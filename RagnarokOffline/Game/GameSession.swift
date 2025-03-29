//
//  GameSession.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/9/5.
//

import Combine
import Observation
import ROGame
import RONetwork
import RORendering
import ROResources

enum GameScene {
    case login
    case charServerList(_ charServers: [CharServerInfo])
    case charSelect(_ chars: [CharInfo])
    case charMake(_ slot: UInt8)
    case mapLoading
    case map2D(_ scene: MapScene2D)
    case map3D(_ scene: MapScene3D)
}

@Observable
final class GameSession {
    @MainActor
    var scene: GameScene = .login

    @ObservationIgnored
    var loginSession: LoginSession?
    @ObservationIgnored
    var charSession: CharSession?
    @ObservationIgnored
    var mapSession: MapSession?

    @ObservationIgnored
    private var account: AccountInfo?

    @ObservationIgnored
    private var chars: [CharInfo] = []

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

        let loginSession = LoginSession(address: address, port: port)

        loginSession.subscribe(to: LoginEvents.Accepted.self) { [unowned self] event in
            self.account = event.account
            self.scene = .charServerList(event.charServers)
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
        guard let account else {
            return
        }

        let charSession = CharSession(account: account, charServer: charServer)

        charSession.subscribe(to: CharServerEvents.Accepted.self) { [unowned self] event in
            self.chars = event.chars
            self.scene = .charSelect(event.chars)
        }
        .store(in: &subscriptions)

        charSession.subscribe(to: CharServerEvents.Refused.self) { event in
        }
        .store(in: &subscriptions)

        charSession.subscribe(to: CharServerEvents.NotifyMapServer.self) { [unowned self] event in
            self.startMapSession(event)
        }
        .store(in: &subscriptions)

        charSession.subscribe(to: CharServerEvents.NotifyAccessibleMaps.self) { event in
        }
        .store(in: &subscriptions)

        charSession.subscribe(to: CharEvents.MakeAccepted.self) { [unowned self] event in
            self.chars.append(event.char)
            self.scene = .charSelect(chars)
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

    private func startMapSession(_ event: CharServerEvents.NotifyMapServer) {
        guard let account = charSession?.account else {
            return
        }

        let mapSession = MapSession(account: account, charID: event.charID, mapServer: event.mapServer)

        mapSession.subscribe(to: MapEvents.Changed.self) { event in
            let mapName = String(event.mapName.dropLast(4))
            self.scene = .mapLoading

            Task {
                let worldPath: ResourcePath = ["data", mapName]
                let world = try await ResourceManager.default.world(at: worldPath)

//                let scene = MapScene2D(mapName: mapName, world: world, position: event.position)
//                scene.mapSceneDelegate = self
//                self.scene = .map2D(scene)

                let scene = MapScene3D(mapName: mapName, world: world, position: event.position)
                scene.mapSceneDelegate = self
                self.scene = .map3D(scene)
            }
        }
        .store(in: &subscriptions)

        mapSession.start()

        self.mapSession = mapSession
    }
}

extension GameSession: MapSceneDelegate {
    func mapSceneDidFinishLoading(_ scene: any MapSceneProtocol) {
        mapSession?.notifyMapLoaded()
    }

    func mapScene(_ scene: any MapSceneProtocol, didTapTileAt position: SIMD2<Int16>) {
        mapSession?.requestMove(x: position.x, y: position.y)
    }

    func mapScene(_ scene: any MapSceneProtocol, didTapMapObjectWith objectID: UInt32) {
        mapSession?.talkToNPC(npcID: objectID)
    }
}
