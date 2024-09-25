//
//  GameSession.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/9/5.
//

import Combine
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

    private var loginClient: LoginClient?
    private var charClient: CharClient?

    private var subscriptions = Set<AnyCancellable>()

    private var state = ClientState()
    private var charServers: [CharServerInfo] = []
    private var chars: [CharInfo] = []

    func login(username: String, password: String) {
        let loginClient = LoginClient()

        loginClient.subscribe(to: LoginEvents.Accepted.self, onLoginAccepted).store(in: &subscriptions)
        loginClient.subscribe(to: LoginEvents.Refused.self, onLoginRefused).store(in: &subscriptions)

        loginClient.subscribe(to: AuthenticationEvents.Banned.self, onAuthenticationBanned).store(in: &subscriptions)

        loginClient.subscribe(to: ConnectionEvents.ErrorOccurred.self, onConnectionErrorOccurred).store(in: &subscriptions)

        loginClient.connect()

        loginClient.login(username: username, password: password)

        self.loginClient = loginClient
    }

    func selectCharServer(_ charServer: CharServerInfo) {
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
    }

    func makeChar(char: CharInfo) {
        charClient?.makeChar(char: char)
    }

    func selectChar(slot: UInt8) {
        charClient?.selectChar(slot: slot)
    }

    // MARK: - Login Events

    private func onLoginAccepted(_ event: LoginEvents.Accepted) {
        state.accountID = event.accountID
        state.loginID1 = event.loginID1
        state.loginID2 = event.loginID2
        state.sex = event.sex
        charServers = event.charServers

        phase = .charServerList(charServers)
    }

    private func onLoginRefused(_ event: LoginEvents.Refused) {
    }

    // MARK: - Char Server Events

    private func onCharServerAccepted(_ event: CharServerEvents.Accepted) {
        chars = event.chars

        phase = .charSelect(chars)
    }

    private func onCharServerRefused(_ event: CharServerEvents.Refused) {
    }

    private func onCharServerNotifyMapServer(_ event: CharServerEvents.NotifyMapServer) {
        state.charID = event.charID

        phase = .map(event.mapName)
    }

    private func onCharServerNotifyAccessibleMaps(_ event: CharServerEvents.NotifyAccessibleMaps) {
    }

    // MARK: - Char Events

    private func onCharMakeAccepted(_ event: CharEvents.MakeAccepted) {
        chars.append(event.char)

        phase = .charSelect(chars)
    }

    private func onCharMakeRefused(_ event: CharEvents.MakeRefused) {
    }

    // MARK: - Authentication Events

    private func onAuthenticationBanned(_ event: AuthenticationEvents.Banned) {
    }

    // MARK: - Connection Events

    private func onConnectionErrorOccurred(_ event: ConnectionEvents.ErrorOccurred) {
    }
}

extension EnvironmentValues {
    @Entry var gameSession = GameSession()
}
