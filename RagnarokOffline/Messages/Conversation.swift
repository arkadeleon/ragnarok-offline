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
    var messages: [any Message] = []

    var scene: ConversationScene = .login

    var availableCommands: [CommandMessage.Command] {
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

    func sendCommand(_ command: CommandMessage.Command, parameters: [String] = []) {
        messages.append(.command(command, parameters: parameters))

        switch command {
        case .login:
            let loginClient = LoginClient()

            loginClient.subscribe(to: LoginEvents.Accepted.self, onLoginAccepted).store(in: &subscriptions)
            loginClient.subscribe(to: LoginEvents.Refused.self, onLoginRefused).store(in: &subscriptions)

            loginClient.subscribe(to: AuthenticationEvents.Banned.self, onAuthenticationBanned).store(in: &subscriptions)

            loginClient.subscribe(to: ConnectionEvents.ErrorOccurred.self, onConnectionErrorOccurred).store(in: &subscriptions)

            loginClient.connect()

            let username = parameters[0]
            let password = parameters[1]
            loginClient.login(username: username, password: password)

            self.loginClient = loginClient
        case .selectCharServer:
            guard let serverNumber = Int(parameters[0]),
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
            char.name = parameters[0]
            char.str = UInt8(parameters[1]) ?? 1
            char.agi = UInt8(parameters[2]) ?? 1
            char.vit = UInt8(parameters[3]) ?? 1
            char.int = UInt8(parameters[4]) ?? 1
            char.dex = UInt8(parameters[5]) ?? 1
            char.luk = UInt8(parameters[6]) ?? 1
            char.slot = UInt8(parameters[7]) ?? 0

            charClient?.makeChar(char: char)
        case .deleteChar:
            break
        case .selectChar:
            let slot = UInt8(parameters[0]) ?? 0

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

        messages.append(.serverText("Accepted"))

        let servers = charServers.enumerated()
            .map({ "(\($0.offset + 1)) \($0.element.name)" })
            .joined(separator: "\n")
        messages.append(.serverText(servers))
    }

    private func onLoginRefused(_ event: LoginEvents.Refused) {
        messages.append(.serverText("Refused"))
        messages.append(.serverText(event.message))
    }

    // MARK: - Char Server Events

    private func onCharServerAccepted(_ event: CharServerEvents.Accepted) {
        scene = .selectChar

        messages.append(.serverText("Accepted"))

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
            messages.append(.serverText(message))
        }
    }

    private func onCharServerRefused(_ event: CharServerEvents.Refused) {
        messages.append(.serverText("Refused"))
    }

    private func onCharServerNotifyMapServer(_ event: CharServerEvents.NotifyMapServer) {
        state.charID = event.charID

        scene = .map

        messages.append(.serverText("Entered map: \(event.mapName)"))

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
        messages.append(.serverText("Accepted"))
    }

    private func onCharMakeRefused(_ event: CharEvents.MakeRefused) {
        messages.append(.serverText("Refused"))
    }

    // MARK: - Map Events

    private func onMapChanged(_ event: MapEvents.Changed) {
        position = event.position

        messages.append(.serverText("Map changed: \(event.mapName), position: (\(event.position.x), \(event.position.y))"))

        // Load map.

        mapClient?.notifyMapLoaded()
    }

    // MARK: - Player Events

    private func onPlayerMoved(_ event: PlayerEvents.Moved) {
        position = [event.moveData.x1, event.moveData.y1]

        messages.append(.serverText("Player moved from (\(event.moveData.x0), \(event.moveData.y0)) to (\(event.moveData.x1), \(event.moveData.y1))"))
    }

    private func onPlayerMessageDisplay(_ event: PlayerEvents.MessageDisplay) {
        messages.append(.serverText("Player message display: \(event.message)"))
    }

    // MARK: - Authentication Events

    private func onAuthenticationBanned(_ event: AuthenticationEvents.Banned) {
        messages.append(.serverText("Banned"))
        messages.append(.serverText(event.message))
    }

    // MARK: - Connection Events

    private func onConnectionErrorOccurred(_ event: ConnectionEvents.ErrorOccurred) {
        messages.append(.serverText(event.error.localizedDescription))
    }
}

extension EnvironmentValues {
    @Entry var conversation = Conversation()
}
