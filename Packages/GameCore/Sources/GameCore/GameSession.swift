//
//  GameSession.swift
//  GameCore
//
//  Created by Leon Li on 2024/9/5.
//

import RagnarokConstants
import Foundation
import Network
import NetworkClient
import NetworkPackets
import Observation
import RagnarokResources
import SpriteRendering
import WorldRendering

@MainActor
@Observable
final public class GameSession {
    public let windowID = "Game"
    public let immersiveSpaceID = "Game"

    public let resourceManager: ResourceManager

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
        case charSelect(_ chars: [CharInfo])
        case charMake(_ slot: UInt8)
        case mapLoading
        case map(_ scene: MapScene)
    }

    public private(set) var phase: GameSession.Phase = .login

    public struct ErrorMessage: Identifiable {
        public let id = UUID()
        public let content: String
    }

    public private(set) var errorMessages: [GameSession.ErrorMessage] = []

    public private(set) var account: AccountInfo?

    public private(set) var chars: [CharInfo] = []

    public private(set) var char: CharInfo?

    public private(set) var playerStatus: CharacterStatus?

    public private(set) var inventory = Inventory()

    public private(set) var dialog: NPCDialog?

    @ObservationIgnored
    var loginSession: LoginSession?
    @ObservationIgnored
    var charSession: CharSession?
    @ObservationIgnored
    var mapSession: MapSession?

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

    // MARK: - Start and Stop

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

    // MARK: - Public

    public func removeErrorMessage(_ errorMessage: GameSession.ErrorMessage) {
        if let index = errorMessages.firstIndex(where: { $0.id == errorMessage.id }) {
            errorMessages.remove(at: index)
        }
    }

    public func login(username: String, password: String) {
        startLoginSession()

        loginSession?.login(username: username, password: password)
    }

    public func selectCharServer(_ charServer: CharServerInfo) {
        startCharSession(charServer)
    }

    public func selectChar(char: CharInfo) {
        if let charSession {
            charSession.selectChar(slot: char.charNum)
        }
    }

    public func makeChar(slot: UInt8) {
        phase = .charMake(slot)
    }

    public func makeChar(char: CharInfo) {
        if let charSession {
            charSession.makeChar(char: char)
        }
    }

    public func cancelMakeChar() {
        phase = .charSelect(chars)
    }

    public func incrementStatusProperty(_ sp: StatusProperty) {
        if let mapSession {
            mapSession.incrementStatusProperty(sp, by: 1)
        }
    }

    public func useItem(_ item: InventoryItem) {
        if let mapSession {
            let accountID = mapSession.account.accountID
            mapSession.useItem(at: item.index, by: accountID)
        }
    }

    public func equipItem(_ item: InventoryItem) {
        if let mapSession {
            mapSession.equipItem(at: item.index, location: item.location)
        }
    }

    public func sendMessage(_ message: String) {
        if let mapSession {
            mapSession.sendMessage(message)
        }
    }

    public func returnToLastSavePoint() {
        mapSession?.returnToLastSavePoint()
    }

    public func returnToCharacterSelect() {
        mapSession?.returnToCharacterSelect()
    }

    public func requestExit() {
        mapSession?.requestExit()
        mapSession?.stop()
        mapSession = nil

        charSession?.stop()
        charSession = nil

        loginSession?.stop()
        loginSession = nil
    }

    // MARK: - NPC

    public func requestNextMessage() {
        guard let mapSession, let dialog else {
            return
        }

        Task {
            try await Task.sleep(for: .milliseconds(1))
            mapSession.requestNextMessage(objectID: dialog.objectID)
        }

        self.dialog = nil
    }

    public func closeDialog() {
        guard let mapSession, let dialog else {
            return
        }

        Task {
            try await Task.sleep(for: .milliseconds(1))
            mapSession.closeDialog(objectID: dialog.objectID)
        }

        self.dialog = nil
    }

    public func selectMenu(select: UInt8) {
        guard let mapSession, let dialog else {
            return
        }

        Task {
            try await Task.sleep(for: .milliseconds(1))
            mapSession.selectMenu(objectID: dialog.objectID, select: select)
        }

        self.dialog = nil
    }

    // MARK: - Character Sprite

    public func characterAnimation(forSlot slot: Int) async -> SpriteRenderer.Animation? {
        guard 0..<chars.count ~= slot else {
            return nil
        }

        return await characterAnimation(for: chars[slot])
    }

    public func characterAnimation(for char: CharInfo) async -> SpriteRenderer.Animation? {
        do {
            let configuration = ComposedSprite.Configuration(char: char)
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
        case .charServerAccepted(let chars):
            self.chars = chars
            phase = .charSelect(chars)
        case .charServerRefused:
            break
        case .charServerNotifiedMapServer(let charID, let mapName, let mapServer):
            if let char = chars.first(where: { $0.charID == charID }) {
                self.char = char
                startMapSession(char: char, mapServer: mapServer)
            }
        case .charServerNotifiedAccessibleMaps(let accessibleMaps):
            break
        case .makeCharAccepted(let char):
            chars.append(char)
            phase = .charSelect(chars)
        case .makeCharRefused:
            break
        case .deleteCharAccepted:
            break
        case .deleteCharRefused:
            break
        case .deleteCharCancelled:
            break
        case .deleteCharReserved(let deletionDate):
            break
        case .authenticationBanned(let message):
            break
        case .errorOccurred(let error):
            break
        }
    }

    // MARK: - Map Session

    private func startMapSession(char: CharInfo, mapServer: MapServerInfo) {
        guard let account = charSession?.account else {
            return
        }

        let mapSession = MapSession(account: account, char: char, mapServer: mapServer)

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

            phase = .charSelect(chars)
        case .mapChanged(let mapName, let position):
            if case .map(let scene) = phase {
                scene.unload()
            }

            phase = .mapLoading

            Task {
                guard let account, let char else {
                    return
                }

                let mapName = String(mapName.dropLast(4))
                let worldPath = ResourcePath(components: ["data", mapName])
                let world = try await resourceManager.world(at: worldPath)

                let player = MapObject(account: account, char: char)

                let scene = MapScene(
                    mapName: mapName,
                    world: world,
                    player: player,
                    playerPosition: position,
                    resourceManager: resourceManager
                )
                scene.mapSceneDelegate = self

                await scene.load()

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
            mapScene?.onMapObjectSpawned(object: object, position: position, direction: direction, headDirection: headDirection)
        case .mapObjectMoved(let object, let startPosition, let endPosition):
            mapScene?.onMapObjectMoved(object: object, startPosition: startPosition, endPosition: endPosition)
        case .mapObjectStopped(let objectID, let position):
            mapScene?.onMapObjectStopped(objectID: objectID, position: position)
        case .maoObjectVanished(let objectID):
            mapScene?.onMapObjectVanished(objectID: objectID)
        case .mapObjectDirectionChanged(let objectID, let direction, let headDirection):
            break
        case .mapObjectSpriteChanged(let objectID):
            break
        case .mapObjectStateChanged(let objectID, let bodyState, let healthState, let effectState):
            mapScene?.onMapObjectStateChanged(objectID: objectID, bodyState: bodyState, healthState: healthState, effectState: effectState)
        case .mapObjectActionPerformed(let sourceObjectID, let targetObjectID, let actionType):
            mapScene?.onMapObjectActionPerformed(sourceObjectID: sourceObjectID, targetObjectID: targetObjectID, actionType: actionType)
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

extension GameSession: MapSceneDelegate {
    func mapSceneDidFinishLoading(_ scene: MapScene) {
        mapSession?.notifyMapLoaded()
    }

    func mapScene(_ scene: MapScene, didTapTileAt position: SIMD2<Int>) {
        mapSession?.requestMove(to: position)
    }

    func mapScene(_ scene: MapScene, didTapMapObject object: MapObject) {
        switch object.type {
        case .monster:
            mapSession?.requestAction(._repeat, onTarget: object.objectID)
        case .npc:
            mapSession?.talkToNPC(objectID: object.objectID)
        default:
            break
        }
    }

    func mapScene(_ scene: MapScene, didTapMapObjectWith objectID: UInt32) {
        mapSession?.talkToNPC(objectID: objectID)
    }

    func mapScene(_ scene: MapScene, didTapMapItem item: MapItem) {
        mapSession?.pickUpItem(objectID: item.objectID)
    }
}
