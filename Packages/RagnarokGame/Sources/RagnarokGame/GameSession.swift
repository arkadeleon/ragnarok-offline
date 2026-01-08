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

    @ObservationIgnored var charSession: CharSession?
    @ObservationIgnored var mapSession: MapSession?

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

    func selectCharServer(_ charServer: CharServerInfo) {
        // Stop and disconnect login client before starting char session
        loginKeepaliveTask?.cancel()
        loginKeepaliveTask = nil

        loginClient?.disconnect()
        loginClient = nil

        startCharSession(charServer)
    }

    func makeCharacter(slot: Int) {
        phase = .login(.characterMake(slot))
    }

    func cancelMakeCharacter() {
        phase = .login(.characterSelect(characters))
    }

    func stopAllSessions() {
        mapSession?.stop()
        mapSession = nil

        charSession?.stop()
        charSession = nil

        loginKeepaliveTask?.cancel()
        loginKeepaliveTask = nil

        loginClient?.disconnect()
        loginClient = nil

        phase = .login(.login)
    }

    // MARK: - NPC

    func requestNextMessage() {
        guard let mapSession, let dialog else {
            return
        }

        mapSession.requestNextMessage(npcID: dialog.npcID)

        dialog.setNeedsClear()
        dialog.action = nil
    }

    func closeDialog() {
        guard let mapSession, let dialog else {
            return
        }

        self.dialog = nil

        mapSession.closeDialog(npcID: dialog.npcID)
    }

    func selectMenu(_ select: UInt8) {
        guard let mapSession, let dialog else {
            return
        }

        dialog.menu = nil

        mapSession.selectMenu(npcID: dialog.npcID, select: select)
    }

    func cancelMenu() {
        guard let mapSession, let dialog else {
            return
        }

        self.dialog = nil

        mapSession.selectMenu(npcID: dialog.npcID, select: 255)
    }

    func confirmInput(_ value: Int32) {
        guard let mapSession, let dialog else {
            return
        }

        mapSession.inputNumber(npcID: dialog.npcID, value: value)

        dialog.input = nil
    }

    func confirmInput(_ value: String) {
        guard let mapSession, let dialog else {
            return
        }

        mapSession.inputText(npcID: dialog.npcID, value: value)

        dialog.input = nil
    }

    // MARK: - Login Client

    // Send login packet
    func login(username: String, password: String) {
        startLoginClient()

        self.username = username

        // See `logclif_parse_reqauth_raw`
        var packet = PACKET_CA_LOGIN()
        packet.packetType = HEADER_CA_LOGIN
        packet.version = 0
        packet.username = username
        packet.password = password
        packet.clienttype = 0
        loginClient?.sendPacket(packet)

        loginClient?.receivePacket()
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
            // See `logclif_auth_ok`
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
            // See `logclif_auth_failed`
            let message = LoginRefusedMessage(from: packet)
            if let localizedMessage = messageStringTable.localizedMessageString(forID: message.messageID) {
                let localizedMessage = localizedMessage.replacingOccurrences(of: "%s", with: message.unblockTime)
                let errorMessage = GameSession.ErrorMessage(content: localizedMessage)
                errorMessages.append(errorMessage)
            }
        case let packet as PACKET_SC_NOTIFY_BAN:
            // See `logclif_sent_auth_result`
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

    // MARK: - Char Session

    private func startCharSession(_ charServer: CharServerInfo) {
        guard let account else {
            return
        }

        let charSession = CharSession(account: account, charServer: charServer)

        Task {
            for await event in charSession.events {
                handleCharEvent(event)
            }
        }

        charSession.start()

        self.charSession = charSession
    }

    private func handleCharEvent(_ event: CharSession.Event) {
        switch event {
        case .charServerAccepted(let characters):
            self.characters = characters
            phase = .login(.characterSelect(characters))
        case .charServerRefused:
            break
        case .charServerNotifiedMapServer(let charID, let mapName, let mapServer):
            if let character = characters.first(where: { $0.charID == charID }) {
                self.character = character
                startMapSession(character: character, mapServer: mapServer)
            }
        case .charServerNotifiedAccessibleMaps(let accessibleMaps):
            break
        case .makeCharacterAccepted(let character):
            characters.append(character)
            phase = .login(.characterSelect(characters))
        case .makeCharacterRefused:
            break
        case .deleteCharacterAccepted:
            break
        case .deleteCharacterRefused:
            break
        case .deleteCharacterCancelled:
            break
        case .deleteCharacterReserved(let deletionDate):
            break
        case .authenticationBanned(let message):
            break
        case .errorOccurred(let error):
            break
        }
    }

    // MARK: - Map Session

    private func startMapSession(character: CharacterInfo, mapServer: MapServerInfo) {
        guard let account = charSession?.account else {
            return
        }

        playerStatus = CharacterStatus(from: character)

        let mapSession = MapSession(account: account, character: character, mapServer: mapServer)

        Task {
            for await event in mapSession.events {
                handleMapEvent(event)
            }
        }

        mapSession.start()

        self.mapSession = mapSession
    }

    private func handleMapEvent(_ event: MapSession.Event) {
        switch event {
        case .mapServerAccepted:
            break
        case .mapServerDisconnected:
            mapSession?.stop()
            mapSession = nil

            phase = .login(.characterSelect(characters))
        case .mapChanged(let mapName, let position):
            if let mapScene {
                mapScene.unload()
            }

            let progress = Progress()
            phase = .map(.loading(progress))

            Task {
                guard let mapSession, let account, let character else {
                    return
                }

                let mapName = mapName.replacingOccurrences(of: ".gat", with: ".rsw")
                let world = try await resourceManager.world(mapName: mapName)

                let player = MapObject(account: account, character: character)

                let scene = MapScene(
                    mapName: mapName,
                    mapSession: mapSession,
                    world: world,
                    player: player,
                    playerPosition: position,
                    resourceManager: resourceManager
                )

                await scene.load(progress: progress)

                phase = .map(.loaded(scene))
            }
        case .playerMoved(let startPosition, let endPosition):
            mapScene?.onPlayerMoved(startPosition: startPosition, endPosition: endPosition)
        case .playerStatusChanged(let status):
            playerStatus.update(from: status)
        case .playerStatusPropertyChanged(let property, let value):
            playerStatus.update(property: property, value: value)
        case .playerStatusPropertyChanged2(let property, let value, let value2):
            playerStatus.update(property: property, value: value, value2: value2)
        case .playerAttackRangeChanged(let value):
            break
        case .achievementListed:
            break
        case .achievementUpdated:
            break
        case .inventoryUpdatesBegan:
            break
        case .inventoryUpdatesEnded:
            break
        case .inventoryItemsAppended(let items):
            inventory.append(items: items)
        case .itemSpawned(let item, let position):
            mapScene?.onItemSpawned(item: item, position: position)
        case .itemVanished(let objectID):
            mapScene?.onItemVanished(objectID: objectID)
        case .itemPickedUp(let item):
            break
        case .itemThrown(let item):
            break
        case .itemUsed(let item, let accountID, let success):
            inventory.updateItem(at: item.index, amount: item.amount)
        case .itemEquipped(let item, let success):
            break
        case .itemUnequipped(let item, let success):
            break
        case .mapObjectSpawned(let object, let position, let direction, let headDirection):
            logger.info("Object \(object.objectID) spawned at \(position) direction: \(direction.rawValue)")
            mapScene?.onMapObjectSpawned(object: object, position: position, direction: direction, headDirection: headDirection)
        case .mapObjectMoved(let object, let startPosition, let endPosition):
            logger.info("Object \(object.objectID) moved from \(startPosition) to \(endPosition)")
            mapScene?.onMapObjectMoved(object: object, startPosition: startPosition, endPosition: endPosition)
        case .mapObjectStopped(let objectID, let position):
            logger.info("Object \(objectID) stopped at \(position)")
            mapScene?.onMapObjectStopped(objectID: objectID, position: position)
        case .maoObjectVanished(let objectID):
            logger.info("Object \(objectID) vanished")
            mapScene?.onMapObjectVanished(objectID: objectID)
        case .mapObjectDirectionChanged(let objectID, let direction, let headDirection):
            break
        case .mapObjectSpriteChanged(let objectID):
            break
        case .mapObjectStateChanged(let objectID, let bodyState, let healthState, let effectState):
            mapScene?.onMapObjectStateChanged(objectID: objectID, bodyState: bodyState, healthState: healthState, effectState: effectState)
        case .mapObjectActionPerformed(let objectAction):
            mapScene?.onMapObjectActionPerformed(objectAction: objectAction)
        case .npcDialogMessageReceived(let npcID, let message):
            if let dialog, dialog.npcID == npcID {
                dialog.clearIfNeeded()
                dialog.append(message: message)
            } else {
                dialog = NPCDialog(npcID: npcID, message: message)
            }
        case .npcDialogActionReceived(let npcID, let action):
            if let dialog, dialog.npcID == npcID {
                switch action {
                case .next:
                    dialog.action = .next
                case .close:
                    dialog.action = .close
                    dialog.menu = nil
                    dialog.input = nil
                }
            }
        case .npcDialogMenuReceived(let npcID, let menu):
            if let dialog, dialog.npcID == npcID {
                dialog.action = nil
                dialog.menu = menu
            }
        case .npcDialogInputReceived(let npcID, let input):
            if let dialog, dialog.npcID == npcID {
                dialog.action = nil
                dialog.input = input
            }
        case .npcDialogClosed(let npcID):
            if let dialog, dialog.npcID == npcID {
                self.dialog = nil
            }
        case .npcImageReceived(let image):
            break
        case .minimapMarkPositionReceived(let npcID, let position):
            break
        case .chatMessageReceived(let message):
            break
        case .authenticationBanned(let message):
            break
        case .errorOccurred(let error):
            break
        }
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
