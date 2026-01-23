//
//  GameSession.swift
//  RagnarokGame
//
//  Created by Leon Li on 2024/9/5.
//

import Foundation
import Network
import Observation
import RagnarokConstants
import RagnarokLocalization
import RagnarokModels
import RagnarokNetwork
import RagnarokPackets
import RagnarokReality
import RagnarokResources
import RagnarokSprite

@MainActor
@Observable
final public class GameSession {
    public let windowID = "Game"
    public let immersiveSpaceID = "Game"

    let resourceManager: ResourceManager

    let itemInfoTable: ItemInfoTable
    let messageStringTable: MessageStringTable

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

    public enum Phase {
        case login(GameSession.LoginPhase)
        case map(GameSession.MapPhase)
    }

    public enum LoginPhase {
        case login
        case charServerList(_ charServers: [CharServerInfo])
        case characterSelect(_ characters: [CharacterInfo])
        case characterMake(_ slot: Int)
    }

    public enum MapPhase {
        case loading(_ progress: Progress)
        case loaded(_ scene: MapScene)
    }

    public private(set) var phase: GameSession.Phase = .login(.login)

    struct ErrorMessage: Identifiable {
        let id = UUID()
        let content: String
    }

    private var username: String?

    private(set) var errorMessages: [GameSession.ErrorMessage] = []
    private(set) var account: AccountInfo?
    private(set) var characters: [CharacterInfo] = []
    private(set) var character: CharacterInfo?

    var playerStatus = CharacterStatus()
    var inventory = Inventory()
    let messageCenter: MessageCenter
    var packetMessages: [PacketMessage] = []
    var dialog: NPCDialog?

    @ObservationIgnored var loginClient: Client?
    @ObservationIgnored var loginKeepaliveTask: Task<Void, Never>?

    @ObservationIgnored var charClient: Client?
    @ObservationIgnored var charKeepaliveTask: Task<Void, Never>?

    @ObservationIgnored var mapClient: Client?
    @ObservationIgnored var mapKeepaliveTask: Task<Void, Never>?
    @ObservationIgnored var currentMapServer: MapServerInfo?

    public var mapScene: MapScene? {
        if case .map(let mapPhase) = phase, case .loaded(let scene) = mapPhase {
            scene
        } else {
            nil
        }
    }

    public init(resourceManager: ResourceManager) {
        self.resourceManager = resourceManager

        self.itemInfoTable = ItemInfoTable()
        self.messageStringTable = MessageStringTable()

        self.messageCenter = MessageCenter(
            itemInfoTable: itemInfoTable,
            messageStringTable: messageStringTable
        )
    }

    // MARK: - Public

    public func test(_ configuration: GameSession.Configuration) async -> NWError? {
        await withCheckedContinuation { continuation in
            let tcp = NWProtocolTCP.Options()
            tcp.connectionTimeout = 10

            let connection = NWConnection(
                host: NWEndpoint.Host(configuration.serverAddress),
                port: NWEndpoint.Port(rawValue: configuration.serverPort)!,
                using: NWParameters(tls: nil, tcp: tcp)
            )

            connection.stateUpdateHandler = { state in
                logger.info("Game session testing connection state changed: \(String(describing: state))")

                switch state {
                case .ready:
                    continuation.resume(returning: nil)
                    connection.cancel()
                case .waiting(let error), .failed(let error):
                    continuation.resume(returning: error)
                    connection.cancel()
                default:
                    break
                }
            }

            connection.start(queue: .global())
        }
    }

    public func start(_ configuration: GameSession.Configuration) {
        state = .running(configuration: configuration)
    }

    public func stop() {
        state = .stopped
    }

    // MARK: - Internal

    func removeErrorMessage(_ errorMessage: GameSession.ErrorMessage) {
        if let index = errorMessages.firstIndex(where: { $0.id == errorMessage.id }) {
            errorMessages.remove(at: index)
        }
    }

    func stopAllSessions() {
        mapKeepaliveTask?.cancel()
        mapKeepaliveTask = nil

        mapClient?.disconnect()
        mapClient = nil

        charKeepaliveTask?.cancel()
        charKeepaliveTask = nil

        charClient?.disconnect()
        charClient = nil

        loginKeepaliveTask?.cancel()
        loginKeepaliveTask = nil

        loginClient?.disconnect()
        loginClient = nil

        phase = .login(.login)
    }

    // MARK: - Login Client

    func login(username: String, password: String) {
        startLoginClient()

        guard let loginClient else {
            return
        }

        self.username = username

        let packet = PacketFactory.CA_LOGIN(username: username, password: password)
        loginClient.sendPacket(packet)

        loginClient.receivePacket()
    }

    private func startLoginClient() {
        guard case .running(let configuration) = state else {
            return
        }

        let client = Client(
            name: "Login",
            address: configuration.serverAddress,
            port: configuration.serverPort
        )

        // Handle error stream
        Task {
            for await error in client.errorStream {
                let errorMessage = GameSession.ErrorMessage(content: error.localizedDescription)
                errorMessages.append(errorMessage)
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

    private func handleLoginPacket(_ packet: any DecodablePacket) {
        switch packet {
        case let packet as PACKET_AC_ACCEPT_LOGIN:
            let account = AccountInfo(from: packet)
            let charServers = packet.char_servers.map(CharServerInfo.init(from:))

            self.account = account

            if charServers.count == 1 {
                selectCharServer(charServers[0])
            } else if charServers.count > 1 {
                phase = .login(.charServerList(charServers))
            }

            startLoginKeepalive()
        case let packet as PACKET_AC_REFUSE_LOGIN:
            let message = LoginRefusedMessage(from: packet)
            let localizedMessage = messageStringTable.localizedMessageString(forID: message.messageID, arguments: message.unblockTime)
            let errorMessage = GameSession.ErrorMessage(content: localizedMessage)
            errorMessages.append(errorMessage)
        case let packet as PACKET_SC_NOTIFY_BAN:
            let message = BannedMessage(from: packet)
            let localizedMessage = messageStringTable.localizedMessageString(forID: message.messageID)
            let errorMessage = GameSession.ErrorMessage(content: localizedMessage)
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
        loginKeepaliveTask?.cancel()
        loginKeepaliveTask = nil

        loginClient?.disconnect()
        loginClient = nil

        startCharClient(charServer)
    }

    func makeCharacter(slot: Int) {
        phase = .login(.characterMake(slot))
    }

    func cancelMakeCharacter() {
        phase = .login(.characterSelect(characters))
    }

    /// Select character.
    ///
    /// Send ``PACKET_CH_SELECT_CHAR``
    func selectCharacter(slot: Int) {
        guard let charClient else {
            return
        }

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
    /// Send ``PACKET_CH_DELETE_CHAR3``
    func deleteCharacter(charID: UInt32) {
        guard let charClient else {
            return
        }

        let packet = PacketFactory.CH_DELETE_CHAR3(charID: charID)
        charClient.sendPacket(packet)
    }

    private func startCharClient(_ charServer: CharServerInfo) {
        guard let account else {
            return
        }

        let client = Client(
            name: "Char",
            address: charServer.ip,
            port: charServer.port
        )

        // Handle error stream
        Task {
            for await error in client.errorStream {
                let errorMessage = GameSession.ErrorMessage(content: error.localizedDescription)
                errorMessages.append(errorMessage)
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

    private func handleCharPacket(_ packet: any DecodablePacket) {
        switch packet {
        case let packet as PACKET_HC_ACCEPT_ENTER:
            let characters = packet.characters.map(CharacterInfo.init(from:))
            self.characters = characters
            phase = .login(.characterSelect(characters))
        case _ as PACKET_HC_REFUSE_ENTER:
            break
        case let packet as PACKET_HC_NOTIFY_ZONESVR:
            if let character = characters.first(where: { $0.charID == packet.CID }) {
                self.character = character
                let mapServer = MapServerInfo(from: packet)

                charKeepaliveTask?.cancel()
                charKeepaliveTask = nil

                charClient?.disconnect()
                charClient = nil

                startMapClient(character: character, mapServer: mapServer)
            }
        case _ as PACKET_HC_NOTIFY_ACCESSIBLE_MAPNAME:
            break
        case let packet as PACKET_HC_ACCEPT_MAKECHAR:
            let character = CharacterInfo(from: packet.character)
            characters.append(character)
            phase = .login(.characterSelect(characters))
        case _ as PACKET_HC_REFUSE_MAKECHAR:
            break
        case _ as PACKET_HC_ACCEPT_DELETECHAR:
            break
        case _ as PACKET_HC_REFUSE_DELETECHAR:
            break
        case let packet as PACKET_HC_DELETE_CHAR3:
            if packet.result == 1 {
                // Delete character accepted
            } else {
                // Delete character refused
            }
        case _ as PACKET_HC_DELETE_CHAR3_CANCEL:
            break
        case _ as PACKET_HC_DELETE_CHAR3_RESERVED:
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
            let message = BannedMessage(from: packet)
            let localizedMessage = messageStringTable.localizedMessageString(forID: message.messageID)
            let errorMessage = GameSession.ErrorMessage(content: localizedMessage)
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
            return
        }

        playerStatus = CharacterStatus(from: character)

        self.currentMapServer = mapServer

        let client = Client(
            name: "Map",
            address: mapServer.ip,
            port: mapServer.port
        )

        // Handle error stream
        Task {
            for await error in client.errorStream {
                let errorMessage = GameSession.ErrorMessage(content: error.localizedDescription)
                errorMessages.append(errorMessage)
            }
        }

        // Handle packet stream
        Task {
            for await packet in client.packetStream {
                let packetMessage = PacketMessage(packet: packet, direction: .incoming)
                packetMessages.append(packetMessage)

                handleMapPacket(packet)
            }
        }

        // Handle sent packet stream
        Task {
            for await packet in client.sentPacketStream {
                let message = PacketMessage(packet: packet, direction: .outgoing)
                packetMessages.append(message)
            }
        }

        client.connect()

        self.mapClient = client

        let packet = PacketFactory.CZ_ENTER(account: account, charID: character.charID)
        client.sendPacket(packet)

        if PACKET_VERSION < 20070521 {
            client.receiveDataAndPacket(count: 4) { [weak self] data in
                let accountID = data.withUnsafeBytes({ $0.load(as: UInt32.self) })
                Task { @MainActor in
                    self?.account?.update(accountID: accountID)
                }
            }
        } else {
            client.receivePacket()
        }

        startMapKeepalive()
    }

    /// Keep alive.
    ///
    /// Send ``PACKET_CZ_REQUEST_TIME`` every 10 seconds.
    private func startMapKeepalive() {
        guard let mapClient else {
            return
        }

        let startTime = Date.now

        mapKeepaliveTask = Task {
            do {
                while !Task.isCancelled {
                    try await Task.sleep(for: .seconds(10))

                    let packet = PacketFactory.CZ_REQUEST_TIME(clientTime: UInt32(Date.now.timeIntervalSince(startTime)))
                    mapClient.sendPacket(packet)
                }
            } catch {
                logger.warning("\(error)")
            }
        }
    }

    private func handleMapPacket(_ packet: any DecodablePacket) {
        switch packet {
        case _ as PACKET_ZC_ACCEPT_ENTER:
            break
        case let packet as PACKET_ZC_RESTART_ACK:
            if packet.type == 1 {
                mapKeepaliveTask?.cancel()
                mapKeepaliveTask = nil

                mapClient?.disconnect()
                mapClient = nil

                phase = .login(.characterSelect(characters))
            }
        case let packet as PACKET_ZC_ACK_REQ_DISCONNECT:
            if packet.result == 0 {
                mapKeepaliveTask?.cancel()
                mapKeepaliveTask = nil

                mapClient?.disconnect()
                mapClient = nil

                phase = .login(.characterSelect(characters))
            }
        case let packet as PACKET_ZC_AID:
            account?.update(accountID: packet.accountID)
        case _ as PACKET_ZC_PING_LIVE:
            let packet = PacketFactory.CZ_PING_LIVE()
            mapClient?.sendPacket(packet)
        case let packet as PACKET_ZC_NPCACK_MAPMOVE:
            if let mapScene {
                mapScene.unload()
            }

            let mapName = packet.mapName
            let position = SIMD2(x: Int(packet.xPos), y: Int(packet.yPos))

            let progress = Progress()
            phase = .map(.loading(progress))

            Task {
                guard let account, let character else {
                    return
                }

                let mapName = mapName.replacingOccurrences(of: ".gat", with: ".rsw")
                let world = try await resourceManager.world(mapName: mapName)

                let player = MapObject(account: account, character: character)

                let scene = MapScene(
                    mapName: mapName,
                    world: world,
                    player: player,
                    playerPosition: position,
                    resourceManager: resourceManager,
                    gameSession: self
                )

                await scene.load(progress: progress)

                phase = .map(.loaded(scene))
            }
        case let packet as PACKET_ZC_NOTIFY_PLAYERMOVE:
            let moveData = MoveData(from: packet.moveData)
            mapScene?.onPlayerMoved(startPosition: moveData.startPosition, endPosition: moveData.endPosition)
        case let packet as PACKET_ZC_STATUS:
            let basicStatus = CharacterBasicStatus(from: packet)
            playerStatus.update(from: basicStatus)
        case let packet as PACKET_ZC_PAR_CHANGE:
            if let sp = StatusProperty(rawValue: Int(packet.varID)) {
                playerStatus.update(property: sp, value: Int(packet.count))
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
        case _ as PACKET_ZC_ATTACK_RANGE:
            break
        case _ as PACKET_ZC_INVENTORY_START:
            break
        case _ as PACKET_ZC_INVENTORY_END:
            break
        case let packet as packet_itemlist_normal:
            let items = packet.list.map { InventoryItem(from: $0) }
            inventory.append(items: items)
        case let packet as packet_itemlist_equip:
            let items = packet.list.map { InventoryItem(from: $0) }
            inventory.append(items: items)
        case let packet as PACKET_ZC_ITEM_ENTRY:
            let item = MapItem(from: packet)
            let position = SIMD2(x: Int(packet.x), y: Int(packet.y))
            mapScene?.onItemSpawned(item: item, position: position)
        case let packet as packet_dropflooritem:
            let item = MapItem(from: packet)
            let position = SIMD2(x: Int(packet.xPos), y: Int(packet.yPos))
            mapScene?.onItemSpawned(item: item, position: position)
        case let packet as PACKET_ZC_ITEM_DISAPPEAR:
            mapScene?.onItemVanished(objectID: packet.itemAid)
        case let packet as PACKET_ZC_ITEM_PICKUP_ACK:
            messageCenter.addMessage(for: packet)
        case _ as PACKET_ZC_ITEM_THROW_ACK:
            break
        case let packet as PACKET_ZC_USE_ITEM_ACK:
            let item = UsedItem(from: packet)
            inventory.updateItem(at: item.index, amount: item.amount)
        case let packet as PACKET_ZC_REQ_WEAR_EQUIP_ACK:
            if let item = inventory.items[Int(packet.index)] {
                messageCenter.addMessage(for: packet, itemID: item.itemID)
            }
        case let packet as PACKET_ZC_REQ_TAKEOFF_EQUIP_ACK:
            if let item = inventory.items[Int(packet.index)] {
                messageCenter.addMessage(for: packet, itemID: item.itemID)
            }
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
            mapScene?.onMapObjectMoved(object: object, startPosition: moveData.startPosition, endPosition: moveData.endPosition)
        case let packet as PACKET_ZC_STOPMOVE:
            let objectID = packet.AID
            let position = SIMD2(x: Int(packet.xPos), y: Int(packet.yPos))
            logger.info("Object \(objectID) stopped at \(position)")
            mapScene?.onMapObjectStopped(objectID: objectID, position: position)
        case let packet as PACKET_ZC_NOTIFY_VANISH:
            let objectID = packet.gid
            logger.info("Object \(objectID) vanished")
            mapScene?.onMapObjectVanished(objectID: objectID)
        case _ as PACKET_ZC_CHANGE_DIRECTION:
            break
        case _ as PACKET_ZC_SPRITE_CHANGE:
            break
        case let packet as PACKET_ZC_STATE_CHANGE:
            let bodyState = StatusChangeOption1(rawValue: Int(packet.bodyState)) ?? .none
            let healthState = StatusChangeOption2(rawValue: Int(packet.healthState)) ?? .none
            let effectState = StatusChangeOption(rawValue: Int(packet.effectState)) ?? .nothing
            mapScene?.onMapObjectStateChanged(objectID: packet.AID, bodyState: bodyState, healthState: healthState, effectState: effectState)
        case let packet as PACKET_ZC_NOTIFY_ACT:
            let objectAction = MapObjectAction(from: packet)
            mapScene?.onMapObjectActionPerformed(objectAction: objectAction)
            messageCenter.addMessage(for: objectAction, account: account)
        case let packet as PACKET_ZC_SAY_DIALOG:
            if let dialog, dialog.npcID == packet.NpcID {
                dialog.clearIfNeeded()
                dialog.append(message: packet.message)
            } else {
                dialog = NPCDialog(npcID: packet.NpcID, message: packet.message)
            }
        case let packet as PACKET_ZC_WAIT_DIALOG:
            if let dialog, dialog.npcID == packet.NpcID {
                dialog.action = .next
            }
        case let packet as PACKET_ZC_CLOSE_DIALOG:
            if let dialog, dialog.npcID == packet.npcId {
                dialog.action = .close
                dialog.menu = nil
                dialog.input = nil
            }
        case let packet as PACKET_ZC_CLEAR_DIALOG:
            if let dialog, dialog.npcID == packet.GID {
                self.dialog = nil
            }
        case let packet as PACKET_ZC_MENU_LIST:
            if let dialog, dialog.npcID == packet.npcId {
                let menu = packet.menu.split(separator: ":").map(String.init)
                dialog.action = nil
                dialog.menu = menu
            }
        case let packet as PACKET_ZC_OPEN_EDITDLG:
            if let dialog, dialog.npcID == packet.npcId {
                dialog.action = nil
                dialog.input = .number
            }
        case let packet as PACKET_ZC_OPEN_EDITDLGSTR:
            if let dialog, dialog.npcID == packet.npcId {
                dialog.action = nil
                dialog.input = .text
            }
        case _ as PACKET_ZC_SHOW_IMAGE:
            break
        case _ as PACKET_ZC_COMPASS:
            break
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
        case let packet as PACKET_SC_NOTIFY_BAN:
            let message = BannedMessage(from: packet)
            let localizedMessage = messageStringTable.localizedMessageString(forID: message.messageID)
            let errorMessage = GameSession.ErrorMessage(content: localizedMessage)
            errorMessages.append(errorMessage)
        case _ as PACKET_ZC_FRIENDS_LIST:
            break
        case _ as PACKET_ZC_SHORTCUT_KEY_LIST:
            break
        case _ as PACKET_ZC_EXTEND_BODYITEM_SIZE:
            break
        case _ as PACKET_ZC_STATUS_CHANGE_ACK:
            break
        case _ as PACKET_ZC_NOTIFY_CARTITEM_COUNTINFO:
            break
        case _ as PACKET_ZC_USE_SKILL:
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

    // MARK: - Map Operations

    func notifyMapLoaded() {
        guard let mapClient else {
            return
        }

        let packet = PacketFactory.CZ_NOTIFY_ACTORINIT()
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
    func requestAction(_ actionType: DamageType, onTarget targetID: UInt32 = 0) {
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
    func changeDirection(headDirection: UInt16, direction: UInt8) {
        guard let mapClient else {
            return
        }

        let packet = PacketFactory.CZ_CHANGE_DIRECTION(headDirection: headDirection, direction: direction)
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

    // MARK: - Chat

    func sendMessage(_ message: String) {
        guard let mapClient, let character else {
            return
        }

        if message.hasPrefix("%") {
//            PACKET_CZ_REQUEST_CHAT_PARTY
        } else if message.hasPrefix("$") {
//            PACKET_CZ_GUILD_CHAT
        } else if message.hasPrefix("/cl") {
//            PACKET_CZ_CLAN_CHAT
        } else {
            let packet = PacketFactory.CZ_REQUEST_CHAT(message: "\(character.name) : \(message)")
            mapClient.sendPacket(packet)
        }
    }

    // MARK: - Item

    func pickUpItem(objectID: UInt32) {
        guard let mapClient else {
            return
        }

        let packet = PacketFactory.CZ_ITEM_PICKUP(objectID: objectID)
        mapClient.sendPacket(packet)
    }

    func throwItem(at index: Int, amount: Int) {
        guard let mapClient else {
            return
        }

        let packet = PacketFactory.CZ_ITEM_THROW(index: index, amount: amount)
        mapClient.sendPacket(packet)
    }

    func useItem(at index: Int) {
        guard let mapClient, let accountID = account?.accountID else {
            return
        }

        let packet = PacketFactory.CZ_USE_ITEM(index: index, accountID: accountID)
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

    // MARK: - NPC

    func talkToNPC(npcID: UInt32) {
        guard let mapClient else {
            return
        }

        let packet = PacketFactory.CZ_CONTACTNPC(npcID: npcID)
        mapClient.sendPacket(packet)
    }

    func requestNextMessage() {
        guard let mapClient, let dialog else {
            return
        }

        let packet = PacketFactory.CZ_REQ_NEXT_SCRIPT(npcID: dialog.npcID)
        mapClient.sendPacket(packet)

        dialog.setNeedsClear()
        dialog.action = nil
    }

    func closeDialog() {
        guard let mapClient, let dialog else {
            return
        }

        self.dialog = nil

        let packet = PacketFactory.CZ_CLOSE_DIALOG(npcID: dialog.npcID)
        mapClient.sendPacket(packet)
    }

    func selectMenu(_ select: UInt8) {
        guard let mapClient, let dialog else {
            return
        }

        dialog.menu = nil

        let packet = PacketFactory.CZ_CHOOSE_MENU(npcID: dialog.npcID, select: select)
        mapClient.sendPacket(packet)
    }

    func cancelMenu() {
        guard let mapClient, let dialog else {
            return
        }

        self.dialog = nil

        let packet = PacketFactory.CZ_CHOOSE_MENU(npcID: dialog.npcID, select: 255)
        mapClient.sendPacket(packet)
    }

    func confirmInput(_ value: Int32) {
        guard let mapClient, let dialog else {
            return
        }

        let packet = PacketFactory.CZ_INPUT_EDITDLG(npcID: dialog.npcID, value: value)
        mapClient.sendPacket(packet)

        dialog.input = nil
    }

    func confirmInput(_ value: String) {
        guard let mapClient, let dialog else {
            return
        }

        let packet = PacketFactory.CZ_INPUT_EDITDLGSTR(npcID: dialog.npcID, value: value)
        mapClient.sendPacket(packet)

        dialog.input = nil
    }
}

// MARK: - Character Sprite

extension GameSession {
    func characterAnimation(forSlot slot: Int) async -> SpriteRenderer.Animation? {
        guard 0..<characters.count ~= slot else {
            return nil
        }

        return await characterAnimation(for: characters[slot])
    }

    func characterAnimation(for character: CharacterInfo) async -> SpriteRenderer.Animation? {
        do {
            let configuration = ComposedSprite.Configuration(character: character)
            let composedSprite = try await ComposedSprite(
                configuration: configuration,
                resourceManager: resourceManager
            )

            let spriteRenderer = SpriteRenderer()
            let animation = await spriteRenderer.render(
                composedSprite: composedSprite,
                actionType: .idle,
                rendersShadow: false
            )
            return animation
        } catch {
            logger.warning("\(error)")
            return nil
        }
    }
}
