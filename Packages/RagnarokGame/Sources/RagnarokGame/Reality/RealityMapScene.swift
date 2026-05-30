//
//  RealityMapScene.swift
//  RagnarokGame
//
//  Created by Leon Li on 2026/5/30.
//

#if os(visionOS)

import AVFAudio
import CoreGraphics
import Foundation
import RagnarokConstants
import RagnarokCore
import RagnarokModels
import RagnarokPackets
import RagnarokRealityRendering
import RagnarokRenderAssets
import RagnarokResources
import RagnarokSprite
import RealityKit
import Spatial
import WorldCamera

public final class RealityMapScene: GameMapScene {
    public let mapName: String
    let world: WorldResource
    let character: CharacterInfo
    let player: MapObject
    let playerPosition: SIMD2<Int>
    let mapGrid: MapGrid
    weak var gameSession: GameSession?

    let rootEntity = Entity()

    private let worldCameraEntity = Entity()

    let spriteEntityManager: SpriteEntityManager
    private var tileEntityManager: TileEntityManager?
    private let tileSelectionRenderer: RealityTileSelectionRenderer

    let pathFinder: PathFinder

    private let resourceManager: ResourceManager

    var cameraState: MapCameraState = .default

    private(set) var objectEntities: [GameObjectID : Entity] = [:]
    private(set) var itemEntities: [GameObjectID : Entity] = [:]

    init(
        mapName: String,
        world: WorldResource,
        character: CharacterInfo,
        player: MapObject,
        playerPosition: SIMD2<Int>,
        resourceManager: ResourceManager,
        gameSession: GameSession
    ) {
        self.mapName = mapName
        self.world = world
        self.character = character
        self.player = player
        self.playerPosition = playerPosition
        self.resourceManager = resourceManager
        self.gameSession = gameSession

        self.mapGrid = MapGrid(gat: world.gat)
        self.pathFinder = PathFinder(mapGrid: self.mapGrid)
        self.spriteEntityManager = SpriteEntityManager(resourceManager: resourceManager)
        self.tileSelectionRenderer = RealityTileSelectionRenderer(resourceManager: resourceManager)

        registerComponents()
        rootEntity.addChild(tileSelectionRenderer.entity)
    }

    public func load(progress: Progress) async {
        if let worldEntity = try? await Entity(from: world, resourceManager: resourceManager, progress: progress) {
            worldEntity.name = mapName
            worldEntity.transform = Transform(rotation: simd_quatf(angle: radians(-180), axis: [1, 0, 0]))
            await playBGM(on: worldEntity)
            rootEntity.addChild(worldEntity)
        }

        let skyboxConfiguration = SkyboxConfiguration.generate(
            light: world.rsw.light,
            mapWidth: mapGrid.width,
            mapHeight: mapGrid.height
        )
        if let skyboxEntity = try? await SkyboxEntity(configuration: skyboxConfiguration) {
            skyboxEntity.name = "skybox"
            rootEntity.addChild(skyboxEntity)
        }

        let tileEntityManager = TileEntityManager(mapGrid: mapGrid, rootEntity: rootEntity)
        tileEntityManager.addTileEntities(forCenter: playerPosition)
        self.tileEntityManager = tileEntityManager

        await tileSelectionRenderer.prepare()

        setupLighting()

        do {
            let (playerEntity, _) = try await spriteEntityManager.entity(for: player)
            let worldPosition = mapGrid.worldPosition(for: playerPosition)
            playerEntity.position = worldPosition
            playerEntity.components.set(GridPositionComponent(position: playerPosition))
            playerEntity.components.set(MapObjectComponent(object: player))
            rootEntity.addChild(playerEntity)
            objectEntities[player.objectID] = playerEntity
            setupWorldCamera(target: playerEntity)
        } catch {
            logger.warning("\(error)")
        }
    }

    public func unload() {
        if let worldEntity = rootEntity.findEntity(named: mapName) {
            worldEntity.stopAllAudio()
        }

        tileSelectionRenderer.hideSelection()
        worldCameraEntity.removeFromParent()

        for child in Array(rootEntity.children) where child !== tileSelectionRenderer.entity {
            child.stopAllAudio()
            child.removeFromParent()
        }

        objectEntities.removeAll()
        itemEntities.removeAll()
        tileEntityManager = nil
    }

    func handleInteraction(_ result: GameHitTestResult) {
        switch result {
        case .ground(let position):
            selectGround(at: position)
        case .mapObject(let objectID):
            gameSession?.requestAction(._repeat, onTarget: objectID)
        case .mapItem(let objectID):
            gameSession?.pickUpItem(objectID: objectID)
        }
    }

    func selectGround(at position: SIMD2<Int>) {
        tileSelectionRenderer.showSelection(at: position, in: mapGrid)
        gameSession?.requestMove(to: position)
    }

    private func setupWorldCamera(target: Entity) {
        let elevationBounds: ClosedRange<Float> = radians(15)...radians(60)

        var worldCameraComponent = WorldCameraComponent(
            azimuth: cameraState.azimuth,
            elevation: cameraState.elevation,
            radius: 15,
            bounds: WorldCameraComponent.CameraBounds(elevation: elevationBounds)
        )
        worldCameraComponent.targetOffset = [0, -0.75, 0]

        let followComponent = FollowComponent(targetId: target.id, smoothing: [3, 1.2, 3])

        worldCameraEntity.components.set([worldCameraComponent, followComponent])
        worldCameraEntity.name = "camera"

        let simulationEntity = PhysicsSimulationComponent.nearestSimulationEntity(for: target)
        let parentEntity = simulationEntity ?? target.parent
        worldCameraEntity.setParent(parentEntity)
        worldCameraEntity.position = target.position(relativeTo: parentEntity)
    }

    private func setupLighting() {
        let lightEntity = Entity()
        lightEntity.name = "light"

        let diffuse = [
            world.rsw.light.diffuseRed,
            world.rsw.light.diffuseGreen,
            world.rsw.light.diffuseBlue,
        ]
        let lightColor = DirectionalLightComponent.Color(
            red: CGFloat(diffuse[0]),
            green: CGFloat(diffuse[1]),
            blue: CGFloat(diffuse[2]),
            alpha: 1
        )
        let lightComponent = DirectionalLightComponent(color: lightColor, intensity: 3000)
        let lightShadowComponent = DirectionalLightComponent.Shadow(maximumDistance: 150)
        lightEntity.components.set([lightComponent, lightShadowComponent])

        let longitude = radians(Double(world.rsw.light.longitude))
        let latitude = radians(Double(world.rsw.light.latitude))

        let target: SIMD3<Float> = [0, 0, 0]
        var lightPosition: SIMD3<Float> = [0, 1, 0]
        var point = Point3D(lightPosition)
        point = point.rotated(by: simd_quatd(angle: latitude, axis: [1, 0, 0]), around: Point3D(target))
        point = point.rotated(by: simd_quatd(angle: longitude, axis: [0, 0, 1]), around: Point3D(target))
        lightPosition = SIMD3(point)

        lightEntity.look(at: target, from: lightPosition, relativeTo: nil)
        rootEntity.addChild(lightEntity)
    }

    private func playBGM(on worldEntity: Entity) async {
        let mp3NameTable = await resourceManager.mp3NameTable()
        guard let mp3Name = mp3NameTable.mp3Name(forMapName: mapName) else {
            return
        }

        let bgmPath = ResourcePath(components: ["BGM", mp3Name])
        guard let bgmData = try? await resourceManager.contentsOfResource(at: bgmPath) else {
            return
        }

        guard let audioBuffer = AVAudioPCMBuffer.load(from: bgmData) else {
            return
        }

        guard let audioResource = try? AudioBufferResource(
            buffer: audioBuffer,
            configuration: AudioBufferResource.Configuration(shouldLoop: true)
        ) else {
            return
        }

        worldEntity.components.set(AudioLibraryComponent(resources: ["BGM": audioResource]))
        worldEntity.components.set(AmbientAudioComponent())
        worldEntity.playAudio(audioResource)
    }

    private func registerComponents() {
        GridPositionComponent.registerComponent()
        MapObjectComponent.registerComponent()
        MapItemComponent.registerComponent()
        HealthPointsComponent.registerComponent()
        SpellPointsComponent.registerComponent()

        WalkingComponent.registerComponent()
        WalkingSystem.registerSystem()
        TileComponent.registerComponent()

        SpriteActionComponent.registerComponent()
        SpriteActionSystem.registerSystem()
        SpriteAnimationComponent.registerComponent()
        SpriteAnimationTimingComponent.registerComponent()
        SpriteAnimationLibraryComponent.registerComponent()
        SpriteAnimationSystem.registerSystem()
        SpriteBillboardComponent.registerComponent()
        SpriteBillboardSystem.registerSystem()

        PlaySpriteAnimationAction.registerAction()
        PlaySpriteAnimationActionHandler.register { _ in
            PlaySpriteAnimationActionHandler()
        }
    }
}

// MARK: - Event Handlers (Phase 6+ will implement)

extension RealityMapScene {
    func onPlayerMoved(startPosition: SIMD2<Int>, endPosition: SIMD2<Int>) {
    }

    func onPlayerParameterChanged(_ packet: PACKET_ZC_PAR_CHANGE) {
    }

    func onPlayerHealthPointsRecovered(hp: Int, amount: Int) {
    }

    func onPlayerSpellPointsRecovered(sp: Int, amount: Int) {
    }

    func onMapObjectSpawned(object: MapObject, position: SIMD2<Int>, direction: Direction, headDirection: HeadDirection) {
    }

    func onMapObjectMoved(object: MapObject, startPosition: SIMD2<Int>, endPosition: SIMD2<Int>) {
    }

    func onMapObjectStopped(objectID: GameObjectID, position: SIMD2<Int>) {
    }

    func onMapObjectVanished(objectID: GameObjectID, type: UInt8) {
    }

    func onMapObjectResurrected(objectID: GameObjectID) {
    }

    func onMapObjectDirectionChanged(objectID: GameObjectID, direction: Direction, headDirection: HeadDirection) {
    }

    func onMapObjectSpriteChanged(_ packet: PACKET_ZC_SPRITE_CHANGE) {
    }

    func onMapObjectStateChanged(objectID: GameObjectID, bodyState: StatusChangeOption1, healthState: StatusChangeOption2, effectState: StatusChangeOption) {
    }

    func onMapObjectActionPerformed(objectAction: MapObjectAction) {
    }

    func onMapObjectSkillPerformed(_ packet: PACKET_ZC_NOTIFY_SKILL) {
    }

    func onMapObjectHealthUpdated(_ packet: PACKET_ZC_HP_INFO) {
    }

    func onItemSpawned(item: MapItem, position: SIMD2<Int>) {
    }

    func onItemVanished(objectID: GameObjectID) {
    }

    func onGroundSkillCast(_ packet: PACKET_ZC_NOTIFY_GROUNDSKILL) {
    }
}

#endif
