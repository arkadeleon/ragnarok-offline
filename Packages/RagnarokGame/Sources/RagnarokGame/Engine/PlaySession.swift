//
//  PlaySession.swift
//  RagnarokGame
//
//  Created by Leon Li on 2026/10/28.
//

import Foundation
import Metal
import Observation
import RagnarokConstants
import RagnarokModels
import RagnarokNetwork
import RagnarokPackets

@MainActor
protocol PlaySessionDelegate: AnyObject {
    func playSession(_ playSession: PlaySession, didFailToEnterWithErrorMessage errorMessage: String)
    func playSessionDidRestart(_ playSession: PlaySession)
    func playSession(_ playSession: PlaySession, didReceiveErrorMessage errorMessage: String)
    func playSessionDidDisconnect(_ playSession: PlaySession)
}

@MainActor
@Observable
final class PlaySession {
    enum MapPhase {
        case connecting
        case loading(_ progress: Progress)
        case loaded(_ runtime: MapSceneRuntime)
    }

    private(set) var mapPhase: MapPhase = .connecting

    private(set) var account: AccountInfo
    let character: CharacterInfo

    var playerStatus: CharacterStatus
    var inventory: Inventory
    var skillList: SkillList
    var skillCooldowns: [Int : SkillCooldown]
    var statusChanges: [StatusChange]
    var shortcutList: ShortcutList
    let messageCenter: MessageCenter

    var dialog: NPCDialog?
    var dealSelectionNPCID: UInt32?
    var npcShop: NPCShop?
    var storage: Storage?
    var warpList: WarpList?

    var interactionMode: GameInteractionMode = .direct

    @ObservationIgnored weak var delegate: (any PlaySessionDelegate)?

    @ObservationIgnored private let context: GameContext
    @ObservationIgnored private let audioPlayer: GameAudioPlayer

    @ObservationIgnored private(set) var mapClient: NetworkClient?
    @ObservationIgnored private var keepaliveTask: Task<Void, Never>?

    @ObservationIgnored private var serverClock = ServerClock()
    @ObservationIgnored private var serverTimeRequestTime: ContinuousClock.Instant?

    var mapRuntime: MapSceneRuntime? {
        if case .loaded(let runtime) = mapPhase {
            runtime
        } else {
            nil
        }
    }

    var mapScene: MapScene? {
        mapRuntime?.scene
    }

    init(context: GameContext, audioPlayer: GameAudioPlayer, account: AccountInfo, character: CharacterInfo) {
        self.context = context
        self.audioPlayer = audioPlayer
        self.account = account
        self.character = character

        self.playerStatus = CharacterStatus(from: character)
        self.inventory = Inventory()
        self.skillList = SkillList()
        self.skillCooldowns = [:]
        self.statusChanges = []
        self.shortcutList = ShortcutList()
        self.messageCenter = MessageCenter(
            itemInfoTable: context.itemInfoTable,
            messageStringTable: context.messageStringTable
        )
    }

    /// Keeps the current cooldown when it would end later than the new one.
    func setSkillCooldown(_ cooldown: SkillCooldown) {
        if let current = skillCooldowns[cooldown.skillID], current.endTime >= cooldown.endTime {
            return
        }
        skillCooldowns[cooldown.skillID] = cooldown
    }

    /// Puts every skill in the shortcut list on cooldown, such as after a skill with a cast delay.
    func setGlobalSkillCooldown(startTime: ContinuousClock.Instant, duration: Duration) {
        for shortcut in shortcutList.rows.joined() {
            if case .skill(let skillID, _) = shortcut {
                let cooldown = SkillCooldown(skillID: skillID, startTime: startTime, duration: duration)
                setSkillCooldown(cooldown)
            }
        }
    }

    /// A status which is already active keeps its place in the list.
    func setStatusChange(_ statusChange: StatusChange) {
        if let index = statusChanges.firstIndex(where: { $0.statusID == statusChange.statusID }) {
            statusChanges[index] = statusChange
        } else {
            statusChanges.append(statusChange)
        }
    }

    func removeStatusChange(statusID: Int) {
        statusChanges.removeAll(where: { $0.statusID == statusID })
    }

    // MARK: - Map Client

    func start(mapServer: MapServerInfo) {
        let mapClient = NetworkClient(
            name: "Map",
            address: mapServer.ip,
            port: mapServer.port
        )
        self.mapClient = mapClient

        // Handle error stream
        Task { [weak self] in
            for await error in mapClient.errorStream {
                logger.warning("\(error)")
                self?.handleClientError(error, from: mapClient)
            }
        }

        // Handle packet stream
        Task { [weak self] in
            for await packet in mapClient.packetStream {
                self?.handlePacket(packet)
            }
        }

        mapClient.connect()

        let packet = PacketFactory.CZ_ENTER(account: account, charID: character.charID)
        mapClient.sendPacket(packet)

        if PACKET_VERSION < 20070521 {
            mapClient.receiveDataAndPacket(count: 4) { [weak self] data in
                let accountID = data.withUnsafeBytes({ $0.load(as: UInt32.self) })
                Task { @MainActor in
                    self?.account.update(accountID: accountID)
                }
            }
        } else {
            mapClient.receivePacket()
        }

        startKeepalive()
    }

    func stop() {
        keepaliveTask?.cancel()
        keepaliveTask = nil

        mapClient?.disconnect()
        mapClient = nil
    }

    private func handleClientError(_ error: NetworkClientError, from client: NetworkClient) {
        guard client === mapClient else {
            return
        }

        switch error {
        case .network, .disconnected:
            if case .connecting = mapPhase {
                let localizedMessage = context.messageStringTable.localizedMessageString(forID: 1)
                delegate?.playSession(self, didFailToEnterWithErrorMessage: localizedMessage)
            } else {
                delegate?.playSessionDidDisconnect(self)
            }
        case .decoding, .encoding:
            break
        }
    }

    private func handlePacket(_ packet: any DecodablePacket) {
        switch packet {
        case let packet as PACKET_ZC_ACCEPT_ENTER:
            serverClock.synchronize(serverTick: packet.startTime, receiveTime: .now)
        case _ as PACKET_ZC_REFUSE_ENTER:
            let localizedMessage = context.messageStringTable.localizedMessageString(forID: 9)
            delegate?.playSession(self, didFailToEnterWithErrorMessage: localizedMessage)
        case let packet as PACKET_ZC_RESTART_ACK:
            if packet.type == 1 {
                delegate?.playSessionDidRestart(self)
            }
        case let packet as PACKET_ZC_ACK_REQ_DISCONNECT:
            messageCenter.addMessage(for: packet)
        case let packet as PACKET_ZC_AID:
            account.update(accountID: packet.accountID)
        case _ as PACKET_ZC_PING_LIVE:
            let packet = PacketFactory.CZ_PING_LIVE()
            mapClient?.sendPacket(packet)
        case let packet as PACKET_ZC_NPCACK_MAPMOVE:
            let mapName = packet.mapName.replacingOccurrences(of: ".gat", with: ".rsw")
            let position = SIMD2(x: Int(packet.xPos), y: Int(packet.yPos))

            if let mapScene, mapScene.mapName == mapName {
                mapScene.jump(toPosition: position)
                notifyMapLoaded()
                break
            }

            mapRuntime?.unload()

            let progress = Progress()
            mapPhase = .loading(progress)

            Task {
                guard let device = MTLCreateSystemDefaultDevice() else {
                    fatalError("PlaySession: Metal is not available on this device")
                }

                let world = try await context.resourceManager.world(mapName: mapName)
                let mapGrid = MapGrid(gat: world.gat)

                let scene = MapScene(
                    mapName: mapName,
                    mapGrid: mapGrid,
                    account: account,
                    character: character,
                    playerPosition: position,
                    resourceManager: context.resourceManager,
                    audioPlayer: audioPlayer,
                    playSession: self
                )
                let renderResources = MapSceneRenderResources(device: device)
                let runtime = MapSceneRuntime(
                    scene: scene,
                    world: world,
                    renderResources: renderResources
                )

                do {
                    try await runtime.load(progress: progress)

                    notifyMapLoaded()

                    mapPhase = .loaded(runtime)
                } catch {
                    logger.warning("Map scene failed to load: \(error)")
                }
            }
        case let packet as PACKET_ZC_NOTIFY_PLAYERMOVE:
            let moveData = MoveData(from: packet.moveData)
            mapScene?.onPlayerMoved(
                startTime: serverClock.time(forServerTick: packet.moveStartTime),
                startPosition: moveData.startPosition,
                endPosition: moveData.endPosition
            )
        case let packet as PACKET_ZC_STATUS:
            let basicStatus = CharacterBasicStatus(from: packet)
            playerStatus.update(from: basicStatus)
        case let packet as PACKET_ZC_SKILLINFO_LIST:
            skillList.replace(from: packet)
        case let packet as PACKET_ZC_SKILLINFO_UPDATE:
            skillList.update(from: packet)
        case let packet as PACKET_ZC_SKILLINFO_UPDATE2:
            skillList.update(from: packet)
        case let packet as PACKET_ZC_ADD_SKILL:
            skillList.add(from: packet)
        case let packet as PACKET_ZC_SKILLINFO_DELETE:
            skillList.delete(from: packet)
        case let packet as PACKET_ZC_SKILL_POSTDELAY:
            let cooldown = SkillCooldown(from: packet, startTime: .now)
            setSkillCooldown(cooldown)
        case let packet as PACKET_ZC_USESKILL_ACK:
            if let skillID = SkillID(rawValue: Int(packet.skillId)),
               let element = Element(rawValue: Int(packet.element)) {
                mapScene?.onMapObjectSkillCast(skillID: skillID, sourceObjectID: packet.srcId, element: element, castTime: .milliseconds(packet.delayTime))
            }
        case let packet as PACKET_ZC_WARPLIST:
            warpList = WarpList(from: packet)
        case let packet as PACKET_ZC_AUTORUN_SKILL:
            var skill = SkillInfo()
            skill.skillID = Int(packet.skill_id)
            skill.flag = Int(packet.skill_type)
            skill.level = Int(packet.skill_lv)
            skill.spCost = Int(packet.skill_sp)
            skill.attackRange = Int(packet.skill_range)
            mapScene?.useSkill(skill, level: skill.level)
        case let packet as PACKET_ZC_DISPEL:
            mapScene?.onMapObjectSkillCastCancelled(sourceObjectID: packet.gid)
        case let packet as PACKET_ZC_ACK_TOUSESKILL:
            messageCenter.addMessage(for: packet)
        case let packet as PACKET_ZC_USE_SKILL:
            let objectSkill = MapObjectSkill(from: packet)
            mapScene?.onMapObjectSkillPerformed(objectSkill: objectSkill)
        case let packet as PACKET_ZC_NOTIFY_SKILL:
            let objectSkill = MapObjectSkill(from: packet)
            mapScene?.onMapObjectSkillPerformed(objectSkill: objectSkill)
        case let packet as PACKET_ZC_NOTIFY_GROUNDSKILL:
            if let skillID = SkillID(rawValue: Int(packet.SKID)) {
                let position = SIMD2(Int(packet.xPos), Int(packet.yPos))
                mapScene?.onGroundSkillCast(skillID: skillID, sourceObjectID: packet.AID, position: position)
            }
        case let packet as PACKET_ZC_SHORTCUT_KEY_LIST:
            shortcutList.update(from: packet)
        case let packet as PACKET_ZC_PAR_CHANGE:
            if let sp = StatusProperty(rawValue: Int(packet.varID)) {
                playerStatus.update(property: sp, value: Int(packet.count))
                mapScene?.onPlayerStatusChanged(property: sp, value: Int(packet.count))
            }
        case let packet as PACKET_ZC_LONGPAR_CHANGE:
            if let sp = StatusProperty(rawValue: Int(packet.varID)) {
                playerStatus.update(property: sp, value: Int(packet.amount))
            }
        case let packet as PACKET_ZC_LONGLONGPAR_CHANGE:
            if let sp = StatusProperty(rawValue: Int(packet.varID)) {
                playerStatus.update(property: sp, value: Int(packet.amount))
            }
        case let packet as PACKET_ZC_STATUS_CHANGE:
            if let sp = StatusProperty(rawValue: Int(packet.statusID)) {
                playerStatus.update(property: sp, value: Int(packet.value))
            }
        case let packet as PACKET_ZC_COUPLESTATUS:
            if let sp = StatusProperty(rawValue: Int(packet.statusType)) {
                playerStatus.update(property: sp, value: Int(packet.defaultStatus), value2: Int(packet.plusStatus))
            }
        case let packet as PACKET_ZC_ATTACK_RANGE:
            playerStatus.update(from: packet)
        case let packet as PACKET_ZC_ATTACK_FAILURE_FOR_DISTANCE:
            mapScene?.onPlayerTooFarToAttack(targetID: packet.targetAID)
        case let packet as PACKET_ZC_ACTION_FAILURE:
            messageCenter.addMessage(for: packet)
        case let packet as PACKET_ZC_RECOVERY:
            if let statusProperty = StatusProperty(rawValue: Int(packet.type)) {
                switch statusProperty {
                case .hp:
                    let amount = Int(packet.amount)
                    let hp = min(playerStatus.hp + amount, playerStatus.maxHp)
                    playerStatus.hp = hp
                    mapScene?.onPlayerHealthPointsRecovered(recovered: amount, current: hp)
                case .sp:
                    let amount = Int(packet.amount)
                    let sp = min(playerStatus.sp + amount, playerStatus.maxSp)
                    playerStatus.sp = sp
                    mapScene?.onPlayerSpellPointsRecovered(recovered: amount, current: sp)
                default:
                    break
                }
            }
        case let packet as PACKET_ZC_NOTIFY_EXP:
            messageCenter.addMessage(for: packet)
        case let packet as PACKET_ZC_INVENTORY_START:
            // invType: 0 = inventory, 1 = cart, 2 = storage, 3 = guild storage
            switch packet.invType {
            case 2:
                storage = Storage(name: packet.name)
            default:
                break
            }
        case _ as PACKET_ZC_INVENTORY_END:
            break
        case let packet as packet_itemlist_normal:
            // invType: 0 = inventory, 1 = cart, 2 = storage, 3 = guild storage
            switch packet.invType {
            case 0:
                inventory.update(from: packet)
            case 2:
                storage?.update(from: packet)
            default:
                break
            }
        case let packet as packet_itemlist_equip:
            // invType: 0 = inventory, 1 = cart, 2 = storage, 3 = guild storage
            switch packet.invType {
            case 0:
                inventory.update(from: packet)
            case 2:
                storage?.update(from: packet)
            default:
                break
            }
        case let packet as PACKET_ZC_ITEM_ENTRY:
            let item = DroppedItem(from: packet)
            let position = SIMD2(x: Int(packet.x), y: Int(packet.y))
            mapScene?.onItemSpawned(item: item, position: position)
        case let packet as packet_dropflooritem:
            let item = DroppedItem(from: packet)
            let position = SIMD2(x: Int(packet.xPos), y: Int(packet.yPos))
            mapScene?.onItemSpawned(item: item, position: position)
        case let packet as PACKET_ZC_ITEM_DISAPPEAR:
            mapScene?.onItemVanished(objectID: packet.itemAid)
        case let packet as PACKET_ZC_ITEM_PICKUP_ACK:
            inventory.update(from: packet)
            messageCenter.addMessage(for: packet)
        case let packet as PACKET_ZC_USE_ITEM_ACK:
            inventory.update(from: packet)
        case let packet as PACKET_ZC_REQ_WEAR_EQUIP_ACK:
            inventory.update(from: packet)
            if let item = inventory.items[Int(packet.index)] {
                messageCenter.addMessage(for: packet, itemID: item.itemID)
            }
        case let packet as PACKET_ZC_REQ_TAKEOFF_EQUIP_ACK:
            inventory.update(from: packet)
            if let item = inventory.items[Int(packet.index)] {
                messageCenter.addMessage(for: packet, itemID: item.itemID)
            }
        case let packet as PACKET_ZC_ITEM_THROW_ACK:
            inventory.update(from: packet)
        case let packet as PACKET_ZC_EQUIP_ARROW:
            inventory.update(from: packet)
        case let packet as PACKET_ZC_DELETE_ITEM_FROM_BODY:
            inventory.update(from: packet)
        case let packet as packet_spawn_unit:
            let object = MapObject(from: packet)
            let posDir = PosDir(from: packet.PosDir)
            let direction = Direction(rawValue: posDir.direction) ?? .north
            let headDirection = HeadDirection(rawValue: Int(packet.headDir)) ?? .lookForward
            logger.info("Object \(object.objectID) spawned at \(posDir.position) direction: \(direction.rawValue)")
            mapScene?.onMapObjectSpawned(object: object, position: posDir.position, direction: direction, headDirection: headDirection)
        case let packet as packet_idle_unit:
            let object = MapObject(from: packet)
            let posDir = PosDir(from: packet.PosDir)
            let direction = Direction(rawValue: posDir.direction) ?? .north
            let headDirection = HeadDirection(rawValue: Int(packet.headDir)) ?? .lookForward
            logger.info("Object \(object.objectID) spawned at \(posDir.position) direction: \(direction.rawValue)")
            mapScene?.onMapObjectSpawned(object: object, position: posDir.position, direction: direction, headDirection: headDirection)
        case let packet as packet_unit_walking:
            let object = MapObject(from: packet)
            let moveData = MoveData(from: packet.MoveData)
            logger.info("Object \(object.objectID) moved from \(moveData.startPosition) to \(moveData.endPosition)")
            mapScene?.onMapObjectMoved(
                object: object,
                startTime: serverClock.time(forServerTick: packet.moveStartTime),
                startPosition: moveData.startPosition,
                endPosition: moveData.endPosition
            )
        case let packet as PACKET_ZC_STOPMOVE:
            let objectID = packet.AID
            let position = SIMD2(x: Int(packet.xPos), y: Int(packet.yPos))
            logger.info("Object \(objectID) stopped at \(position)")
            mapScene?.onMapObjectStopped(objectID: objectID, position: position)
        case let packet as PACKET_ZC_NOTIFY_VANISH:
            let objectID = packet.gid
            let type = UnitClearType(rawValue: Int(packet.type)) ?? .outsight
            logger.info("Object \(objectID) vanished (type: \(packet.type))")
            mapScene?.onMapObjectVanished(objectID: objectID, type: type)
        case let packet as PACKET_ZC_RESURRECTION:
            logger.info("Object \(packet.gid) resurrected")
            mapScene?.onMapObjectResurrected(objectID: packet.gid)
        case let packet as PACKET_ZC_CHANGE_DIRECTION:
            let direction = Direction(rawValue: Int(packet.dir)) ?? .north
            let headDirection = HeadDirection(rawValue: Int(packet.headDir)) ?? .lookForward
            mapScene?.onMapObjectDirectionChanged(objectID: packet.srcId, direction: direction, headDirection: headDirection)
        case let packet as PACKET_ZC_SPRITE_CHANGE:
            if let look = Look(rawValue: Int(packet.type)) {
                mapScene?.onMapObjectSpriteChanged(objectID: packet.AID, look: look, value: Int(packet.val), value2: Int(packet.val2))
            }
        case let packet as PACKET_ZC_STATE_CHANGE:
            let bodyState = StatusChangeOption1(rawValue: Int(packet.bodyState)) ?? .none
            let healthState = StatusChangeOption2(rawValue: Int(packet.healthState)) ?? .none
            let effectState = StatusChangeOption(rawValue: Int(packet.effectState)) ?? .nothing
            mapScene?.onMapObjectStateChanged(objectID: packet.AID, bodyState: bodyState, healthState: healthState, effectState: effectState)
        case let packet as PACKET_ZC_NOTIFY_ACT:
            let objectAction = MapObjectAction(from: packet)
            mapScene?.onMapObjectActionPerformed(objectAction: objectAction)
            messageCenter.addMessage(for: objectAction, account: account)
        case let packet as PACKET_ZC_HP_INFO:
            mapScene?.onMapObjectHealthUpdated(objectID: packet.GID, hp: Int(packet.HP), maxHp: Int(packet.maxHP))
        case let packet as PACKET_ZC_MSG_STATE_CHANGE:
            if packet.AID == account.accountID {
                if packet.state != 0 {
                    let statusChange = StatusChange(statusID: Int(packet.index), startTime: .now, duration: nil)
                    setStatusChange(statusChange)
                } else {
                    removeStatusChange(statusID: Int(packet.index))
                }
            }
        case let packet as PACKET_ZC_MSG_STATE_CHANGE3:
            if packet.AID == account.accountID {
                switch OfficialStatusChangeID(rawValue: Int(packet.index)) {
                case .efst_postdelay, .efst_groundmagic:
                    if packet.remain > 0 {
                        setGlobalSkillCooldown(startTime: .now, duration: .milliseconds(packet.remain))
                    }
                default:
                    break
                }

                if packet.state != 0 {
                    let statusChange = StatusChange(from: packet, startTime: .now)
                    setStatusChange(statusChange)
                }
            }
        case let packet as PACKET_ZC_NOTIFY_EFFECT:
            if let effect = NotifyEffect(rawValue: Int(packet.effectId)) {
                mapScene?.onSpecialEffectSpawned(effect: effect, objectID: packet.aid)
            }
        case let packet as PACKET_ZC_NOTIFY_EFFECT2:
            if let effectID = EffectID(rawValue: Int(packet.effectID)) {
                mapScene?.onEffectSpawned(effectID: effectID, objectID: packet.AID)
            }
        case let packet as PACKET_ZC_SAY_DIALOG:
            if dialog?.npcID == packet.NpcID {
                dialog?.update(from: packet)
            } else {
                dialog = NPCDialog(from: packet)
            }
        case let packet as PACKET_ZC_WAIT_DIALOG:
            dialog?.update(from: packet)
        case let packet as PACKET_ZC_CLOSE_DIALOG:
            dialog?.update(from: packet)
        case let packet as PACKET_ZC_CLEAR_DIALOG:
            if dialog?.npcID == packet.GID {
                dialog = nil
            }
        case let packet as PACKET_ZC_MENU_LIST:
            dialog?.update(from: packet)
        case let packet as PACKET_ZC_OPEN_EDITDLG:
            dialog?.update(from: packet)
        case let packet as PACKET_ZC_OPEN_EDITDLGSTR:
            dialog?.update(from: packet)
        case _ as PACKET_ZC_SHOW_IMAGE:
            break
        case _ as PACKET_ZC_COMPASS:
            break
        case let packet as PACKET_ZC_SELECT_DEALTYPE:
            dealSelectionNPCID = packet.npcId
        case let packet as PACKET_ZC_PC_PURCHASE_ITEMLIST:
            npcShop = NPCShop(from: packet)
        case let packet as PACKET_ZC_PC_SELL_ITEMLIST:
            npcShop = NPCShop(from: packet)
        case let packet as PACKET_ZC_PC_PURCHASE_RESULT:
            npcShop = nil
            messageCenter.addMessage(for: packet)
        case let packet as PACKET_ZC_PC_SELL_RESULT:
            npcShop = nil
            messageCenter.addMessage(for: packet)
        case let packet as PACKET_ZC_NOTIFY_STOREITEM_COUNTINFO:
            storage?.update(from: packet)
        case let packet as PACKET_ZC_ADD_ITEM_TO_STORE:
            storage?.update(from: packet)
        case let packet as PACKET_ZC_DELETE_ITEM_FROM_STORE:
            storage?.update(from: packet)
        case _ as PACKET_ZC_CLOSE_STORE:
            storage = nil
        case let packet as PACKET_ZC_NOTIFY_CHAT:
            let message = ChatMessage(from: packet)
            messageCenter.add(message)
        case let packet as PACKET_ZC_WHISPER:
            let message = ChatMessage(from: packet)
            messageCenter.add(message)
        case let packet as PACKET_ZC_NOTIFY_PLAYERCHAT:
            let message = ChatMessage(from: packet)
            messageCenter.add(message)
        case let packet as PACKET_ZC_NPC_CHAT:
            let message = ChatMessage(from: packet)
            messageCenter.add(message)
        case let packet as PACKET_ZC_NOTIFY_CHAT_PARTY:
            let message = ChatMessage(from: packet)
            messageCenter.add(message)
        case let packet as PACKET_ZC_GUILD_CHAT:
            let message = ChatMessage(from: packet)
            messageCenter.add(message)
        case let packet as PACKET_ZC_NOTIFY_CLAN_CHAT:
            let message = ChatMessage(from: packet)
            messageCenter.add(message)
        case _ as PACKET_ZC_ALL_ACH_LIST:
            break
        case _ as PACKET_ZC_ACH_UPDATE:
            break
        case let packet as PACKET_ZC_NOTIFY_TIME:
            if let requestTime = serverTimeRequestTime {
                let now = ContinuousClock.now
                serverClock.synchronize(serverTick: packet.time, receiveTime: now, roundTripTime: requestTime.duration(to: now))
                serverTimeRequestTime = nil
            }
        case let packet as PACKET_SC_NOTIFY_BAN:
            let message = BannedMessage(from: packet)
            let localizedMessage = context.messageStringTable.localizedMessageString(forID: message.messageID)
            delegate?.playSession(self, didReceiveErrorMessage: localizedMessage)
        case _ as PACKET_ZC_FRIENDS_LIST:
            break
        case _ as PACKET_ZC_EXTEND_BODYITEM_SIZE:
            break
        case _ as PACKET_ZC_STATUS_CHANGE_ACK:
            break
        case _ as PACKET_ZC_NOTIFY_CARTITEM_COUNTINFO:
            break
        case _ as PACKET_ZC_PARTY_CONFIG:
            break
        case _ as PACKET_ZC_REPUTE_INFO:
            break
        case _ as PACKET_ZC_BROADCAST:
            break
        case _ as PACKET_ZC_BROADCAST2:
            break
        default:
            break
        }
    }

    /// Keep alive and synchronize the server clock.
    ///
    /// Send ``PACKET_CZ_REQUEST_TIME`` every second for the first 5 seconds, then every 10 seconds.
    /// The map server drops it until the map is loaded, so it restarts after each map load.
    private func startKeepalive() {
        guard let mapClient else {
            return
        }

        let startTime = ContinuousClock.now

        keepaliveTask?.cancel()
        keepaliveTask = Task {
            var requestCount = 0
            while !Task.isCancelled {
                let now = ContinuousClock.now
                let clientTime = Int(startTime.duration(to: now).timeInterval * 1000)
                serverTimeRequestTime = now

                let packet = PacketFactory.CZ_REQUEST_TIME(clientTime: UInt32(truncatingIfNeeded: clientTime))
                mapClient.sendPacket(packet)

                try? await Task.sleep(for: requestCount < 5 ? .seconds(1) : .seconds(10))
                requestCount += 1
            }
        }
    }

    // MARK: - Map Operations

    func notifyMapLoaded() {
        guard let mapClient else {
            return
        }

        let packet = PacketFactory.CZ_NOTIFY_ACTORINIT()
        mapClient.sendPacket(packet)

        startKeepalive()
    }

    func resurrectInPlace() {
        guard let mapClient else {
            return
        }

        let packet = PacketFactory.CZ_STANDING_RESURRECTION()
        mapClient.sendPacket(packet)
    }

    func returnToLastSavePoint() {
        guard let mapClient else {
            return
        }

        let packet = PacketFactory.CZ_RESTART(type: 0)
        mapClient.sendPacket(packet)
    }

    func returnToCharacterSelect() {
        guard let mapClient else {
            return
        }

        let packet = PacketFactory.CZ_RESTART(type: 1)
        mapClient.sendPacket(packet)
    }

    func requestExit() {
        guard let mapClient else {
            return
        }

        let packet = PacketFactory.CZ_REQUEST_QUIT()
        mapClient.sendPacket(packet)
    }

    // MARK: - Player

    /// Request move to position.
    ///
    /// Send ``PACKET_CZ_REQUEST_MOVE``
    func requestMove(to position: SIMD2<Int>) {
        guard let mapClient else {
            return
        }

        let packet = PacketFactory.CZ_REQUEST_MOVE(position: position)
        mapClient.sendPacket(packet)
    }

    /// Request action on target.
    ///
    /// Send ``PACKET_CZ_REQUEST_ACT``
    func requestAction(_ actionType: DamageType, onTarget targetID: GameObjectID = 0) {
        guard let mapClient else {
            return
        }

        let packet = PacketFactory.CZ_REQUEST_ACT(targetID: targetID, actionType: actionType)
        mapClient.sendPacket(packet)
    }

    /// Change direction.
    ///
    /// Send ``PACKET_CZ_CHANGE_DIRECTION``
    ///
    /// Receive ``PACKET_ZC_CHANGE_DIRECTION``
    func changeDirection(direction: Direction, headDirection: HeadDirection) {
        guard let mapClient else {
            return
        }

        let packet = PacketFactory.CZ_CHANGE_DIRECTION(
            headDirection: UInt16(headDirection.rawValue),
            direction: UInt8(direction.rawValue)
        )
        mapClient.sendPacket(packet)
    }

    func incrementStatusProperty(_ sp: StatusProperty, by amount: Int) {
        guard let mapClient else {
            return
        }

        switch sp {
        case .str, .agi, .vit, .int, .dex, .luk:
            let packet = PacketFactory.CZ_STATUS_CHANGE(property: sp, amount: amount)
            mapClient.sendPacket(packet)
        case .pow, .sta, .wis, .spl, .con, .crt:
            let packet = PacketFactory.CZ_ADVANCED_STATUS_CHANGE(property: sp, amount: amount)
            mapClient.sendPacket(packet)
        default:
            break
        }
    }

    func upgradeSkillLevel(skillID: Int) {
        guard let mapClient else {
            return
        }

        let packet = PacketFactory.CZ_UPGRADE_SKILLLEVEL(skillID: skillID)
        mapClient.sendPacket(packet)
    }

    func useSkill(skillID: Int, level: Int, onTarget targetID: GameObjectID) {
        guard let mapClient else {
            return
        }

        let packet = PacketFactory.CZ_USE_SKILL(
            skillID: skillID,
            selectedLevel: max(level, 1),
            targetID: targetID
        )
        mapClient.sendPacket(packet)
    }

    func useSkill(skillID: Int, level: Int, toGround position: SIMD2<Int>) {
        guard let mapClient else {
            return
        }

        let packet = PacketFactory.CZ_USE_SKILL_TOGROUND(
            skillID: skillID,
            selectedLevel: max(level, 1),
            position: position
        )
        mapClient.sendPacket(packet)
    }

    func selectWarpPoint(mapName: String) {
        guard let mapClient, let warpList else {
            return
        }

        let packet = PacketFactory.CZ_SELECT_WARPPOINT(skillID: warpList.skillID, mapName: mapName)
        mapClient.sendPacket(packet)

        self.warpList = nil
    }

    func cancelWarpPoint() {
        selectWarpPoint(mapName: "cancel")
    }

    // MARK: - Item

    func pickUpItem(objectID: GameObjectID) {
        guard let mapClient else {
            return
        }

        let packet = PacketFactory.CZ_ITEM_PICKUP(objectID: objectID)
        mapClient.sendPacket(packet)
    }

    func useItem(at index: Int) {
        guard let mapClient else {
            return
        }

        let packet = PacketFactory.CZ_USE_ITEM(index: index, accountID: account.accountID)
        mapClient.sendPacket(packet)
    }

    func equipItem(at index: Int, location: EquipPositions) {
        guard let mapClient else {
            return
        }

        let packet = PacketFactory.CZ_REQ_WEAR_EQUIP(index: index, location: location)
        mapClient.sendPacket(packet)
    }

    func unequipItem(at index: Int) {
        guard let mapClient else {
            return
        }

        let packet = PacketFactory.CZ_REQ_TAKEOFF_EQUIP(index: index)
        mapClient.sendPacket(packet)
    }

    func throwItem(at index: Int, amount: Int) {
        guard let mapClient else {
            return
        }

        let packet = PacketFactory.CZ_ITEM_THROW(index: index, amount: amount)
        mapClient.sendPacket(packet)
    }

    // MARK: - Shortcut

    func setShortcut(_ shortcut: Shortcut, atRow row: Int, column: Int) {
        guard let mapClient else {
            return
        }

        var shortcutList = self.shortcutList
        shortcutList.setShortcut(shortcut, atRow: row, column: column)

        for change in shortcutList.changes(from: self.shortcutList) {
            let packet = PacketFactory.CZ_SHORTCUT_KEY_CHANGE2(change: change)
            mapClient.sendPacket(packet)
        }

        self.shortcutList = shortcutList
    }

    func removeShortcut(atRow row: Int, column: Int) {
        setShortcut(.empty, atRow: row, column: column)
    }

    func moveShortcut(
        _ shortcut: Shortcut,
        fromRow sourceRow: Int,
        column sourceColumn: Int,
        toRow targetRow: Int,
        column targetColumn: Int
    ) {
        guard let mapClient,
              shortcutList.rows[sourceRow][sourceColumn] == shortcut else {
            return
        }

        var shortcutList = self.shortcutList
        shortcutList.setShortcut(.empty, atRow: sourceRow, column: sourceColumn)
        shortcutList.setShortcut(shortcut, atRow: targetRow, column: targetColumn)

        for change in shortcutList.changes(from: self.shortcutList) {
            let packet = PacketFactory.CZ_SHORTCUT_KEY_CHANGE2(change: change)
            mapClient.sendPacket(packet)
        }

        self.shortcutList = shortcutList
    }

    func setShortcutRowShift(_ rowShift: Int) {
        guard let mapClient else {
            return
        }

        shortcutList.rowShift = rowShift

        let packet = PacketFactory.CZ_SHORTCUTKEYBAR_ROTATE2(rowShift: rowShift)
        mapClient.sendPacket(packet)
    }

    // MARK: - NPC Dialog

    func talkToNPC(npcID: GameObjectID) {
        guard let mapClient else {
            return
        }

        let packet = PacketFactory.CZ_CONTACTNPC(npcID: npcID)
        mapClient.sendPacket(packet)
    }

    func requestNextMessage() {
        guard let mapClient, let npcID = dialog?.npcID else {
            return
        }

        let packet = PacketFactory.CZ_REQ_NEXT_SCRIPT(npcID: npcID)
        mapClient.sendPacket(packet)

        dialog?.setNeedsClearMessage()
        dialog?.clearAction()
    }

    func closeDialog() {
        guard let mapClient, let npcID = dialog?.npcID else {
            return
        }

        dialog = nil

        let packet = PacketFactory.CZ_CLOSE_DIALOG(npcID: npcID)
        mapClient.sendPacket(packet)
    }

    func selectMenu(_ select: UInt8) {
        guard let mapClient, let npcID = dialog?.npcID else {
            return
        }

        dialog?.clearMenu()

        let packet = PacketFactory.CZ_CHOOSE_MENU(npcID: npcID, select: select)
        mapClient.sendPacket(packet)
    }

    func cancelMenu() {
        guard let mapClient, let npcID = dialog?.npcID else {
            return
        }

        dialog = nil

        let packet = PacketFactory.CZ_CHOOSE_MENU(npcID: npcID, select: 255)
        mapClient.sendPacket(packet)
    }

    func confirmInput(_ value: Int32) {
        guard let mapClient, let npcID = dialog?.npcID else {
            return
        }

        let packet = PacketFactory.CZ_INPUT_EDITDLG(npcID: npcID, value: value)
        mapClient.sendPacket(packet)

        dialog?.clearInput()
    }

    func confirmInput(_ value: String) {
        guard let mapClient, let npcID = dialog?.npcID else {
            return
        }

        let packet = PacketFactory.CZ_INPUT_EDITDLGSTR(npcID: npcID, value: value)
        mapClient.sendPacket(packet)

        dialog?.clearInput()
    }

    // MARK: - NPC Shop

    func selectDealType(_ dealType: NPCShopDealType) {
        guard let mapClient, let npcID = dealSelectionNPCID else {
            return
        }

        dealSelectionNPCID = nil

        let packet = PacketFactory.CZ_ACK_SELECT_DEALTYPE(npcID: npcID, dealType: dealType)
        mapClient.sendPacket(packet)
    }

    func cancelDealSelection() {
        dealSelectionNPCID = nil
    }

    func purchaseItems(_ purchases: [NPCShopPurchase]) {
        guard let mapClient else {
            return
        }

        let packet = PacketFactory.CZ_PC_PURCHASE_ITEMLIST(purchases: purchases)
        mapClient.sendPacket(packet)
    }

    func sellItems(_ sales: [NPCShopSale]) {
        guard let mapClient else {
            return
        }

        let packet = PacketFactory.CZ_PC_SELL_ITEMLIST(sales: sales)
        mapClient.sendPacket(packet)
    }

    func closeNPCShop() {
        guard let mapClient else {
            return
        }

        npcShop = nil

        let packet = PacketFactory.CZ_NPC_TRADE_QUIT()
        mapClient.sendPacket(packet)
    }

    // MARK: - Storage

    func moveItemToStorage(index: Int, amount: Int) {
        guard let mapClient, storage != nil else {
            return
        }

        let packet = PacketFactory.CZ_MOVE_ITEM_FROM_BODY_TO_STORE(index: index, amount: amount)
        mapClient.sendPacket(packet)
    }

    func moveItemFromStorage(index: Int, amount: Int) {
        guard let mapClient, storage != nil else {
            return
        }

        let packet = PacketFactory.CZ_MOVE_ITEM_FROM_STORE_TO_BODY(index: index, amount: amount)
        mapClient.sendPacket(packet)
    }

    func closeStorage() {
        guard let mapClient else {
            return
        }

        storage = nil

        let packet = PacketFactory.CZ_CLOSE_STORE()
        mapClient.sendPacket(packet)
    }
}

extension PlaySession {
    /// An item which is no longer in the inventory is dimmed, and cannot be used.
    func isShortcutAvailable(_ shortcut: Shortcut) -> Bool {
        switch shortcut {
        case .empty, .skill:
            true
        case .item(let itemID):
            inventory.items.values.contains(where: { $0.itemID == itemID })
        }
    }

    /// The number shown beside the icon: how many of an item are left, or the level a skill is used at.
    func shortcutLabel(_ shortcut: Shortcut) -> String? {
        switch shortcut {
        case .empty:
            nil
        case .item(let itemID):
            inventory.items.values.first(where: { $0.itemID == itemID }).map({ "\($0.amount)" })
        case .skill(_, let level):
            "\(level)"
        }
    }

    func skillCooldown(for shortcut: Shortcut) -> SkillCooldown? {
        switch shortcut {
        case .empty, .item:
            nil
        case .skill(let skillID, _):
            skillCooldowns[skillID]
        }
    }
}

extension PlaySession {
    static let testing = PlaySession(context: .testing)

    convenience init(context: GameContext) {
        self.init(
            context: context,
            audioPlayer: GameAudioPlayer(resourceManager: context.resourceManager),
            account: AccountInfo(from: PACKET_AC_ACCEPT_LOGIN()),
            character: CharacterInfo()
        )
    }
}
