//
//  ChatSession.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/8/15.
//

import Combine
import Observation
import RONetwork
import ROPackets

@MainActor
@Observable
final class ChatSession {
    enum Phase {
        case login
        case selectCharServer
        case selectChar
        case map
    }

    var phase: ChatSession.Phase = .login

    var messages: [any Message] = []

    var playerPosition: SIMD2<Int>?

    var availableCommands: [CommandMessage.Command] {
        switch phase {
        case .login:
            [.login]
        case .selectCharServer:
            [.selectCharServer]
        case .selectChar:
            [.makeChar, .deleteChar, .selectChar]
        case .map:
            [.moveUp, .moveDown, .moveLeft, .moveRight]
        }
    }

    @ObservationIgnored
    private var account: AccountInfo?

    @ObservationIgnored
    private var charServers: [CharServerInfo] = []

    @ObservationIgnored
    private var chars: [CharInfo] = []

    @ObservationIgnored
    private var loginSession: LoginSession?
    @ObservationIgnored
    private var charSession: CharSession?
    @ObservationIgnored
    private var mapSession: MapSession?

    @ObservationIgnored
    private var subscriptions = Set<AnyCancellable>()

    func sendMessage(_ content: String) {
        messages.append(.clientText(content))

        if let mapSession {
            mapSession.sendMessage(content)
        }
    }

    func sendCommand(_ command: CommandMessage.Command, parameters: [String] = []) {
        messages.append(.command(command, parameters: parameters))

        switch command {
        case .login:
            startLoginSession()

            let username = parameters[0]
            let password = parameters[1]
            loginSession?.login(username: username, password: password)

            loginSession?.keepAlive(username: username)
        case .selectCharServer:
            guard let serverNumber = Int(parameters[0]),
                  serverNumber - 1 < charServers.count else {
                return
            }

            let charServer = charServers[serverNumber - 1]
            startCharSession(charServer)
        case .makeChar:
            var char = CharInfo()
            char.name = parameters[0]
            char.str = UInt8(parameters[1]) ?? 1
            char.agi = UInt8(parameters[2]) ?? 1
            char.vit = UInt8(parameters[3]) ?? 1
            char.int = UInt8(parameters[4]) ?? 1
            char.dex = UInt8(parameters[5]) ?? 1
            char.luk = UInt8(parameters[6]) ?? 1
            char.slot = UInt8(parameters[7]) ?? 0

            charSession?.makeChar(char: char)
        case .deleteChar:
            break
        case .selectChar:
            let slot = UInt8(parameters[0]) ?? 0

            charSession?.selectChar(slot: slot)
        case .moveUp:
            if let position = playerPosition {
                mapSession?.requestMove(to: [position.x, position.y + 1])
            }
        case .moveDown:
            if let position = playerPosition {
                mapSession?.requestMove(to: [position.x, position.y - 1])
            }
        case .moveLeft:
            if let position = playerPosition {
                mapSession?.requestMove(to: [position.x - 1, position.y])
            }
        case .moveRight:
            if let position = playerPosition {
                mapSession?.requestMove(to: [position.x + 1, position.y])
            }
        }
    }

    private func startLoginSession() {
        let address = ClientSettings.shared.serverAddress
        guard let port = UInt16(ClientSettings.shared.serverPort) else {
            return
        }

        let loginSession = LoginSession(address: address, port: port)

        loginSession.subscribe(to: LoginEvents.Accepted.self) { [unowned self] event in
            self.account = event.account
            self.charServers = event.charServers

            self.phase = .selectCharServer

            self.messages.append(.serverText("Accepted"))

            let charServers = event.charServers.enumerated()
                .map {
                    "(\($0.offset + 1)) \($0.element.name)"
                }
                .joined(separator: "\n")
            self.messages.append(.serverText(charServers))
        }
        .store(in: &subscriptions)

        loginSession.subscribe(to: LoginEvents.Refused.self) { [unowned self] event in
            self.messages.append(.serverText("Refused"))
            self.messages.append(.serverText(event.message.rawValue))
        }
        .store(in: &subscriptions)

        loginSession.subscribe(to: AuthenticationEvents.Banned.self) { [unowned self] event in
            self.messages.append(.serverText("Banned"))
            self.messages.append(.serverText(event.message.rawValue))
        }
        .store(in: &subscriptions)

        loginSession.subscribe(to: ConnectionEvents.ErrorOccurred.self) { [unowned self] event in
            self.messages.append(.serverText(event.error.localizedDescription))
        }
        .store(in: &subscriptions)

        loginSession.start()

        self.loginSession = loginSession
    }

    private func startCharSession(_ charServer: CharServerInfo) {
        guard let account else {
            return
        }

        let charSession = CharSession(account: account, charServer: charServer)

        charSession.subscribe(to: CharServerEvents.Accepted.self) { [unowned self] event in
            self.chars = event.chars
            self.phase = .selectChar

            self.messages.append(.serverText("Accepted"))

            for char in event.chars {
                let message = """
                Char ID: \(char.charID)
                Name: \(char.name)
                Str: \(char.str)
                Agi: \(char.agi)
                Vit: \(char.vit)
                Int: \(char.int)
                Dex: \(char.dex)
                Luk: \(char.luk)
                Slot: \(char.slot)
                """
                self.messages.append(.serverText(message))
            }
        }
        .store(in: &subscriptions)

        charSession.subscribe(to: CharServerEvents.Refused.self) { [unowned self] event in
            self.messages.append(.serverText("Refused"))
        }
        .store(in: &subscriptions)

        charSession.subscribe(to: CharServerEvents.NotifyMapServer.self) { [unowned self] event in
            self.phase = .map

            self.messages.append(.serverText("Entered map: \(event.mapName)"))

            self.startMapSession(event)
        }
        .store(in: &subscriptions)

        charSession.subscribe(to: CharServerEvents.NotifyAccessibleMaps.self) { event in
        }
        .store(in: &subscriptions)

        charSession.subscribe(to: CharEvents.MakeAccepted.self) { [unowned self] event in
            self.messages.append(.serverText("Accepted"))
        }
        .store(in: &subscriptions)

        charSession.subscribe(to: CharEvents.MakeRefused.self) { [unowned self] event in
            self.messages.append(.serverText("Refused"))
        }
        .store(in: &subscriptions)

        charSession.subscribe(to: AuthenticationEvents.Banned.self) { [unowned self] event in
            self.messages.append(.serverText("Banned"))
            self.messages.append(.serverText(event.message.rawValue))
        }
        .store(in: &subscriptions)

        charSession.subscribe(to: ConnectionEvents.ErrorOccurred.self) { [unowned self] event in
            self.messages.append(.serverText(event.error.localizedDescription))
        }
        .store(in: &subscriptions)

        charSession.start()

        self.charSession = charSession
    }

    private func startMapSession(_ event: CharServerEvents.NotifyMapServer) {
        guard let account = charSession?.account,
              let char = chars.first(where: { $0.charID == event.charID }) else {
            return
        }

        let mapSession = MapSession(account: account, char: char, mapServer: event.mapServer)

        mapSession.subscribe(to: MapEvents.Changed.self) { [unowned self] event in
            self.playerPosition = event.position
            self.messages.append(.serverText("Map changed: \(event.mapName), position: \(event.position)"))

            // Load map.

            self.mapSession?.notifyMapLoaded()
        }
        .store(in: &subscriptions)

        mapSession.subscribe(to: PlayerEvents.Moved.self) { [unowned self] event in
            self.playerPosition = event.endPosition
            self.messages.append(.serverText("Player moved from \(event.startPosition) to \(event.endPosition)"))
        }
        .store(in: &subscriptions)

        mapSession.subscribe(to: ChatEvents.MessageReceived.self) { [unowned self] event in
            self.messages.append(.serverText("\(event.content)"))
        }
        .store(in: &subscriptions)

        mapSession.start()

        self.mapSession = mapSession
    }
}
