//
//  GameSession.swift
//  RagnarokGame
//
//  Created by Leon Li on 2024/9/5.
//

import Foundation
import Observation
import RagnarokConstants
import RagnarokLocalization
import RagnarokModels
import RagnarokNetwork
import RagnarokPackets
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

    @ObservationIgnored var loginClient: NetworkClient?
    @ObservationIgnored var loginKeepaliveTask: Task<Void, Never>?

    @ObservationIgnored var charClient: NetworkClient?
    @ObservationIgnored var charKeepaliveTask: Task<Void, Never>?

    var playSession: PlaySession? {
        if case .play(let playSession) = stage {
            playSession
        } else {
            nil
        }
    }

    public var mapScene: MapScene? {
        mapRuntime?.scene
    }

    var mapRuntime: MapSceneRuntime? {
        playSession?.mapRuntime
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
            stopCharClient()
            resetLoginPhase()
        case .play(let playSession):
            playSession.mapRuntime?.unload()
            account = playSession.account
            playSession.stop()
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

    private func returnToLogin(errorMessage content: String) {
        stopAllClients()

        let errorMessage = GameSession.ErrorMessage(content: content) { gameSession, errorMessage in
            gameSession.removeErrorMessage(errorMessage)
            gameSession.resetLoginPhase()
        }
        errorMessages.append(errorMessage)
    }

    private func handleClientError(_ error: NetworkClientError, from client: NetworkClient) {
        switch error {
        case .network, .disconnected:
            guard client === loginClient || client === charClient else {
                break
            }

            let localizedMessage = context.messageStringTable.localizedMessageString(forID: 1)
            returnToLogin(errorMessage: localizedMessage)
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

        let playSession = PlaySession(
            context: context,
            audioPlayer: audioPlayer,
            account: account,
            character: character
        )
        playSession.delegate = self
        stage = .play(playSession)
        playSession.start(mapServer: mapServer)
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

// MARK: - PlaySessionDelegate

extension GameSession: PlaySessionDelegate {
    func playSession(_ playSession: PlaySession, didFailToEnterWithErrorMessage errorMessage: String) {
        returnToLogin(errorMessage: errorMessage)
    }

    func playSessionDidRestart(_ playSession: PlaySession) {
        exitCurrentPhase()
    }

    func playSession(_ playSession: PlaySession, didReceiveErrorMessage errorMessage: String) {
        errorMessages.append(GameSession.ErrorMessage(content: errorMessage))
    }

    func playSessionDidDisconnect(_ playSession: PlaySession) {
        isDisconnected = true
    }
}
