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
    private var chars: [CharInfo] = []

    func login(username: String, password: String) {
        connectToLoginServer()

        loginClient?.login(username: username, password: password)

        loginClient?.keepAlive(username: username)
    }

    func selectCharServer(_ charServer: CharServerInfo) {
        connectToCharServer(charServer)

        charClient?.enter()

        charClient?.keepAlive()
    }

    func makeChar(char: CharInfo) {
        charClient?.makeChar(char: char)
    }

    func selectChar(slot: UInt8) {
        charClient?.selectChar(slot: slot)
    }

    private func connectToLoginServer() {
        let loginClient = LoginClient()

        loginClient.subscribe(to: LoginEvents.Accepted.self) { [unowned self] event in
            self.state.accountID = event.accountID
            self.state.loginID1 = event.loginID1
            self.state.loginID2 = event.loginID2
            self.state.sex = event.sex

            self.charServers = event.charServers

            self.phase = .charServerList(charServers)
        }
        .store(in: &subscriptions)

        loginClient.subscribe(to: LoginEvents.Refused.self) { event in
        }
        .store(in: &subscriptions)

        loginClient.subscribe(to: AuthenticationEvents.Banned.self) { event in
        }
        .store(in: &subscriptions)

        loginClient.subscribe(to: ConnectionEvents.ErrorOccurred.self) { event in
        }
        .store(in: &subscriptions)

        loginClient.connect()

        self.loginClient = loginClient
    }

    private func connectToCharServer(_ charServer: CharServerInfo) {
        let charClient = CharClient(state: state, charServer: charServer)

        charClient.subscribe(to: CharServerEvents.Accepted.self) { [unowned self] event in
            self.chars = event.chars

            self.phase = .charSelect(chars)
        }
        .store(in: &subscriptions)

        charClient.subscribe(to: CharServerEvents.Refused.self) { event in
        }
        .store(in: &subscriptions)

        charClient.subscribe(to: CharServerEvents.NotifyMapServer.self) { [unowned self] event in
            self.state.charID = event.charID

            self.phase = .map(event.mapName)

            self.connectToMapServer(event.mapServer)

            self.mapClient?.enter()

            self.mapClient?.keepAlive()
        }
        .store(in: &subscriptions)

        charClient.subscribe(to: CharServerEvents.NotifyAccessibleMaps.self) { event in
        }
        .store(in: &subscriptions)

        charClient.subscribe(to: CharEvents.MakeAccepted.self) { [unowned self] event in
            self.chars.append(event.char)

            self.phase = .charSelect(chars)
        }
        .store(in: &subscriptions)

        charClient.subscribe(to: CharEvents.MakeRefused.self) { event in
        }
        .store(in: &subscriptions)

        charClient.subscribe(to: AuthenticationEvents.Banned.self) { event in
        }
        .store(in: &subscriptions)

        charClient.subscribe(to: ConnectionEvents.ErrorOccurred.self) { event in
        }
        .store(in: &subscriptions)

        charClient.connect()

        self.charClient = charClient
    }

    private func connectToMapServer(_ mapServer: MapServerInfo) {
        let mapClient = MapClient(state: state, mapServer: mapServer)

        mapClient.subscribe(to: MapEvents.Changed.self) { [unowned self] event in
            // Load map.

            self.mapClient?.notifyMapLoaded()
        }
        .store(in: &subscriptions)

        mapClient.subscribe(to: PlayerEvents.Moved.self) { event in
        }
        .store(in: &subscriptions)

        mapClient.subscribe(to: PlayerEvents.MessageDisplay.self) { event in
        }
        .store(in: &subscriptions)

        mapClient.connect()

        self.mapClient = mapClient
    }
}

extension EnvironmentValues {
    @Entry var gameSession = GameSession()
}
