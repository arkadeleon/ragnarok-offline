//
//  GameSession.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/9/5.
//

import Observation
import RONetwork
import SwiftUI

enum GamePhase {
    case login
    case charServerList(_ charServers: [CharServerInfo])
    case charSelect(_ chars: [CharInfo])
    case charMake(_ slot: UInt8)
    case map(String)
}

@Observable
final class GameSession {
    var phase: GamePhase = .login

    private var loginClient: LoginClient!
    private var charClient: CharClient?

    private var state: ClientState?
    private var charServers: [CharServerInfo] = []
    private var chars: [CharInfo] = []

    func login(username: String, password: String) {
        loginClient = LoginClient()
        loginClient.onAcceptLogin = { [weak self] state, charServers in
            self?.state = state
            self?.charServers = charServers

            self?.phase = .charServerList(charServers)

//            self?.messages.append(.server("Accepted"))
//
//            let serversMessage = charServers.enumerated()
//                .map({ "(\($0.offset + 1)) \($0.element.name)" })
//                .joined(separator: "\n")
//            self?.messages.append(.server(serversMessage))
        }
        loginClient.onRefuseLogin = { [weak self] message in
//            self?.messages.append(.server("Refused"))
//            self?.messages.append(.server(message))
        }
        loginClient.onNotifyBan = { [weak self] message in
//            self?.messages.append(.server("Banned"))
//            self?.messages.append(.server(message))
        }
        loginClient.onError = { [weak self] error in
//            self?.messages.append(.server(error.localizedDescription))
        }

        loginClient.connect()

        loginClient.login(username: username, password: password)
    }

    func selectCharServer(_ charServer: CharServerInfo) {
        guard let state else {
            return
        }

        charClient = CharClient(state: state, charServer: charServer)
        charClient?.onAcceptEnter = { [weak self] chars in
            self?.chars = chars

            self?.phase = .charSelect(chars)
        }
//        charClient?.onRefuseEnter = { [weak self] in
//            self?.messages.append(.server("Refused"))
//        }
        charClient?.onAcceptMakeChar = { [weak self] char in
            self?.chars.append(char)

            self?.phase = .charSelect(self?.chars ?? [])
        }
//        charClient?.onRefuseMakeChar = { [weak self] in
//            self?.messages.append(.server("Refused"))
//        }
        charClient?.onNotifyZoneServer = { [weak self] mapName, mapServer in
            self?.phase = .map(mapName)
        }

        charClient?.connect()

        charClient?.enter()
    }

    func makeChar(char: CharInfo) {
        charClient?.makeChar(char: char)
    }

    func selectChar(slot: UInt8) {
        charClient?.selectChar(slot: slot)
    }
}

extension EnvironmentValues {
    @Entry var gameSession = GameSession()
}
