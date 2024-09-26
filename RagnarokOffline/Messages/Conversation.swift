//
//  Conversation.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/8/15.
//

import Combine
import Observation
import RONetwork
import SwiftUI

enum ConversationScene {
    case login
    case selectCharServer
    case selectChar
    case map
}

@Observable
class Conversation {
    var messages: [Message] = []

    var scene: ConversationScene = .login

    var availableCommands: [MessageCommand] {
        switch scene {
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

    private var loginClient: LoginClient?
    private var charClient: CharClient?
    private var mapClient: MapClient?

    private var subscriptions = Set<AnyCancellable>()

    private var state = ClientState()
    private var charServers: [CharServerInfo] = []
    private var position: SIMD2<UInt16> = [0, 0]

    func executeCommand(_ command: MessageCommand, arguments: [String] = []) {
        var content = "$" + command.rawValue
        for (index, argument) in command.arguments.enumerated() {
            content.append("\n")
            content.append("--\(argument) \(arguments[index])")
        }

        let message = Message(sender: .client, content: content)
        messages.append(message)

        switch command {
        case .login:
            let loginClient = LoginClient()

            loginClient.subscribe(to: LoginEvents.Accepted.self, onLoginAccepted).store(in: &subscriptions)
            loginClient.subscribe(to: LoginEvents.Refused.self, onLoginRefused).store(in: &subscriptions)

            loginClient.subscribe(to: AuthenticationEvents.Banned.self, onAuthenticationBanned).store(in: &subscriptions)

            loginClient.subscribe(to: ConnectionEvents.ErrorOccurred.self, onConnectionErrorOccurred).store(in: &subscriptions)

            loginClient.connect()

            let username = arguments[0]
            let password = arguments[1]
            loginClient.login(username: username, password: password)

            self.loginClient = loginClient
        case .selectCharServer:
            guard let serverNumber = Int(arguments[0]),
                  serverNumber - 1 < charServers.count else {
                break
            }

            let charServer = charServers[serverNumber - 1]
            let charClient = CharClient(state: state, charServer: charServer)

            charClient.subscribe(to: CharServerEvents.Accepted.self, onCharServerAccepted).store(in: &subscriptions)
            charClient.subscribe(to: CharServerEvents.Refused.self, onCharServerRefused).store(in: &subscriptions)
            charClient.subscribe(to: CharServerEvents.NotifyMapServer.self, onCharServerNotifyMapServer).store(in: &subscriptions)
            charClient.subscribe(to: CharServerEvents.NotifyAccessibleMaps.self, onCharServerNotifyAccessibleMaps).store(in: &subscriptions)

            charClient.subscribe(to: CharEvents.MakeAccepted.self, onCharMakeAccepted).store(in: &subscriptions)
            charClient.subscribe(to: CharEvents.MakeRefused.self, onCharMakeRefused).store(in: &subscriptions)

            charClient.subscribe(to: AuthenticationEvents.Banned.self, onAuthenticationBanned).store(in: &subscriptions)

            charClient.subscribe(to: ConnectionEvents.ErrorOccurred.self, onConnectionErrorOccurred).store(in: &subscriptions)

            charClient.connect()

            charClient.enter()

            self.charClient = charClient
        case .makeChar:
            var char = CharInfo()
            char.name = arguments[0]
            char.str = UInt8(arguments[1]) ?? 1
            char.agi = UInt8(arguments[2]) ?? 1
            char.vit = UInt8(arguments[3]) ?? 1
            char.int = UInt8(arguments[4]) ?? 1
            char.dex = UInt8(arguments[5]) ?? 1
            char.luk = UInt8(arguments[6]) ?? 1
            char.slot = UInt8(arguments[7]) ?? 0

            charClient?.makeChar(char: char)
        case .deleteChar:
            break
        case .selectChar:
            let slot = UInt8(arguments[0]) ?? 0

            charClient?.selectChar(slot: slot)
        case .moveUp:
            mapClient?.requestMove(x: position.x, y: position.y + 1)
        case .moveDown:
            mapClient?.requestMove(x: position.x, y: position.y - 1)
        case .moveLeft:
            mapClient?.requestMove(x: position.x - 1, y: position.y)
        case .moveRight:
            mapClient?.requestMove(x: position.x + 1, y: position.y)
        }
    }

    // MARK: - Login Events

    private func onLoginAccepted(_ event: LoginEvents.Accepted) {
        state.accountID = event.accountID
        state.loginID1 = event.loginID1
        state.loginID2 = event.loginID2
        state.sex = event.sex

        charServers = event.charServers

        scene = .selectCharServer

        messages.append(.server("Accepted"))

        let serversMessage = charServers.enumerated()
            .map({ "(\($0.offset + 1)) \($0.element.name)" })
            .joined(separator: "\n")
        messages.append(.server(serversMessage))
    }

    private func onLoginRefused(_ event: LoginEvents.Refused) {
        messages.append(.server("Refused"))
        messages.append(.server(event.message))
    }

    // MARK: - Char Server Events

    private func onCharServerAccepted(_ event: CharServerEvents.Accepted) {
        scene = .selectChar

        messages.append(.server("Accepted"))

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
            messages.append(.server(message))
        }
    }

    private func onCharServerRefused(_ event: CharServerEvents.Refused) {
        messages.append(.server("Refused"))
    }

    private func onCharServerNotifyMapServer(_ event: CharServerEvents.NotifyMapServer) {
        state.charID = event.charID

        scene = .map

        messages.append(.server("Entered map: \(event.mapName)"))

        let mapClient = MapClient(state: state, mapServer: event.mapServer)

        mapClient.subscribe(to: MapEvents.Changed.self, onMapChanged).store(in: &subscriptions)

        mapClient.subscribe(to: PlayerEvents.Moved.self, onPlayerMoved).store(in: &subscriptions)
        mapClient.subscribe(to: PlayerEvents.MessageDisplay.self, onPlayerMessageDisplay).store(in: &subscriptions)

        mapClient.connect()

        mapClient.enter()

        mapClient.keepAlive()

        self.mapClient = mapClient
    }

    private func onCharServerNotifyAccessibleMaps(_ event: CharServerEvents.NotifyAccessibleMaps) {
    }

    // MARK: - Char Events

    private func onCharMakeAccepted(_ event: CharEvents.MakeAccepted) {
        messages.append(.server("Accepted"))
    }

    private func onCharMakeRefused(_ event: CharEvents.MakeRefused) {
        messages.append(.server("Refused"))
    }

    // MARK: - Map Events

    private func onMapChanged(_ event: MapEvents.Changed) {
        position = event.position

        messages.append(.server("Map changed: \(event.mapName), position: (\(event.position.x), \(event.position.y))"))

        // Load map.

        mapClient?.notifyMapLoaded()
    }

    // MARK: - Player Events

    private func onPlayerMoved(_ event: PlayerEvents.Moved) {
        position = [event.moveData.x1, event.moveData.y1]

        messages.append(.server("Player moved from (\(event.moveData.x0), \(event.moveData.y0)) to (\(event.moveData.x1), \(event.moveData.y1))"))
    }

    private func onPlayerMessageDisplay(_ event: PlayerEvents.MessageDisplay) {
        messages.append(.server("Player message display: \(event.message)"))
    }

    // MARK: - Authentication Events

    private func onAuthenticationBanned(_ event: AuthenticationEvents.Banned) {
        messages.append(.server("Banned"))
        messages.append(.server(event.message))
    }

    // MARK: - Connection Events

    private func onConnectionErrorOccurred(_ event: ConnectionEvents.ErrorOccurred) {
        messages.append(.server(event.error.localizedDescription))
    }
}

extension EnvironmentValues {
    @Entry var conversation = Conversation()
}
