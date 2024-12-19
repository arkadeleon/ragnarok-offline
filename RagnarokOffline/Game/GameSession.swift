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
    let storage = SessionStorage()

    @MainActor
    var phase: GamePhase = .login

    @MainActor
    var mapScene: GameMapScene?

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
        let loginSession = LoginSession(storage: storage)

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
            self.phase = .map
            self.mapScene = nil

            Task {
                try await self.loadMap(event)
            }
        }
        .store(in: &subscriptions)

        mapSession.subscribe(to: PlayerEvents.Moved.self) { [unowned self] event in
            self.mapScene?.movePlayer(from: event.fromPosition, to: event.toPosition)
        }
        .store(in: &subscriptions)

        mapSession.subscribe(to: PlayerEvents.MessageReceived.self) { event in
        }
        .store(in: &subscriptions)

        // MapObjectEvents

        mapSession.subscribe(to: MapObjectEvents.Spawned.self) { [unowned self] event in
            self.mapScene?.addObject(event.object)
        }
        .store(in: &subscriptions)

        mapSession.subscribe(to: MapObjectEvents.Moved.self) { [unowned self] event in
            self.mapScene?.moveObject(event.objectID, from: event.fromPosition, to: event.toPosition)
        }
        .store(in: &subscriptions)

        mapSession.subscribe(to: MapObjectEvents.Stopped.self) { [unowned self] event in
            self.mapScene?.moveObject(event.objectID, to: event.position)
        }
        .store(in: &subscriptions)

        mapSession.subscribe(to: MapObjectEvents.Vanished.self) { [unowned self] event in
            self.mapScene?.removeObject(event.objectID)
        }
        .store(in: &subscriptions)

        mapSession.subscribe(to: MapObjectEvents.StateChanged.self) { [unowned self] event in
            self.mapScene?.updateObject(event.objectID, effectState: event.effectState)
        }
        .store(in: &subscriptions)

        mapSession.start()

        self.mapSession = mapSession
    }

    private func loadMap(_ event: MapEvents.Changed) async throws {
        let mapName = String(event.mapName.dropLast(4))

        if let map = try await MapDatabase.renewal.map(forName: mapName),
           let grid = map.grid() {
            Task { @MainActor in
                let mapScene = GameMapScene(name: mapName, grid: grid, position: event.position)
                mapScene.positionTapHandler = { [unowned self] position in
                    Task {
                        if let object = await self.storage.mapObjects.values.first(where: { $0.position == position && $0.effectState != .cloak }) {
                            self.mapSession?.talkToNPC(npcID: object.id)
                        } else {
                            self.mapSession?.requestMove(x: position.x, y: position.y)
                        }
                    }
                }
                self.mapScene = mapScene

                mapSession?.notifyMapLoaded()
            }
        }
    }
}

extension EnvironmentValues {
    @Entry var gameSession = GameSession()
}
