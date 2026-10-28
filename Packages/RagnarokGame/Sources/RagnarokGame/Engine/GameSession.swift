//
//  GameSession.swift
//  RagnarokGame
//
//  Created by Leon Li on 2024/9/5.
//

import Foundation
import Metal
import Network
import Observation
import RagnarokConstants
import RagnarokLocalization
import RagnarokModels
import RagnarokNetwork
import RagnarokPackets
import RagnarokRendering
import RagnarokRenderAssets
import RagnarokResources
import RagnarokSprite

@MainActor
@Observable
final public class GameSession {
    public static let windowID = "Game"
    public static let immersiveSpaceID = "Game"

    let context: GameContext
    let audioPlayer: GameAudioPlayer

    public struct Configuration: Codable, Hashable {
        public var serverAddress: String
        public var serverPort: UInt16

        public init(serverAddress: String, serverPort: UInt16) {
            self.serverAddress = serverAddress
            self.serverPort = serverPort
        }
    }

    public enum State {
        case notStarted
        case running(configuration: GameSession.Configuration)
        case stopped
    }

    public private(set) var state: GameSession.State = .notStarted

    private(set) var stage: GameStage = .login(.login)

    struct ErrorMessage: Identifiable {
        typealias Action = @MainActor (_ gameSession: GameSession, _ errorMessage: GameSession.ErrorMessage) -> Void

        let id = UUID()
        let content: String
        let action: GameSession.ErrorMessage.Action

        init(content: String, action: GameSession.ErrorMessage.Action? = nil) {
            self.content = content
            self.action = action ?? { gameSession, errorMessage in
                gameSession.removeErrorMessage(errorMessage)
            }
        }

        @MainActor
        func performAction(in gameSession: GameSession) {
            action(gameSession, self)
        }
    }

    private var username: String?

    private(set) var isDisconnected = false
    private(set) var errorMessages: [GameSession.ErrorMessage] = []
    private(set) var account: AccountInfo?
    private(set) var charServers: [CharServerInfo] = []
    private(set) var charServer: CharServerInfo?
    private(set) var characters: [CharacterInfo] = []

    var selectedCharacterSlot: Int = 0
    private(set) var maxCharacterSlots: Int = 9

    private(set) var playSession: PlaySession?

    @ObservationIgnored var loginClient: NetworkClient?
    @ObservationIgnored var loginKeepaliveTask: Task<Void, Never>?

    @ObservationIgnored var charClient: NetworkClient?
    @ObservationIgnored var charKeepaliveTask: Task<Void, Never>?


    public var mapScene: MapScene? {
        mapRuntime?.scene
    }

    var mapRuntime: MapSceneRuntime? {
        if case .map(let mapPhase) = stage, case .loaded(let runtime) = mapPhase {
            runtime
        } else {
            nil
        }
    }

    public init(resourceManager: ResourceManager) {
        self.context = GameContext(resourceManager: resourceManager)
        self.audioPlayer = GameAudioPlayer(resourceManager: resourceManager)
    }

    // MARK: - Public

    public func start(_ configuration: GameSession.Configuration) {
        state = .running(configuration: configuration)
    }

    public func stop() {
        exitSession()
        state = .stopped
    }

    // MARK: - Internal

    func removeErrorMessage(_ errorMessage: GameSession.ErrorMessage) {
        if let index = errorMessages.firstIndex(where: { $0.id == errorMessage.id }) {
            errorMessages.remove(at: index)
        }
    }

    func exitSession() {
        mapRuntime?.unload()

        stopAllClients()
        playSession = nil
        resetLoginPhase()

        isDisconnected = false
        errorMessages.removeAll()
    }

    func stopAllClients() {
        playSession?.stop()
        stopCharClient()
        stopLoginClient()
    }

    func exitCurrentPhase() {
        switch stage {
        case .login(.login):
            stopAllClients()
            resetLoginPhase()
        case .login(.loggingIn), .login(.charServerList):
            stopLoginClient()
            resetLoginPhase()
        case .login(.connectingCharServer), .login(.characterSelect):
            stopCharClient()
            resetLoginPhase()
        case .login(.characterMake):
            stage = .login(.characterSelect(characters))
        case .login(.waitingForMapServer):
            playSession?.stop()
            stopCharClient()
            playSession = nil
            resetLoginPhase()
        case .map:
            mapRuntime?.unload()
            if let playSession {
                account = playSession.account
            }
            playSession?.stop()
            playSession = nil
            if let charServer {
                stage = .login(.connectingCharServer(charServer))
                startCharClient(charServer)
            } else {
                stage = .login(.login)
            }
        }
    }

    private func resetLoginPhase() {
        account = nil
        charServers = []
        charServer = nil
        characters = []
        selectedCharacterSlot = 0
        maxCharacterSlots = 9

        stage = .login(.login)
    }

    private func handleClientError(_ error: NetworkClientError, from client: NetworkClient) {
        switch error {
        case .network, .disconnected:
            switch stage {
            case .login:
                guard client === loginClient || client === charClient || client === playSession?.mapClient else {
                    break
                }

                stopAllClients()

                let localizedMessage = context.messageStringTable.localizedMessageString(forID: 1)
                let errorMessage = GameSession.ErrorMessage(content: localizedMessage) { gameSession, errorMessage in
                    gameSession.removeErrorMessage(errorMessage)
                    gameSession.resetLoginPhase()
                }
                errorMessages.append(errorMessage)
            case .map:
                guard client === playSession?.mapClient else {
                    break
                }

                isDisconnected = true
            }
        case .decoding, .encoding:
            break
        }
    }

    // MARK: - Login Client

    func login(username: String, password: String) {
        guard case .login(.login) = stage else {
            return
        }

        startLoginClient()

        guard let loginClient else {
            return
        }

        stage = .login(.loggingIn)

        self.username = username

        let packet = PacketFactory.CA_LOGIN(username: username, password: password)
        loginClient.sendPacket(packet)

        loginClient.receivePacket()
    }

    private func startLoginClient() {
        guard case .running(let configuration) = state else {
            return
        }

        let client = NetworkClient(
            name: "Login",
            address: configuration.serverAddress,
            port: configuration.serverPort
        )

        // Handle error stream
        Task {
            for await error in client.errorStream {
                logger.warning("\(error)")
                handleClientError(error, from: client)
            }
        }

        // Handle packet stream
        Task {
            for await packet in client.packetStream {
                handleLoginPacket(packet)
            }
        }

        client.connect()

        self.loginClient = client
    }

    private func stopLoginClient() {
        loginKeepaliveTask?.cancel()
        loginKeepaliveTask = nil

        loginClient?.disconnect()
        loginClient = nil
    }

    private func handleLoginPacket(_ packet: any DecodablePacket) {
        switch packet {
        case let packet as PACKET_AC_ACCEPT_LOGIN:
            let account = AccountInfo(from: packet)
            let charServers = packet.char_servers.map(CharServerInfo.init(from:))

            self.account = account
            self.charServers = charServers

            if charServers.count == 1 {
                selectCharServer(charServers[0])
            } else if charServers.count > 1 {
                stage = .login(.charServerList(charServers))
            } else {
                stage = .login(.login)
            }

            startLoginKeepalive()
        case let packet as PACKET_AC_REFUSE_LOGIN:
            stopLoginClient()

            let message = LoginRefusedMessage(from: packet)
            let localizedMessage = context.messageStringTable.localizedMessageString(forID: message.messageID, arguments: message.unblockTime)
            let errorMessage = GameSession.ErrorMessage(content: localizedMessage) { gameSession, errorMessage in
                gameSession.removeErrorMessage(errorMessage)
                gameSession.resetLoginPhase()
            }
            errorMessages.append(errorMessage)
        case let packet as PACKET_SC_NOTIFY_BAN:
            stopLoginClient()

            let message = BannedMessage(from: packet)
            let localizedMessage = context.messageStringTable.localizedMessageString(forID: message.messageID)
            let errorMessage = GameSession.ErrorMessage(content: localizedMessage) { gameSession, errorMessage in
                gameSession.removeErrorMessage(errorMessage)
                gameSession.resetLoginPhase()
            }
            errorMessages.append(errorMessage)
        default:
            break
        }
    }

    /// Keep alive.
    ///
    /// Send ``PACKET_CA_CONNECT_INFO_CHANGED`` every 10 seconds.
    private func startLoginKeepalive() {
        guard let loginClient else {
            return
        }

        loginKeepaliveTask = Task {
            do {
                while !Task.isCancelled {
                    try await Task.sleep(for: .seconds(10))

                    let packet = PacketFactory.CA_CONNECT_INFO_CHANGED(username: username ?? "")
                    loginClient.sendPacket(packet)
                }
            } catch {
                logger.warning("\(error)")
            }
        }
    }

    // MARK: - Char Client

    func selectCharServer(_ charServer: CharServerInfo) {
        stopLoginClient()

        self.charServer = charServer
        stage = .login(.connectingCharServer(charServer))

        startCharClient(charServer)
    }

    func makeCharacter(slot: Int) {
        stage = .login(.characterMake(slot))
    }

    /// Select character.
    ///
    /// Send ``PACKET_CH_SELECT_CHAR``
    func selectCharacter(slot: Int) {
        guard case .login(.characterSelect) = stage, let charClient else {
            return
        }

        stage = .login(.waitingForMapServer(slot))

        let packet = PacketFactory.CH_SELECT_CHAR(slot: slot)
        charClient.sendPacket(packet)
    }

    /// Create character.
    ///
    /// Send ``PACKET_CH_MAKE_CHAR``
    func createCharacter(_ character: CharacterInfo) {
        guard let charClient else {
            return
        }

        let packet = PacketFactory.CH_MAKE_CHAR(character: character)
        charClient.sendPacket(packet)
    }

    /// Delete character.
    ///
    /// Send ``PACKET_CH_DELETE_CHAR3_RESERVED``, then ``PACKET_CH_DELETE_CHAR3`` on success.
    func deleteCharacter(charID: UInt32) {
        guard case .login(.characterSelect) = stage, let charClient else {
            return
        }

        let packet = PacketFactory.CH_DELETE_CHAR3_RESERVED(charID: charID)
        charClient.sendPacket(packet)
    }

    private func startCharClient(_ charServer: CharServerInfo) {
        guard let account else {
            preconditionFailure("startCharClient called before account was set")
        }

        let client = NetworkClient(
            name: "Char",
            address: charServer.ip,
            port: charServer.port
        )

        // Handle error stream
        Task {
            for await error in client.errorStream {
                logger.warning("\(error)")
                handleClientError(error, from: client)
            }
        }

        // Handle packet stream
        Task {
            for await packet in client.packetStream {
                handleCharPacket(packet)
            }
        }

        client.connect()

        self.charClient = client

        let packet = PacketFactory.CH_ENTER(account: account)
        client.sendPacket(packet)

        // Receive accountID (4 bytes) and update account
        client.receiveDataAndPacket(count: 4) { [weak self] data in
            let accountID = data.withUnsafeBytes({ $0.load(as: UInt32.self) })
            Task { @MainActor in
                self?.account?.update(accountID: accountID)
            }
        }

        startCharKeepalive()
    }

    private func stopCharClient() {
        charKeepaliveTask?.cancel()
        charKeepaliveTask = nil

        charClient?.disconnect()
        charClient = nil
    }

    private func handleCharPacket(_ packet: any DecodablePacket) {
        switch packet {
        case let packet as PACKET_HC_ACCEPT_ENTER:
            let characters = packet.characters.map(CharacterInfo.init(from:))
            self.characters = characters

            let maxSlots = Int(packet.total)
            if maxSlots > 0 {
                maxCharacterSlots = maxSlots
            } else {
                let highestSlot = characters.map(\.charNum).max() ?? -1
                maxCharacterSlots = max(highestSlot + 1, 9)
            }

            stage = .login(.characterSelect(characters))
        case _ as PACKET_HC_REFUSE_ENTER:
            switch stage {
            case .login(.waitingForMapServer):
                let localizedMessage = context.messageStringTable.localizedMessageString(forID: 9)
                let errorMessage = GameSession.ErrorMessage(content: localizedMessage) { gameSession, errorMessage in
                    gameSession.removeErrorMessage(errorMessage)
                    gameSession.stage = .login(.characterSelect(gameSession.characters))
                }
                errorMessages.append(errorMessage)
            default:
                stopCharClient()

                let localizedMessage = context.messageStringTable.localizedMessageString(forID: 9)
                let errorMessage = GameSession.ErrorMessage(content: localizedMessage) { gameSession, errorMessage in
                    gameSession.removeErrorMessage(errorMessage)
                    gameSession.resetLoginPhase()
                }
                errorMessages.append(errorMessage)
            }
        case let packet as PACKET_HC_NOTIFY_ZONESVR:
            if let character = characters.first(where: { $0.charID == packet.CID }) {
                let mapServer = MapServerInfo(from: packet)

                stopCharClient()

                startMapClient(character: character, mapServer: mapServer)
            }
        case _ as PACKET_HC_NOTIFY_ACCESSIBLE_MAPNAME:
            let localizedMessage = context.messageStringTable.localizedMessageString(forID: 1811)
            let errorMessage = GameSession.ErrorMessage(content: localizedMessage) { gameSession, errorMessage in
                gameSession.removeErrorMessage(errorMessage)
                gameSession.stage = .login(.characterSelect(gameSession.characters))
            }
            errorMessages.append(errorMessage)
        case let packet as PACKET_HC_ACCEPT_MAKECHAR:
            let character = CharacterInfo(from: packet.character)
            characters.append(character)
            selectedCharacterSlot = character.charNum
            stage = .login(.characterSelect(characters))
        case let packet as PACKET_HC_REFUSE_MAKECHAR:
            let message = MakeCharRefusedMessage(from: packet)
            let localizedMessage = context.messageStringTable.localizedMessageString(forID: message.messageID)
            let errorMessage = GameSession.ErrorMessage(content: localizedMessage)
            errorMessages.append(errorMessage)
        case _ as PACKET_HC_ACCEPT_DELETECHAR:
            break
        case _ as PACKET_HC_REFUSE_DELETECHAR:
            break
        case let packet as PACKET_HC_DELETE_CHAR3_RESERVED:
            if packet.result == 1 {
                let packet = PacketFactory.CH_DELETE_CHAR3(charID: packet.CID, birthdate: "")
                charClient?.sendPacket(packet)
            } else {
                let message = DeleteCharReservedMessage(from: packet)
                let localizedMessage = context.messageStringTable.localizedMessageString(forID: message.messageID)
                let errorMessage = GameSession.ErrorMessage(content: localizedMessage)
                errorMessages.append(errorMessage)
            }
        case let packet as PACKET_HC_DELETE_CHAR3:
            if packet.result == 1 {
                characters.removeAll(where: { $0.charID == packet.CID })
                stage = .login(.characterSelect(characters))
            } else {
                let message = DeleteCharMessage(from: packet)
                let localizedMessage = context.messageStringTable.localizedMessageString(forID: message.messageID)
                let errorMessage = GameSession.ErrorMessage(content: localizedMessage)
                errorMessages.append(errorMessage)
            }
        case _ as PACKET_HC_DELETE_CHAR3_CANCEL:
            break
        case _ as PACKET_HC_ACCEPT_ENTER2:
            break
        case _ as PACKET_HC_SECOND_PASSWD_LOGIN:
            break
        case _ as PACKET_HC_CHARLIST_NOTIFY:
            break
        case _ as PACKET_HC_BLOCK_CHARACTER:
            break
        case let packet as PACKET_SC_NOTIFY_BAN:
            stopCharClient()

            let message = BannedMessage(from: packet)
            let localizedMessage = context.messageStringTable.localizedMessageString(forID: message.messageID)
            let errorMessage = GameSession.ErrorMessage(content: localizedMessage) { gameSession, errorMessage in
                gameSession.removeErrorMessage(errorMessage)
                gameSession.resetLoginPhase()
            }
            errorMessages.append(errorMessage)
        default:
            break
        }
    }

    /// Keep alive.
    ///
    /// Send ``PACKET_CH_ENTER`` (PACKET_PING) every 12 seconds.
    private func startCharKeepalive() {
        guard let charClient, let account else {
            return
        }

        charKeepaliveTask = Task {
            do {
                while !Task.isCancelled {
                    try await Task.sleep(for: .seconds(12))

                    let packet = PacketFactory.PING(accountID: account.accountID)
                    charClient.sendPacket(packet)
                }
            } catch {
                logger.warning("\(error)")
            }
        }
    }

    // MARK: - Map Client

    private func startMapClient(character: CharacterInfo, mapServer: MapServerInfo) {
        guard let account else {
            preconditionFailure("startMapClient called before account was set")
        }

        let client = NetworkClient(
            name: "Map",
            address: mapServer.ip,
            port: mapServer.port
        )

        // Handle error stream
        Task {
            for await error in client.errorStream {
                logger.warning("\(error)")
                handleClientError(error, from: client)
            }
        }

        // Handle packet stream
        Task {
            for await packet in client.packetStream {
                handleMapPacket(packet)
            }
        }

        let playSession = PlaySession(
            context: context,
            account: account,
            character: character,
            mapClient: client
        )
        self.playSession = playSession
        playSession.start()
    }

    private func handleMapPacket(_ packet: any DecodablePacket) {
        guard let playSession else {
            return
        }

        switch packet {
        case let packet as PACKET_ZC_ACCEPT_ENTER:
            playSession.serverClock.synchronize(serverTick: packet.startTime, receiveTime: .now)
        case _ as PACKET_ZC_REFUSE_ENTER:
            playSession.stop()

            let localizedMessage = context.messageStringTable.localizedMessageString(forID: 9)
            let errorMessage = GameSession.ErrorMessage(content: localizedMessage) { gameSession, errorMessage in
                gameSession.removeErrorMessage(errorMessage)
                gameSession.resetLoginPhase()
            }
            errorMessages.append(errorMessage)
        case let packet as PACKET_ZC_RESTART_ACK:
            if packet.type == 1 {
                exitCurrentPhase()
            }
        case let packet as PACKET_ZC_ACK_REQ_DISCONNECT:
            playSession.messageCenter.addMessage(for: packet)
        case let packet as PACKET_ZC_AID:
            playSession.account.update(accountID: packet.accountID)
        case _ as PACKET_ZC_PING_LIVE:
            let packet = PacketFactory.CZ_PING_LIVE()
            playSession.mapClient?.sendPacket(packet)
        case let packet as PACKET_ZC_NPCACK_MAPMOVE:
            let mapName = packet.mapName.replacingOccurrences(of: ".gat", with: ".rsw")
            let position = SIMD2(x: Int(packet.xPos), y: Int(packet.yPos))

            if let mapScene, mapScene.mapName == mapName {
                mapScene.jump(toPosition: position)
                playSession.notifyMapLoaded()
                break
            }

            mapRuntime?.unload()

            let progress = Progress()
            stage = .map(.loading(progress))

            Task {
                guard let device = MTLCreateSystemDefaultDevice() else {
                    fatalError("GameSession: Metal is not available on this device")
                }

                let world = try await context.resourceManager.world(mapName: mapName)
                let mapGrid = MapGrid(gat: world.gat)

                let scene = MapScene(
                    mapName: mapName,
                    mapGrid: mapGrid,
                    account: playSession.account,
                    character: playSession.character,
                    playerPosition: position,
                    resourceManager: context.resourceManager,
                    audioPlayer: audioPlayer,
                    playSession: playSession
                )
                let renderResources = MapSceneRenderResources(device: device)
                let runtime = MapSceneRuntime(
                    scene: scene,
                    world: world,
                    renderResources: renderResources
                )

                do {
                    try await runtime.load(progress: progress)

                    playSession.notifyMapLoaded()

                    stage = .map(.loaded(runtime))
                } catch {
                    logger.warning("Map scene failed to load: \(error)")
                }
            }
        case let packet as PACKET_ZC_NOTIFY_PLAYERMOVE:
            let moveData = MoveData(from: packet.moveData)
            mapScene?.onPlayerMoved(
                startTime: playSession.serverClock.time(forServerTick: packet.moveStartTime),
                startPosition: moveData.startPosition,
                endPosition: moveData.endPosition
            )
        case let packet as PACKET_ZC_STATUS:
            let basicStatus = CharacterBasicStatus(from: packet)
            playSession.playerStatus.update(from: basicStatus)
        case let packet as PACKET_ZC_SKILLINFO_LIST:
            playSession.skillList.replace(from: packet)
        case let packet as PACKET_ZC_SKILLINFO_UPDATE:
            playSession.skillList.update(from: packet)
        case let packet as PACKET_ZC_SKILLINFO_UPDATE2:
            playSession.skillList.update(from: packet)
        case let packet as PACKET_ZC_ADD_SKILL:
            playSession.skillList.add(from: packet)
        case let packet as PACKET_ZC_SKILLINFO_DELETE:
            playSession.skillList.delete(from: packet)
        case let packet as PACKET_ZC_SKILL_POSTDELAY:
            let cooldown = SkillCooldown(from: packet, startTime: .now)
            playSession.setSkillCooldown(cooldown)
        case let packet as PACKET_ZC_USESKILL_ACK:
            if let skillID = SkillID(rawValue: Int(packet.skillId)),
               let element = Element(rawValue: Int(packet.element)) {
                mapScene?.onMapObjectSkillCast(skillID: skillID, sourceObjectID: packet.srcId, element: element, castTime: .milliseconds(packet.delayTime))
            }
        case let packet as PACKET_ZC_WARPLIST:
            playSession.warpList = WarpList(from: packet)
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
            playSession.messageCenter.addMessage(for: packet)
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
            playSession.shortcutList.update(from: packet)
        case let packet as PACKET_ZC_PAR_CHANGE:
            if let sp = StatusProperty(rawValue: Int(packet.varID)) {
                playSession.playerStatus.update(property: sp, value: Int(packet.count))
                mapScene?.onPlayerStatusChanged(property: sp, value: Int(packet.count))
            }
        case let packet as PACKET_ZC_LONGPAR_CHANGE:
            if let sp = StatusProperty(rawValue: Int(packet.varID)) {
                playSession.playerStatus.update(property: sp, value: Int(packet.amount))
            }
        case let packet as PACKET_ZC_LONGLONGPAR_CHANGE:
            if let sp = StatusProperty(rawValue: Int(packet.varID)) {
                playSession.playerStatus.update(property: sp, value: Int(packet.amount))
            }
        case let packet as PACKET_ZC_STATUS_CHANGE:
            if let sp = StatusProperty(rawValue: Int(packet.statusID)) {
                playSession.playerStatus.update(property: sp, value: Int(packet.value))
            }
        case let packet as PACKET_ZC_COUPLESTATUS:
            if let sp = StatusProperty(rawValue: Int(packet.statusType)) {
                playSession.playerStatus.update(property: sp, value: Int(packet.defaultStatus), value2: Int(packet.plusStatus))
            }
        case let packet as PACKET_ZC_ATTACK_RANGE:
            playSession.playerStatus.update(from: packet)
        case let packet as PACKET_ZC_ATTACK_FAILURE_FOR_DISTANCE:
            mapScene?.onPlayerTooFarToAttack(targetID: packet.targetAID)
        case let packet as PACKET_ZC_ACTION_FAILURE:
            playSession.messageCenter.addMessage(for: packet)
        case let packet as PACKET_ZC_RECOVERY:
            if let statusProperty = StatusProperty(rawValue: Int(packet.type)) {
                switch statusProperty {
                case .hp:
                    let amount = Int(packet.amount)
                    let hp = min(playSession.playerStatus.hp + amount, playSession.playerStatus.maxHp)
                    playSession.playerStatus.hp = hp
                    mapScene?.onPlayerHealthPointsRecovered(recovered: amount, current: hp)
                case .sp:
                    let amount = Int(packet.amount)
                    let sp = min(playSession.playerStatus.sp + amount, playSession.playerStatus.maxSp)
                    playSession.playerStatus.sp = sp
                    mapScene?.onPlayerSpellPointsRecovered(recovered: amount, current: sp)
                default:
                    break
                }
            }
        case let packet as PACKET_ZC_NOTIFY_EXP:
            playSession.messageCenter.addMessage(for: packet)
        case let packet as PACKET_ZC_INVENTORY_START:
            // invType: 0 = inventory, 1 = cart, 2 = storage, 3 = guild storage
            switch packet.invType {
            case 2:
                playSession.storage = Storage(name: packet.name)
            default:
                break
            }
        case _ as PACKET_ZC_INVENTORY_END:
            break
        case let packet as packet_itemlist_normal:
            // invType: 0 = inventory, 1 = cart, 2 = storage, 3 = guild storage
            switch packet.invType {
            case 0:
                playSession.inventory.update(from: packet)
            case 2:
                playSession.storage?.update(from: packet)
            default:
                break
            }
        case let packet as packet_itemlist_equip:
            // invType: 0 = inventory, 1 = cart, 2 = storage, 3 = guild storage
            switch packet.invType {
            case 0:
                playSession.inventory.update(from: packet)
            case 2:
                playSession.storage?.update(from: packet)
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
            playSession.inventory.update(from: packet)
            playSession.messageCenter.addMessage(for: packet)
        case let packet as PACKET_ZC_USE_ITEM_ACK:
            playSession.inventory.update(from: packet)
        case let packet as PACKET_ZC_REQ_WEAR_EQUIP_ACK:
            playSession.inventory.update(from: packet)
            if let item = playSession.inventory.items[Int(packet.index)] {
                playSession.messageCenter.addMessage(for: packet, itemID: item.itemID)
            }
        case let packet as PACKET_ZC_REQ_TAKEOFF_EQUIP_ACK:
            playSession.inventory.update(from: packet)
            if let item = playSession.inventory.items[Int(packet.index)] {
                playSession.messageCenter.addMessage(for: packet, itemID: item.itemID)
            }
        case let packet as PACKET_ZC_ITEM_THROW_ACK:
            playSession.inventory.update(from: packet)
        case let packet as PACKET_ZC_EQUIP_ARROW:
            playSession.inventory.update(from: packet)
        case let packet as PACKET_ZC_DELETE_ITEM_FROM_BODY:
            playSession.inventory.update(from: packet)
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
                startTime: playSession.serverClock.time(forServerTick: packet.moveStartTime),
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
            playSession.messageCenter.addMessage(for: objectAction, account: playSession.account)
        case let packet as PACKET_ZC_HP_INFO:
            mapScene?.onMapObjectHealthUpdated(objectID: packet.GID, hp: Int(packet.HP), maxHp: Int(packet.maxHP))
        case let packet as PACKET_ZC_MSG_STATE_CHANGE:
            if packet.AID == playSession.account.accountID {
                if packet.state != 0 {
                    let statusChange = StatusChange(statusID: Int(packet.index), startTime: .now, duration: nil)
                    playSession.setStatusChange(statusChange)
                } else {
                    playSession.removeStatusChange(statusID: Int(packet.index))
                }
            }
        case let packet as PACKET_ZC_MSG_STATE_CHANGE3:
            if packet.AID == playSession.account.accountID {
                switch OfficialStatusChangeID(rawValue: Int(packet.index)) {
                case .efst_postdelay, .efst_groundmagic:
                    if packet.remain > 0 {
                        playSession.setGlobalSkillCooldown(startTime: .now, duration: .milliseconds(packet.remain))
                    }
                default:
                    break
                }

                if packet.state != 0 {
                    let statusChange = StatusChange(from: packet, startTime: .now)
                    playSession.setStatusChange(statusChange)
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
            if playSession.dialog?.npcID == packet.NpcID {
                playSession.dialog?.update(from: packet)
            } else {
                playSession.dialog = NPCDialog(from: packet)
            }
        case let packet as PACKET_ZC_WAIT_DIALOG:
            playSession.dialog?.update(from: packet)
        case let packet as PACKET_ZC_CLOSE_DIALOG:
            playSession.dialog?.update(from: packet)
        case let packet as PACKET_ZC_CLEAR_DIALOG:
            if playSession.dialog?.npcID == packet.GID {
                playSession.dialog = nil
            }
        case let packet as PACKET_ZC_MENU_LIST:
            playSession.dialog?.update(from: packet)
        case let packet as PACKET_ZC_OPEN_EDITDLG:
            playSession.dialog?.update(from: packet)
        case let packet as PACKET_ZC_OPEN_EDITDLGSTR:
            playSession.dialog?.update(from: packet)
        case _ as PACKET_ZC_SHOW_IMAGE:
            break
        case _ as PACKET_ZC_COMPASS:
            break
        case let packet as PACKET_ZC_SELECT_DEALTYPE:
            playSession.dealSelectionNPCID = packet.npcId
        case let packet as PACKET_ZC_PC_PURCHASE_ITEMLIST:
            playSession.npcShop = NPCShop(from: packet)
        case let packet as PACKET_ZC_PC_SELL_ITEMLIST:
            playSession.npcShop = NPCShop(from: packet)
        case let packet as PACKET_ZC_PC_PURCHASE_RESULT:
            playSession.npcShop = nil
            playSession.messageCenter.addMessage(for: packet)
        case let packet as PACKET_ZC_PC_SELL_RESULT:
            playSession.npcShop = nil
            playSession.messageCenter.addMessage(for: packet)
        case let packet as PACKET_ZC_NOTIFY_STOREITEM_COUNTINFO:
            playSession.storage?.update(from: packet)
        case let packet as PACKET_ZC_ADD_ITEM_TO_STORE:
            playSession.storage?.update(from: packet)
        case let packet as PACKET_ZC_DELETE_ITEM_FROM_STORE:
            playSession.storage?.update(from: packet)
        case _ as PACKET_ZC_CLOSE_STORE:
            playSession.storage = nil
        case let packet as PACKET_ZC_NOTIFY_CHAT:
            let message = ChatMessage(from: packet)
            playSession.messageCenter.add(message)
        case let packet as PACKET_ZC_WHISPER:
            let message = ChatMessage(from: packet)
            playSession.messageCenter.add(message)
        case let packet as PACKET_ZC_NOTIFY_PLAYERCHAT:
            let message = ChatMessage(from: packet)
            playSession.messageCenter.add(message)
        case let packet as PACKET_ZC_NPC_CHAT:
            let message = ChatMessage(from: packet)
            playSession.messageCenter.add(message)
        case let packet as PACKET_ZC_NOTIFY_CHAT_PARTY:
            let message = ChatMessage(from: packet)
            playSession.messageCenter.add(message)
        case let packet as PACKET_ZC_GUILD_CHAT:
            let message = ChatMessage(from: packet)
            playSession.messageCenter.add(message)
        case let packet as PACKET_ZC_NOTIFY_CLAN_CHAT:
            let message = ChatMessage(from: packet)
            playSession.messageCenter.add(message)
        case _ as PACKET_ZC_ALL_ACH_LIST:
            break
        case _ as PACKET_ZC_ACH_UPDATE:
            break
        case let packet as PACKET_ZC_NOTIFY_TIME:
            if let requestTime = playSession.serverTimeRequestTime {
                let now = ContinuousClock.now
                playSession.serverClock.synchronize(serverTick: packet.time, receiveTime: now, roundTripTime: requestTime.duration(to: now))
                playSession.serverTimeRequestTime = nil
            }
        case let packet as PACKET_SC_NOTIFY_BAN:
            let message = BannedMessage(from: packet)
            let localizedMessage = context.messageStringTable.localizedMessageString(forID: message.messageID)
            let errorMessage = GameSession.ErrorMessage(content: localizedMessage)
            errorMessages.append(errorMessage)
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

    // MARK: - Chat

    func sendMessage(_ message: String) {
        guard let playSession, let mapClient = playSession.mapClient else {
            return
        }

        if message.hasPrefix("%") {
//            PACKET_CZ_REQUEST_CHAT_PARTY
        } else if message.hasPrefix("$") {
//            PACKET_CZ_GUILD_CHAT
        } else if message.hasPrefix("/cl") {
//            PACKET_CZ_CLAN_CHAT
        } else if message.hasPrefix("/") {
            performSlashCommand(message)
        } else {
            let packet = PacketFactory.CZ_REQUEST_CHAT(message: "\(playSession.character.name) : \(message)")
            mapClient.sendPacket(packet)
        }
    }

    private func performSlashCommand(_ message: String) {
        guard let slashCommand = SlashCommand(message: message) else {
            playSession?.messageCenter.addUnknownSlashCommandMessage()
            return
        }

        switch slashCommand {
        case .where:
            if let mapScene {
                let mapName = mapScene.mapName.replacingOccurrences(of: ".rsw", with: "")
                let localizedMapName = context.mapInfoTable.localizedMapName(forMapName: mapName) ?? mapName
                playSession?.messageCenter.addLocationMessage(mapName: mapName, localizedMapName: localizedMapName, position: mapScene.player.gridPosition)
            }
        case .sit, .stand:
            mapScene?.toggleSit()
        case .help:
            playSession?.messageCenter.addSlashCommandHelpMessages()
        }
    }

    // MARK: - Shortcut

    func useShortcut(_ shortcut: Shortcut) {
        guard let playSession else {
            return
        }

        switch shortcut {
        case .empty:
            break
        case .item(let itemID):
            if let item = playSession.inventory.items.values.first(where: { $0.itemID == itemID }) {
                playSession.useItem(at: item.index)
            }
        case .skill(let skillID, let level):
            if let skill = playSession.skillList.skills[skillID] {
                mapScene?.useSkill(skill, level: level)
            }
        }
    }
}

// MARK: - Character Sprite

extension GameSession {
    func characterAnimation(forSlot slot: Int) async -> SpriteAnimation? {
        guard let character = characters.first(where: { $0.charNum == slot }) else {
            return nil
        }
        return await characterAnimation(for: character)
    }

    func characterAnimation(for character: CharacterInfo, direction: SpriteDirection = .south) async -> SpriteAnimation? {
        do {
            let configuration = ComposedSprite.Configuration(character: character)
            let composedSprite = try await ComposedSprite(
                configuration: configuration,
                resourceManager: context.resourceManager
            )

            let renderer = SpriteAnimationRenderer()
            let animation = await renderer.render(
                composedSprite: composedSprite,
                actionType: .idle,
                direction: direction,
                rendersShadow: false
            )
            return animation
        } catch {
            logger.warning("\(error)")
            return nil
        }
    }
}
