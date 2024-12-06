//
//  GameSession.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/9/5.
//

import Combine
import Observation
import RODatabase
import RONetwork
import SwiftUI

enum GamePhase {
    case login
    case charServerList(_ charServers: [CharServerInfo])
    case charSelect(_ chars: [CharInfo])
    case charMake(_ slot: UInt8)
    case map
}

@Observable
final class GameSession {
    var phase: GamePhase = .login
    var map: GameMap?

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

    func requestMove(x: Int16, y: Int16) {
        mapClient?.requestMove(x: x, y: y)
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
            Task { [self] in
                let mapName = String(event.mapName.dropLast(4))
                if let map = try await MapDatabase.renewal.map(forName: mapName),
                   let grid = map.grid() {
                    self.phase = .map
                    self.map = GameMap(name: mapName, grid: grid, position: event.position)
                }

                self.mapClient?.notifyMapLoaded()
            }
        }
        .store(in: &subscriptions)

        mapClient.subscribe(to: PlayerEvents.Moved.self) { [unowned self] event in
            Task {
                await MainActor.run {
                    self.map?.player.position = [event.moveData.x1, event.moveData.y1]
                }
            }
        }
        .store(in: &subscriptions)

        mapClient.subscribe(to: PlayerEvents.MessageDisplay.self) { event in
        }
        .store(in: &subscriptions)

        mapClient.subscribe(to: ObjectEvents.Spawned.self) { [unowned self] event in
            let object = GameMap.Object(position: event.position)
            self.map?.objects.append(object)
        }
        .store(in: &subscriptions)

        mapClient.connect()

        self.mapClient = mapClient
    }
}

extension EnvironmentValues {
    @Entry var gameSession = GameSession()
}
