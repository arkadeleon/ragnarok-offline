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
import RagnarokNetwork
import RagnarokReality
import RagnarokResources
import RagnarokSprite

@MainActor
@Observable
final public class GameSession {
    public let windowID = "Game"
    public let immersiveSpaceID = "Game"

    let resourceManager: ResourceManager

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
        case login
        case charServerList(_ charServers: [CharServerInfo])
        case characterSelect(_ characters: [CharacterInfo])
        case characterMake(_ slot: Int)
        case mapLoading(_ progress: Progress)
        case map(_ scene: MapScene)
    }

    public private(set) var phase: GameSession.Phase = .login

    struct ErrorMessage: Identifiable {
        let id = UUID()
        let content: String
    }

    private(set) var errorMessages: [GameSession.ErrorMessage] = []
    private(set) var account: AccountInfo?
    private(set) var characters: [CharacterInfo] = []
    private(set) var character: CharacterInfo?
    private(set) var playerStatus: CharacterStatus?
    private(set) var inventory = Inventory()
    private(set) var dialog: NPCDialog?

    @ObservationIgnored var loginSession: LoginSession?
    @ObservationIgnored var charSession: CharSession?
    @ObservationIgnored var mapSession: MapSession?

    var mapScene: MapScene? {
        if case .map(let scene) = phase {
            scene
        } else {
            nil
        }
    }

    public init(resourceManager: ResourceManager) {
        self.resourceManager = resourceManager
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

    func login(username: String, password: String) {
        startLoginSession()

        loginSession?.login(username: username, password: password)
    }

    func selectCharServer(_ charServer: CharServerInfo) {
        startCharSession(charServer)
    }

    func makeCharacter(slot: Int) {
        phase = .characterMake(slot)
    }

    func cancelMakeCharacter() {
        phase = .characterSelect(characters)
    }

    func stopAllSessions() {
        mapSession?.stop()
        mapSession = nil

        charSession?.stop()
        charSession = nil

        loginSession?.stop()
        loginSession = nil

        phase = .login
    }

    // MARK: - NPC

    func requestNextMessage() {
        guard let mapSession, let dialog else {
            return
        }

        Task {
            try await Task.sleep(for: .milliseconds(1))
            mapSession.requestNextMessage(objectID: dialog.objectID)
        }

        self.dialog = nil
    }

    func closeDialog() {
        guard let mapSession, let dialog else {
            return
        }

        Task {
            try await Task.sleep(for: .milliseconds(1))
            mapSession.closeDialog(objectID: dialog.objectID)
        }

        self.dialog = nil
    }

    func selectMenu(select: UInt8) {
        guard let mapSession, let dialog else {
            return
        }

        Task {
            try await Task.sleep(for: .milliseconds(1))
            mapSession.selectMenu(objectID: dialog.objectID, select: select)
        }

        self.dialog = nil
    }

    // MARK: - Login Session

    private func startLoginSession() {
        guard case .running(let configuration) = state else {
            return
        }

        let loginSession = LoginSession(
            address: configuration.serverAddress,
            port: configuration.serverPort
        )

        Task {
            for await event in loginSession.events {
                handleLoginEvent(event)
            }
        }

        loginSession.start()

        self.loginSession = loginSession
    }

    private func handleLoginEvent(_ event: LoginSession.Event) {
        switch event {
        case .loginAccepted(let account, let charServers):
            self.account = account

            if charServers.count == 1 {
                selectCharServer(charServers[0])
            } else if charServers.count > 1 {
                phase = .charServerList(charServers)
            }
        case .loginRefused(let message):
            Task {
                let messageStringTable = await resourceManager.messageStringTable(for: .current)
                if let localizedMessage = messageStringTable.localizedMessageString(forID: message.messageID) {
                    let localizedMessage = localizedMessage.replacingOccurrences(of: "%s", with: message.unblockTime)
                    let errorMessage = GameSession.ErrorMessage(content: localizedMessage)
                    errorMessages.append(errorMessage)
                }
            }
        case .authenticationBanned(let message):
            Task {
                let messageStringTable = await resourceManager.messageStringTable(for: .current)
                if let localizedMessage = messageStringTable.localizedMessageString(forID: message.messageID) {
                    let errorMessage = GameSession.ErrorMessage(content: localizedMessage)
                    errorMessages.append(errorMessage)
                }
            }
        case .errorOccurred(let error):
            let errorMessage = GameSession.ErrorMessage(content: error.localizedDescription)
            errorMessages.append(errorMessage)
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
            phase = .characterSelect(characters)
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
            phase = .characterSelect(characters)
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

            phase = .characterSelect(characters)
        case .mapChanged(let mapName, let position):
            if case .map(let scene) = phase {
                scene.unload()
            }

            let progress = Progress()
            phase = .mapLoading(progress)

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

                phase = .map(scene)
            }
        case .playerMoved(let startPosition, let endPosition):
            mapScene?.onPlayerMoved(startPosition: startPosition, endPosition: endPosition)
        case .playerStatusChanged(let status):
            self.playerStatus = status
        case .playerAttackRangeChanged(let value):
            break
        case .achievementListed:
            break
        case .achievementUpdated:
            break
        case .itemListReceived(let inventory):
            self.inventory = inventory
        case .itemListUpdated(let inventory):
            self.inventory = inventory
        case .itemSpawned(let item, let position):
            mapScene?.onItemSpawned(item: item, position: position)
        case .itemVanished(let objectID):
            mapScene?.onItemVanished(objectID: objectID)
        case .itemPickedUp(let item):
            break
        case .itemThrown(let item):
            break
        case .itemUsed(let item, let accountID, let success):
            break
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
        case .npcDialogReceived(let dialog):
            self.dialog = dialog
        case .npcDialogClosed(let npcID):
            dialog = nil
        case .imageReceived(let image):
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
