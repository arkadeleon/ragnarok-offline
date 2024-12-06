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

    @ObservationIgnored
    private var loginClient: LoginClient?
    @ObservationIgnored
    private var charClient: CharClient?
    @ObservationIgnored
    private var mapClient: MapClient?

    @ObservationIgnored
    private var subscriptions = Set<AnyCancellable>()

    @ObservationIgnored
    private var state = ClientState()
    @ObservationIgnored
    private var charServers: [CharServerInfo] = []
    @ObservationIgnored
    private var position: SIMD2<Int16> = [0, 0]

    func sendCommand(_ command: CommandMessage.Command, parameters: [String] = []) {
        messages.append(.command(command, parameters: parameters))

        switch command {
        case .login:
            connectToLoginServer()

            let username = parameters[0]
            let password = parameters[1]
            loginClient?.login(username: username, password: password)

            loginClient?.keepAlive(username: username)
        case .selectCharServer:
            guard let serverNumber = Int(parameters[0]),
                  serverNumber - 1 < charServers.count else {
                break
            }

            let charServer = charServers[serverNumber - 1]

            connectToCharServer(charServer)

            charClient?.enter()

            charClient?.keepAlive()
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

    private func connectToLoginServer() {
        let loginClient = LoginClient()

        loginClient.subscribe(to: LoginEvents.Accepted.self) { [unowned self] event in
            self.state.accountID = event.accountID
            self.state.loginID1 = event.loginID1
            self.state.loginID2 = event.loginID2
            self.state.sex = event.sex

            self.charServers = event.charServers

            self.scene = .selectCharServer

            self.messages.append(.serverText("Accepted"))

            let servers = self.charServers.enumerated()
                .map {
                    "(\($0.offset + 1)) \($0.element.name)"
                }
                .joined(separator: "\n")
            self.messages.append(.serverText(servers))
        }
        .store(in: &subscriptions)

        loginClient.subscribe(to: LoginEvents.Refused.self) { [unowned self] event in
            self.messages.append(.serverText("Refused"))
            self.messages.append(.serverText(event.message))
        }
        .store(in: &subscriptions)

        loginClient.subscribe(to: AuthenticationEvents.Banned.self) { [unowned self] event in
            self.messages.append(.serverText("Banned"))
            self.messages.append(.serverText(event.message))
        }
        .store(in: &subscriptions)

        loginClient.subscribe(to: ConnectionEvents.ErrorOccurred.self) { [unowned self] event in
            self.messages.append(.serverText(event.error.localizedDescription))
        }
        .store(in: &subscriptions)

        loginClient.connect()

        self.loginClient = loginClient
    }

    private func connectToCharServer(_ charServer: CharServerInfo) {
        let charClient = CharClient(state: state, charServer: charServer)

        charClient.subscribe(to: CharServerEvents.Accepted.self) { [unowned self] event in
            self.scene = .selectChar

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

        charClient.subscribe(to: CharServerEvents.Refused.self) { [unowned self] event in
            self.messages.append(.serverText("Refused"))
        }
        .store(in: &subscriptions)

        charClient.subscribe(to: CharServerEvents.NotifyMapServer.self) { [unowned self] event in
            self.state.charID = event.charID

            self.scene = .map

            self.messages.append(.serverText("Entered map: \(event.mapName)"))

            self.connectToMapServer(event.mapServer)

            self.mapClient?.enter()

            self.mapClient?.keepAlive()
        }
        .store(in: &subscriptions)

        charClient.subscribe(to: CharServerEvents.NotifyAccessibleMaps.self) { event in
        }
        .store(in: &subscriptions)

        charClient.subscribe(to: CharEvents.MakeAccepted.self) { [unowned self] event in
            self.messages.append(.serverText("Accepted"))
        }
        .store(in: &subscriptions)

        charClient.subscribe(to: CharEvents.MakeRefused.self) { [unowned self] event in
            self.messages.append(.serverText("Refused"))
        }
        .store(in: &subscriptions)

        charClient.subscribe(to: AuthenticationEvents.Banned.self) { [unowned self] event in
            self.messages.append(.serverText("Banned"))
            self.messages.append(.serverText(event.message))
        }
        .store(in: &subscriptions)

        charClient.subscribe(to: ConnectionEvents.ErrorOccurred.self) { [unowned self] event in
            self.messages.append(.serverText(event.error.localizedDescription))
        }
        .store(in: &subscriptions)

        charClient.connect()

        self.charClient = charClient
    }

    private func connectToMapServer(_ mapServer: MapServerInfo) {
        let mapClient = MapClient(state: state, mapServer: mapServer)

        mapClient.subscribe(to: MapEvents.Changed.self) { [unowned self] event in
            self.position = event.position

            self.messages.append(.serverText("Map changed: \(event.mapName), position: (\(event.position.x), \(event.position.y))"))

            // Load map.

            self.mapClient?.notifyMapLoaded()
        }
        .store(in: &subscriptions)

        mapClient.subscribe(to: PlayerEvents.Moved.self) { [unowned self] event in
            self.position = event.toPosition

            self.messages.append(.serverText("Player moved from \(event.fromPosition) to \(event.toPosition)"))
        }
        .store(in: &subscriptions)

        mapClient.subscribe(to: PlayerEvents.MessageDisplay.self) { [unowned self] event in
            self.messages.append(.serverText("Player message display: \(event.message)"))
        }
        .store(in: &subscriptions)

        mapClient.connect()

        self.mapClient = mapClient
    }
}

extension EnvironmentValues {
    @Entry var conversation = Conversation()
}
