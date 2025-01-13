//
//  GameSession.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/9/5.
//

import Combine
import Observation
import RODatabase
import ROFileFormats
import ROGame
import RONetwork
import SwiftUI

enum GamePhase {
    case login
    case charServerList(_ charServers: [CharServerInfo])
    case charSelect(_ chars: [CharInfo])
    case charMake(_ slot: UInt8)
    case mapLoading
    case map(_ mapName: String, _ gat: GAT, _ gnd: GND, _ position: SIMD2<Int16>)
}

@Observable
final class GameSession {
    let storage = SessionStorage()

    @MainActor
    var phase: GamePhase = .login

    @ObservationIgnored
    var loginSession: LoginSession?
    @ObservationIgnored
    var charSession: CharSession?
    @ObservationIgnored
    var mapSession: MapSession?

    @ObservationIgnored
    private var subscriptions = Set<AnyCancellable>()

    @MainActor
    func login(username: String, password: String) {
        startLoginSession()

        loginSession?.login(username: username, password: password)

        loginSession?.keepAlive(username: username)
    }

    @MainActor
    func selectCharServer(_ charServer: CharServerInfo) {
        startCharSession(charServer)
    }

    private func startLoginSession() {
        let address = ClientSettings.shared.serverAddress
        guard let port = UInt16(ClientSettings.shared.serverPort) else {
            return
        }

        let loginSession = LoginSession(storage: storage, address: address, port: port)

        loginSession.subscribe(to: LoginEvents.Accepted.self) { [unowned self] event in
            self.phase = .charServerList(event.charServers)
        }
        .store(in: &subscriptions)

        loginSession.subscribe(to: LoginEvents.Refused.self) { event in
        }
        .store(in: &subscriptions)

        loginSession.subscribe(to: AuthenticationEvents.Banned.self) { event in
        }
        .store(in: &subscriptions)

        loginSession.subscribe(to: ConnectionEvents.ErrorOccurred.self) { event in
        }
        .store(in: &subscriptions)

        loginSession.start()

        self.loginSession = loginSession
    }

    private func startCharSession(_ charServer: CharServerInfo) {
        let charSession = CharSession(storage: storage, charServer: charServer)

        charSession.subscribe(to: CharServerEvents.Accepted.self) { [unowned self] event in
            Task {
                let chars = await self.storage.chars
                self.phase = .charSelect(chars)
            }
        }
        .store(in: &subscriptions)

        charSession.subscribe(to: CharServerEvents.Refused.self) { event in
        }
        .store(in: &subscriptions)

        charSession.subscribe(to: CharServerEvents.NotifyMapServer.self) { [unowned self] event in
            self.startMapSession(event.mapServer)
        }
        .store(in: &subscriptions)

        charSession.subscribe(to: CharServerEvents.NotifyAccessibleMaps.self) { event in
        }
        .store(in: &subscriptions)

        charSession.subscribe(to: CharEvents.MakeAccepted.self) { [unowned self] event in
            Task {
                let chars = await self.storage.chars
                self.phase = .charSelect(chars)
            }
        }
        .store(in: &subscriptions)

        charSession.subscribe(to: CharEvents.MakeRefused.self) { event in
        }
        .store(in: &subscriptions)

        charSession.subscribe(to: AuthenticationEvents.Banned.self) { event in
        }
        .store(in: &subscriptions)

        charSession.subscribe(to: ConnectionEvents.ErrorOccurred.self) { event in
        }
        .store(in: &subscriptions)

        charSession.start()

        self.charSession = charSession
    }

    private func startMapSession(_ mapServer: MapServerInfo) {
        let mapSession = MapSession(storage: storage, mapServer: mapServer)

        mapSession.subscribe(to: MapEvents.Changed.self) { [unowned self] event in
            let mapName = String(event.mapName.dropLast(4))
            self.phase = .mapLoading

            Task {
                let gat = try await GameResourceManager.default.gat(forMapName: mapName)
                let gnd = try await GameResourceManager.default.gnd(forMapName: mapName)

                self.phase = .map(mapName, gat, gnd, event.position)
            }
        }
        .store(in: &subscriptions)

        mapSession.start()

        self.mapSession = mapSession
    }

//    private func loadMap(_ event: MapEvents.Changed) async throws {
//        let mapName = String(event.mapName.dropLast(4))
//
//        if let map = try await MapDatabase.renewal.map(forName: mapName),
//           let grid = map.grid() {
//            Task { @MainActor in
//                let mapScene = GameMapScene(name: mapName, grid: grid, position: event.position)
//                mapScene.positionTapHandler = { [unowned self] position in
//                    Task {
//                        if let object = await self.storage.mapObjects.values.first(where: { $0.position == position && $0.effectState != .cloak }) {
//                            self.mapSession?.talkToNPC(npcID: object.id)
//                        } else {
//                            self.mapSession?.requestMove(x: position.x, y: position.y)
//                        }
//                    }
//                }
//                self.mapScene = mapScene
//
//                mapSession?.notifyMapLoaded()
//            }
//        }
//    }
}

extension EnvironmentValues {
    @Entry var gameSession = GameSession()
}
