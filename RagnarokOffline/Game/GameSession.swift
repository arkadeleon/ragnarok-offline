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
    case charServerList
    case charSelect
    case charMake(_ slot: UInt8)
    case map
}

@Observable
final class GameSession {
    @MainActor
    var phase: GamePhase = .login

    @MainActor
    var mapScene: GameMapScene?

    @MainActor
    var npcDialog: GameNPCDialog?
    @MainActor
    var npcMenuDialog: GameNPCMenuDialog?

    @ObservationIgnored
    var loginSession: LoginSession?
    @ObservationIgnored
    var charSession: CharSession?
    @ObservationIgnored
    var mapSession: MapSession?

    @ObservationIgnored
    private var subscriptions = Set<AnyCancellable>()

    @ObservationIgnored
    private var state = ClientState()

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

    @MainActor
    func requestNextScript(npcID: UInt32) {
        npcDialog = nil

        mapSession?.requestNextScript(npcID: npcID)
    }

    @MainActor
    func closeDialog(npcID: UInt32) {
        npcDialog = nil

        mapSession?.closeDialog(npcID: npcID)
    }

    @MainActor
    func selectMenu(npcID: UInt32, select: UInt8) {
        npcMenuDialog = nil

        mapSession?.selectMenu(npcID: npcID, select: select)
    }

    private func startLoginSession() {
        let loginSession = LoginSession()

        loginSession.subscribe(to: LoginEvents.Accepted.self) { [unowned self] event in
            self.state.accountID = event.accountID
            self.state.loginID1 = event.loginID1
            self.state.loginID2 = event.loginID2
            self.state.sex = event.sex

            self.phase = .charServerList
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
        let charSession = CharSession(state: state, charServer: charServer)

        charSession.subscribe(to: CharServerEvents.Accepted.self) { [unowned self] event in
            self.phase = .charSelect
        }
        .store(in: &subscriptions)

        charSession.subscribe(to: CharServerEvents.Refused.self) { event in
        }
        .store(in: &subscriptions)

        charSession.subscribe(to: CharServerEvents.NotifyMapServer.self) { [unowned self] event in
            self.state.charID = event.charID

            self.startMapSession(event.mapServer)
        }
        .store(in: &subscriptions)

        charSession.subscribe(to: CharServerEvents.NotifyAccessibleMaps.self) { event in
        }
        .store(in: &subscriptions)

        charSession.subscribe(to: CharEvents.MakeAccepted.self) { [unowned self] event in
            self.phase = .charSelect
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
        let mapSession = MapSession(state: state, mapServer: mapServer)

        mapSession.subscribe(to: MapEvents.Changed.self) { [unowned self] event in
            self.phase = .map
            self.mapScene = nil
            self.npcDialog = nil
            self.npcMenuDialog = nil

            Task { [self] in
                try await self.loadMap(event)
            }
        }
        .store(in: &subscriptions)

        mapSession.subscribe(to: PlayerEvents.Moved.self) { [unowned self] event in
            self.mapScene?.movePlayer(from: event.fromPosition, to: event.toPosition)
        }
        .store(in: &subscriptions)

        mapSession.subscribe(to: PlayerEvents.MessageDisplay.self) { event in
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

        mapSession.subscribe(to: MapObjectEvents.Vanished.self) { [unowned self] event in
            self.mapScene?.removeObject(event.objectID)
        }
        .store(in: &subscriptions)

        mapSession.subscribe(to: MapObjectEvents.StateChanged.self) { [unowned self] event in
            self.mapScene?.updateObject(event.objectID, effectState: event.effectState)
        }
        .store(in: &subscriptions)

        // NPCEvents

        mapSession.subscribe(to: NPCEvents.DisplayDialog.self) { [unowned self] event in
            if let npcDialog, npcDialog.npcID == event.npcID {
                npcDialog.message.append("\n")
                npcDialog.message.append(event.message)
            } else {
                let npcDialog = GameNPCDialog(npcID: event.npcID, message: event.message)
                self.npcDialog = npcDialog
            }
        }
        .store(in: &subscriptions)

        mapSession.subscribe(to: NPCEvents.AddNextButton.self) { [unowned self] event in
            if let npcDialog, npcDialog.npcID == event.npcID {
                npcDialog.showsNextButton = true
            }
        }
        .store(in: &subscriptions)

        mapSession.subscribe(to: NPCEvents.AddCloseButton.self) { [unowned self] event in
            if let npcDialog, npcDialog.npcID == event.npcID {
                npcDialog.showsCloseButton = true
            }
        }
        .store(in: &subscriptions)

        mapSession.subscribe(to: NPCEvents.DisplayMenuDialog.self) { [unowned self] event in
            self.npcDialog = nil
            self.npcMenuDialog = GameNPCMenuDialog(npcID: event.npcID, items: event.items)
        }
        .store(in: &subscriptions)

        mapSession.start()

        self.mapSession = mapSession
    }

    private func loadMap(_ event: MapEvents.Changed) async throws {
        let mapName = String(event.mapName.dropLast(4))

        if let map = try await MapDatabase.renewal.map(forName: mapName),
           let grid = map.grid() {
            await MainActor.run {
                let mapScene = GameMapScene(name: mapName, grid: grid, position: event.position)
                mapScene.positionTapHandler = { [unowned self] position in
                    if let object = self.mapSession?.objects.values.first(where: { $0.position == position && $0.effectState != .cloak }) {
                        self.mapSession?.contactNPC(npcID: object.id)
                    } else {
                        self.mapSession?.requestMove(x: position.x, y: position.y)
                    }
                }
                self.mapScene = mapScene
            }
        }

        mapSession?.notifyMapLoaded()
    }
}

extension EnvironmentValues {
    @Entry var gameSession = GameSession()
}
