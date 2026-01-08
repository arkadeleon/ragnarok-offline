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
        self.messageStringTable = MessageStringTable()
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

    // Send login packet
    func login(username: String, password: String) {
        startLoginClient()

        guard let loginClient else {
            return
        }

        self.username = username

        // See `logclif_parse_reqauth_raw`
        var packet = PACKET_CA_LOGIN()
        packet.packetType = HEADER_CA_LOGIN
        packet.version = 0
        packet.username = username
        packet.password = password
        packet.clienttype = 0
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

            // Start keepalive after successful login
            startLoginKeepalive()
        case let packet as PACKET_AC_REFUSE_LOGIN:
            let message = LoginRefusedMessage(from: packet)
            if let localizedMessage = messageStringTable.localizedMessageString(forID: message.messageID) {
                let localizedMessage = localizedMessage.replacingOccurrences(of: "%s", with: message.unblockTime)
                let errorMessage = GameSession.ErrorMessage(content: localizedMessage)
                errorMessages.append(errorMessage)
            }
        case let packet as PACKET_SC_NOTIFY_BAN:
            let message = BannedMessage(from: packet)
            if let localizedMessage = messageStringTable.localizedMessageString(forID: message.messageID) {
                let errorMessage = GameSession.ErrorMessage(content: localizedMessage)
                errorMessages.append(errorMessage)
            }
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
            while !Task.isCancelled {
                try? await Task.sleep(for: .seconds(10))

                guard !Task.isCancelled else {
                    break
                }

                // See `logclif_parse_keepalive`
                var packet = PACKET_CA_CONNECT_INFO_CHANGED()
                packet.packetType = HEADER_CA_CONNECT_INFO_CHANGED
                packet.name = username ?? ""
                loginClient.sendPacket(packet)
            }
        }
    }

    // MARK: - Char Client

    func selectCharServer(_ charServer: CharServerInfo) {
        // Stop and disconnect login client before starting char client
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

        // See `chclif_parse_charselect`
        var packet = PACKET_CH_SELECT_CHAR()
        packet.packetType = HEADER_CH_SELECT_CHAR
        packet.slot = UInt8(slot)
        charClient.sendPacket(packet)
    }

    /// Create character.
    ///
    /// Send ``PACKET_CH_MAKE_CHAR``
    func createCharacter(_ character: CharacterInfo) {
        guard let charClient else {
            return
        }

        // See `chclif_parse_createnewchar`
        var packet = PACKET_CH_MAKE_CHAR()
        packet.packetType = HEADER_CH_MAKE_CHAR
        packet.name = character.name
        packet.slot = UInt8(character.charNum)
        packet.hair_color = UInt16(character.headPalette)
        packet.hair_style = UInt16(character.head)
        packet.job = UInt32(character.job)
        packet.sex = UInt8(character.sex)
        charClient.sendPacket(packet)
    }

    /// Delete character.
    ///
    /// Send ``PACKET_CH_DELETE_CHAR3``
    func deleteCharacter(charID: UInt32) {
        guard let charClient else {
            return
        }

        // See `chclif_parse_char_delete2_accept`
        var packet = PACKET_CH_DELETE_CHAR3()
        packet.packetType = HEADER_CH_DELETE_CHAR3
        packet.CID = charID
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

        // Send initial enter packet and receive accountID
        // See `chclif_parse_reqtoconnect`
        var packet = PACKET_CH_ENTER()
        packet.packetType = HEADER_CH_ENTER
        packet.accountID = account.accountID
        packet.loginID1 = account.loginID1
        packet.loginID2 = account.loginID2
        packet.clientType = account.langType
        packet.sex = UInt8(account.sex)
        client.sendPacket(packet)

        // Receive accountID (4 bytes) and update account
        client.receiveDataAndPacket(count: 4) { [weak self] data in
            let accountID = data.withUnsafeBytes({ $0.load(as: UInt32.self) })
            Task { @MainActor in
                self?.account?.update(accountID: accountID)
            }
        }

        // Start keepalive timer
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

                // Stop and disconnect char client before starting map session
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
            if let localizedMessage = messageStringTable.localizedMessageString(forID: message.messageID) {
                let errorMessage = GameSession.ErrorMessage(content: localizedMessage)
                errorMessages.append(errorMessage)
            }
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
            while !Task.isCancelled {
                try? await Task.sleep(for: .seconds(12))

                guard !Task.isCancelled else {
                    break
                }

                // See `chclif_parse_keepalive`
                var packet = PACKET_PING()
                packet.packetType = HEADER_PING
                packet.AID = account.accountID
                charClient.sendPacket(packet)
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
                handleMapPacket(packet)
            }
        }

        client.connect()

        self.mapClient = client

        // Send initial enter packet
        // See `clif_parse_LoadEndAck`
        var packet = PACKET_CZ_ENTER()
        packet.accountID = account.accountID
        packet.charID = character.charID
        packet.loginID1 = account.loginID1
        packet.clientTime = UInt32(Date.now.timeIntervalSince1970)
        packet.sex = UInt8(account.sex)
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

        // Start keepalive timer
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
            while !Task.isCancelled {
                try? await Task.sleep(for: .seconds(10))

                guard !Task.isCancelled else {
                    break
                }

                // See `clif_keepalive`
                var packet = PACKET_CZ_REQUEST_TIME()
                packet.clientTime = UInt32(Date.now.timeIntervalSince(startTime))
                mapClient.sendPacket(packet)
            }
        }
    }

    private func handleMapPacket(_ packet: any DecodablePacket) {
        switch packet {
        case _ as PACKET_ZC_ACCEPT_ENTER:
            break
        case let packet as PACKET_ZC_RESTART_ACK:
            if packet.type == 1 {
                // Stop and disconnect map client
                mapKeepaliveTask?.cancel()
                mapKeepaliveTask = nil

                mapClient?.disconnect()
                mapClient = nil

                phase = .login(.characterSelect(characters))
            }
        case let packet as PACKET_ZC_ACK_REQ_DISCONNECT:
            if packet.result == 0 {
                // Stop and disconnect map client
                mapKeepaliveTask?.cancel()
                mapKeepaliveTask = nil

                mapClient?.disconnect()
                mapClient = nil

                phase = .login(.characterSelect(characters))
            }
        case let packet as PACKET_ZC_AID:
            account?.update(accountID: packet.accountID)
        case _ as PACKET_ZC_PING_LIVE:
            var packet = PACKET_CZ_PING_LIVE()
            packet.packetType = HEADER_CZ_PING_LIVE
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
        case _ as PACKET_ZC_ITEM_PICKUP_ACK:
            break
        case _ as PACKET_ZC_ITEM_THROW_ACK:
            break
        case let packet as PACKET_ZC_USE_ITEM_ACK:
            let item = UsedItem(from: packet)
            inventory.updateItem(at: item.index, amount: item.amount)
        case _ as PACKET_ZC_REQ_WEAR_EQUIP_ACK:
            break
        case _ as PACKET_ZC_REQ_TAKEOFF_EQUIP_ACK:
            break
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
        case _ as PACKET_ZC_NOTIFY_CHAT:
            break
        case _ as PACKET_ZC_WHISPER:
            break
        case _ as PACKET_ZC_NOTIFY_PLAYERCHAT:
            break
        case _ as PACKET_ZC_NPC_CHAT:
            break
        case _ as PACKET_ZC_NOTIFY_CHAT_PARTY:
            break
        case _ as PACKET_ZC_GUILD_CHAT:
            break
        case _ as PACKET_ZC_NOTIFY_CLAN_CHAT:
            break
        case _ as PACKET_ZC_ALL_ACH_LIST:
            break
        case _ as PACKET_ZC_ACH_UPDATE:
            break
        case let packet as PACKET_SC_NOTIFY_BAN:
            let message = BannedMessage(from: packet)
            if let localizedMessage = messageStringTable.localizedMessageString(forID: message.messageID) {
                let errorMessage = GameSession.ErrorMessage(content: localizedMessage)
                errorMessages.append(errorMessage)
            }
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

        var packet = PACKET_CZ_NOTIFY_ACTORINIT()
        packet.packetType = HEADER_CZ_NOTIFY_ACTORINIT
        mapClient.sendPacket(packet)
    }

    func returnToLastSavePoint() {
        guard let mapClient else {
            return
        }

        var packet = PACKET_CZ_RESTART()
        packet.type = 0
        mapClient.sendPacket(packet)
    }

    func returnToCharacterSelect() {
        guard let mapClient else {
            return
        }

        var packet = PACKET_CZ_RESTART()
        packet.type = 1
        mapClient.sendPacket(packet)
    }

    func requestExit() {
        guard let mapClient else {
            return
        }

        var packet = PACKET_CZ_REQUEST_QUIT()
        packet.packetType = HEADER_CZ_REQUEST_QUIT
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

        var packet = PACKET_CZ_REQUEST_MOVE()
        packet.x = Int16(position.x)
        packet.y = Int16(position.y)
        mapClient.sendPacket(packet)
    }

    /// Request action on target.
    ///
    /// Send ``PACKET_CZ_REQUEST_ACT``
    func requestAction(_ actionType: DamageType, onTarget targetID: UInt32 = 0) {
        guard let mapClient else {
            return
        }

        var packet = PACKET_CZ_REQUEST_ACT()
        packet.targetID = targetID
        packet.action = UInt8(actionType.rawValue)
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

        var packet = PACKET_CZ_CHANGE_DIRECTION()
        packet.headDirection = headDirection
        packet.direction = direction
        mapClient.sendPacket(packet)
    }

    func incrementStatusProperty(_ sp: StatusProperty, by amount: Int) {
        guard let mapClient else {
            return
        }

        switch sp {
        case .str, .agi, .vit, .int, .dex, .luk:
            var packet = PACKET_CZ_STATUS_CHANGE()
            packet.statusID = Int16(sp.rawValue)
            packet.amount = Int8(amount)
            mapClient.sendPacket(packet)
        case .pow, .sta, .wis, .spl, .con, .crt:
            var packet = PACKET_CZ_ADVANCED_STATUS_CHANGE()
            packet.packetType = HEADER_CZ_ADVANCED_STATUS_CHANGE
            packet.type = Int16(sp.rawValue)
            packet.amount = Int16(amount)
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
            var packet = PACKET_CZ_REQUEST_CHAT()
            packet.message = "\(character.name) : \(message)"
            mapClient.sendPacket(packet)
        }
    }

    // MARK: - Item

    // See `clif_parse_TakeItem`
    func pickUpItem(objectID: UInt32) {
        guard let mapClient else {
            return
        }

        var packet = PACKET_CZ_ITEM_PICKUP()
        packet.objectID = objectID
        mapClient.sendPacket(packet)
    }

    // See `clif_parse_DropItem`
    func throwItem(at index: Int, amount: Int) {
        guard let mapClient else {
            return
        }

        var packet = PACKET_CZ_ITEM_THROW()
        packet.index = UInt16(index)
        packet.amount = Int16(amount)
        mapClient.sendPacket(packet)
    }

    // See `clif_parse_UseItem`
    func useItem(at index: Int) {
        guard let mapClient, let accountID = account?.accountID else {
            return
        }

        var packet = PACKET_CZ_USE_ITEM()
        packet.index = UInt16(index)
        packet.accountID = accountID
        mapClient.sendPacket(packet)
    }

    // See `clif_parse_EquipItem`
    func equipItem(at index: Int, location: EquipPositions) {
        guard let mapClient else {
            return
        }

        var packet = PACKET_CZ_REQ_WEAR_EQUIP()
        packet.packetType = HEADER_CZ_REQ_WEAR_EQUIP
        packet.index = UInt16(index)
        packet.position = UInt32(location.rawValue)
        mapClient.sendPacket(packet)
    }

    // See `clif_parse_UnequipItem`
    func unequipItem(at index: Int) {
        guard let mapClient else {
            return
        }

        var packet = PACKET_CZ_REQ_TAKEOFF_EQUIP()
        packet.index = UInt16(index)
        mapClient.sendPacket(packet)
    }

    // MARK: - NPC

    func talkToNPC(npcID: UInt32) {
        guard let mapClient else {
            return
        }

        // See `clif_parse_NpcClicked`
        var packet = PACKET_CZ_CONTACTNPC()
        packet.packetType = HEADER_CZ_CONTACTNPC
        packet.AID = npcID
        packet.type = 1
        mapClient.sendPacket(packet)
    }

    func requestNextMessage() {
        guard let mapClient, let dialog else {
            return
        }

        // See `clif_parse_NpcNextClicked`
        var packet = PACKET_CZ_REQ_NEXT_SCRIPT()
        packet.packetType = HEADER_CZ_REQ_NEXT_SCRIPT
        packet.npcID = dialog.npcID
        mapClient.sendPacket(packet)

        dialog.setNeedsClear()
        dialog.action = nil
    }

    func closeDialog() {
        guard let mapClient, let dialog else {
            return
        }

        self.dialog = nil

        // See `clif_parse_NpcCloseClicked`
        var packet = PACKET_CZ_CLOSE_DIALOG()
        packet.packetType = HEADER_CZ_CLOSE_DIALOG
        packet.GID = dialog.npcID
        mapClient.sendPacket(packet)
    }

    func selectMenu(_ select: UInt8) {
        guard let mapClient, let dialog else {
            return
        }

        dialog.menu = nil

        // See `clif_parse_NpcSelectMenu`
        var packet = PACKET_CZ_CHOOSE_MENU()
        packet.packetType = HEADER_CZ_CHOOSE_MENU
        packet.npcID = dialog.npcID
        packet.select = select
        mapClient.sendPacket(packet)
    }

    func cancelMenu() {
        guard let mapClient, let dialog else {
            return
        }

        self.dialog = nil

        // See `clif_parse_NpcSelectMenu`
        var packet = PACKET_CZ_CHOOSE_MENU()
        packet.packetType = HEADER_CZ_CHOOSE_MENU
        packet.npcID = dialog.npcID
        packet.select = 255
        mapClient.sendPacket(packet)
    }

    func confirmInput(_ value: Int32) {
        guard let mapClient, let dialog else {
            return
        }

        // See `clif_parse_NpcAmountInput`
        var packet = PACKET_CZ_INPUT_EDITDLG()
        packet.packetType = HEADER_CZ_INPUT_EDITDLG
        packet.GID = dialog.npcID
        packet.value = value
        mapClient.sendPacket(packet)

        dialog.input = nil
    }

    func confirmInput(_ value: String) {
        guard let mapClient, let dialog else {
            return
        }

        // See `clif_parse_NpcStringInput`
        var packet = PACKET_CZ_INPUT_EDITDLGSTR()
        packet.packetType = HEADER_CZ_INPUT_EDITDLGSTR
        packet.packetLength = Int16(2 + 2 + 4 + value.utf8.count)
        packet.GID = Int32(dialog.npcID)
        packet.value = value
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
