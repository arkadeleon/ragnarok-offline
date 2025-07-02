//
//  GameSession.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/9/5.
//

import Combine
import Observation
import ROConstants
import RONetwork
import ROPackets
import RORendering
import ROResources

@MainActor
@Observable
final public class GameSession {
    public enum Phase {
        case login
        case charServerList(_ charServers: [CharServerInfo])
        case charSelect(_ chars: [CharInfo])
        case charMake(_ slot: UInt8)
        case mapLoading
        case map(_ scene: any MapSceneProtocol)
    }

    public private(set) var phase: GameSession.Phase = .login

    public private(set) var account: AccountInfo?

    public private(set) var chars: [CharInfo] = []

    public private(set) var char: CharInfo?

    public private(set) var status: CharacterStatus?

    public private(set) var inventory = Inventory()

    public private(set) var dialog: NPCDialog?

    @ObservationIgnored
    private var resourceManager: ResourceManager?

    @ObservationIgnored
    private var scriptManager: ScriptManager?

    @ObservationIgnored
    var loginSession: LoginSession?
    @ObservationIgnored
    var charSession: CharSession?
    @ObservationIgnored
    var mapSession: MapSession?

    @ObservationIgnored
    private var subscriptions = Set<AnyCancellable>()

    public init() {
    }

    // MARK: - Public

    public func start(resourceManager: ResourceManager, scriptManager: ScriptManager) {
        self.resourceManager = resourceManager
        self.scriptManager = scriptManager
    }

    public func login(serverAddress: String, serverPort: String, username: String, password: String) {
        startLoginSession(serverAddress: serverAddress, serverPort: serverPort)

        loginSession?.login(username: username, password: password)

        loginSession?.keepAlive(username: username)
    }

    public func selectCharServer(_ charServer: CharServerInfo) {
        startCharSession(charServer)
    }

    public func selectChar(char: CharInfo) {
        if let charSession {
            charSession.selectChar(slot: char.slot)
        }
    }

    public func makeChar(slot: UInt8) {
        phase = .charMake(slot)
    }

    public func makeChar(char: CharInfo) {
        if let charSession {
            charSession.makeChar(char: char)
        }
    }

    public func incrementStatusProperty(_ sp: StatusProperty) {
        if let mapSession {
            mapSession.incrementStatusProperty(sp, by: 1)
        }
    }

    public func useItem(_ item: InventoryItem) {
        if let mapSession {
            let accountID = mapSession.account.accountID
            mapSession.useItem(at: item.index, by: accountID)
        }
    }

    public func equipItem(_ item: InventoryItem) {
        if let mapSession {
            mapSession.equipItem(at: item.index, location: item.location)
        }
    }

    public func sendMessage(_ message: String) {
        if let mapSession {
            mapSession.sendMessage(message)
        }
    }

    // MARK: - NPC

    public func requestNextMessage() {
        guard let mapSession, let dialog else {
            return
        }

        Task {
            try await Task.sleep(for: .milliseconds(1))
            mapSession.requestNextMessage(objectID: dialog.objectID)
        }

        self.dialog = nil
    }

    public func closeDialog() {
        guard let mapSession, let dialog else {
            return
        }

        Task {
            try await Task.sleep(for: .milliseconds(1))
            mapSession.closeDialog(objectID: dialog.objectID)
        }

        self.dialog = nil
    }

    public func selectMenu(select: UInt8) {
        guard let mapSession, let dialog else {
            return
        }

        Task {
            try await Task.sleep(for: .milliseconds(1))
            mapSession.selectMenu(objectID: dialog.objectID, select: select)
        }

        self.dialog = nil
    }

    // MARK: - Private

    private func startLoginSession(serverAddress: String, serverPort: String) {
        guard let serverPort = UInt16(serverPort) else {
            return
        }

        let loginSession = LoginSession(address: serverAddress, port: serverPort)

        loginSession.subscribe(to: LoginEvents.Accepted.self) { [unowned self] event in
            self.account = event.account
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
        guard let account else {
            return
        }

        let charSession = CharSession(account: account, charServer: charServer)

        charSession.subscribe(to: CharServerEvents.Accepted.self) { [unowned self] event in
            self.chars = event.chars
            self.phase = .charSelect(event.chars)
        }
        .store(in: &subscriptions)

        charSession.subscribe(to: CharServerEvents.Refused.self) { event in
        }
        .store(in: &subscriptions)

        charSession.subscribe(to: CharServerEvents.NotifyMapServer.self) { [unowned self] event in
            if let char = self.chars.first(where: { $0.charID == event.charID }) {
                self.char = char
                self.startMapSession(char: char, mapServer: event.mapServer)
            }
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

    private func startMapSession(char: CharInfo, mapServer: MapServerInfo) {
        guard let account = charSession?.account, let resourceManager, let scriptManager else {
            return
        }

        let mapSession = MapSession(account: account, char: char, mapServer: mapServer)

        mapSession.subscribe(to: MapEvents.Changed.self) { event in
            self.phase = .mapLoading

            Task {
                let mapName = String(event.mapName.dropLast(4))
                let worldPath: ResourcePath = ["data", mapName]
                let world = try await resourceManager.world(at: worldPath)

                let player = MapObject(account: account, char: char)

//                let scene = MapScene2D(
//                    mapName: mapName,
//                    world: world,
//                    player: player,
//                    playerPosition: event.position
//                )

                let scene = MapScene3D(
                    mapName: mapName,
                    world: world,
                    player: player,
                    playerPosition: event.position,
                    resourceManager: resourceManager,
                    scriptManager: scriptManager
                )

                scene.mapSceneDelegate = self

                self.prepareMapScene(scene)
                self.phase = .map(scene)
            }
        }
        .store(in: &subscriptions)

        mapSession.subscribe(to: PlayerEvents.StatusChanged.self) { [unowned self] event in
            self.status = event.status
        }
        .store(in: &subscriptions)

        mapSession.subscribe(to: ItemEvents.ListReceived.self) { [unowned self] event in
            self.inventory = event.inventory
        }
        .store(in: &subscriptions)

        mapSession.subscribe(to: ItemEvents.ListUpdated.self) { [unowned self] event in
            self.inventory = event.inventory
        }
        .store(in: &subscriptions)

        mapSession.subscribe(to: NPCEvents.DialogReceived.self) { [unowned self] event in
            dialog = event.dialog
        }
        .store(in: &subscriptions)

        mapSession.subscribe(to: NPCEvents.DialogClosed.self) { [unowned self] event in
            dialog = nil
        }
        .store(in: &subscriptions)

        mapSession.start()

        self.mapSession = mapSession
    }

    private func prepareMapScene(_ scene: any MapSceneProtocol) {
        guard let mapSession else {
            return
        }

        mapSession.subscribe(to: PlayerEvents.Moved.self) { event in
            scene.onPlayerMoved(event)
        }
        .store(in: &subscriptions)

        mapSession.subscribe(to: ItemEvents.Spawned.self) { event in
            scene.onItemSpawned(event)
        }
        .store(in: &subscriptions)

        mapSession.subscribe(to: ItemEvents.Vanished.self) { event in
            scene.onItemVanished(event)
        }
        .store(in: &subscriptions)

        mapSession.subscribe(to: MapObjectEvents.Spawned.self) { event in
            scene.onMapObjectSpawned(event)
        }
        .store(in: &subscriptions)

        mapSession.subscribe(to: MapObjectEvents.Moved.self) { event in
            scene.onMapObjectMoved(event)
        }
        .store(in: &subscriptions)

        mapSession.subscribe(to: MapObjectEvents.Stopped.self) { event in
            scene.onMapObjectStopped(event)
        }
        .store(in: &subscriptions)

        mapSession.subscribe(to: MapObjectEvents.Vanished.self) { event in
            scene.onMapObjectVanished(event)
        }
        .store(in: &subscriptions)

        mapSession.subscribe(to: MapObjectEvents.StateChanged.self) { event in
            scene.onMapObjectStateChanged(event)
        }
        .store(in: &subscriptions)

        mapSession.subscribe(to: MapObjectEvents.ActionPerformed.self) { event in
            scene.onMapObjectActionPerformed(event)
        }
        .store(in: &subscriptions)
    }
}

extension GameSession: MapSceneDelegate {
    func mapSceneDidFinishLoading(_ scene: any MapSceneProtocol) {
        mapSession?.notifyMapLoaded()
    }

    func mapScene(_ scene: any MapSceneProtocol, didTapTileAt position: SIMD2<Int>) {
        mapSession?.requestMove(to: position)
    }

    func mapScene(_ scene: any MapSceneProtocol, didTapMapObject object: MapObject) {
        switch object.type {
        case .monster:
            mapSession?.requestAction(._repeat, onTarget: object.objectID)
        case .npc:
            mapSession?.talkToNPC(objectID: object.objectID)
        default:
            break
        }
    }

    func mapScene(_ scene: any MapSceneProtocol, didTapMapObjectWith objectID: UInt32) {
        mapSession?.talkToNPC(objectID: objectID)
    }

    func mapScene(_ scene: any MapSceneProtocol, didTapMapItem item: MapItem) {
        mapSession?.pickUpItem(objectID: item.objectID)
    }
}
