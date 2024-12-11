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

    var mapObjects: [UInt32 : GameMap.Object] = [:]
    var mapScene: GameMapScene?

    var npcDialog: GameNPCDialog?
    var npcMenuDialog: GameNPCMenuDialog?

    @ObservationIgnored
    private var loginSession: LoginSession?
    @ObservationIgnored
    private var charSession: CharSession?
    @ObservationIgnored
    private var mapSession: MapSession?

    @ObservationIgnored
    private var subscriptions = Set<AnyCancellable>()

    @ObservationIgnored
    private var state = ClientState()
    @ObservationIgnored
    private var charServers: [CharServerInfo] = []
    @ObservationIgnored
    private var chars: [CharInfo] = []

    func login(username: String, password: String) {
        startLoginSession()

        loginSession?.login(username: username, password: password)

        loginSession?.keepAlive(username: username)
    }

    func selectCharServer(_ charServer: CharServerInfo) {
        startCharSession(charServer)
    }

    func makeChar(char: CharInfo) {
        charSession?.makeChar(char: char)
    }

    func selectChar(slot: UInt8) {
        charSession?.selectChar(slot: slot)
    }

    func requestMove(x: Int16, y: Int16) {
        mapSession?.requestMove(x: x, y: y)
    }

    func contactNPC(npcID: UInt32) {
        mapSession?.contactNPC(npcID: npcID)
    }

    func requestNextScript(npcID: UInt32) {
        npcDialog = nil

        mapSession?.requestNextScript(npcID: npcID)
    }

    func closeDialog(npcID: UInt32) {
        npcDialog = nil

        mapSession?.closeDialog(npcID: npcID)
    }

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

            self.charServers = event.charServers

            self.phase = .charServerList(charServers)
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
            self.chars = event.chars

            self.phase = .charSelect(chars)
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
            self.chars.append(event.char)

            self.phase = .charSelect(chars)
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
            self.mapObjects.removeAll()
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
            let object = GameMap.Object(object: event.object, position: event.position)
            self.mapObjects[object.id] = object

            self.mapScene?.addObject(event.object, at: event.position)
        }
        .store(in: &subscriptions)

        mapSession.subscribe(to: MapObjectEvents.Moved.self) { [unowned self] event in
            if let object = mapObjects[event.object.id] {
                object.position = event.toPosition

                self.mapScene?.moveObject(event.object.id, from: event.fromPosition, to: event.toPosition)
            } else {
                let object = GameMap.Object(object: event.object, position: event.toPosition)
                self.mapObjects[object.id] = object

                self.mapScene?.addObject(event.object, at: event.toPosition)
            }
        }
        .store(in: &subscriptions)

        mapSession.subscribe(to: MapObjectEvents.Vanished.self) { [unowned self] event in
            self.mapObjects[event.objectID] = nil
            self.mapScene?.removeObject(event.objectID)
        }
        .store(in: &subscriptions)

        mapSession.subscribe(to: MapObjectEvents.StateChanged.self) { [unowned self] event in
            if let object = self.mapObjects[event.objectID] {
                object.bodyState = event.bodyState
                object.healthState = event.healthState
                object.effectState = event.effectState

                self.mapScene?.updateObject(event.objectID, effectState: event.effectState)
            }
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
                    if let object = self.mapObjects.values.first(where: { $0.position == position && $0.effectState != .cloak }) {
                        self.contactNPC(npcID: object.id)
                    } else {
                        self.requestMove(x: position.x, y: position.y)
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
