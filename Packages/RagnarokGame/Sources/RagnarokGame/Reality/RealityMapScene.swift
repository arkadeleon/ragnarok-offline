//
//  RealityMapScene.swift
//  RagnarokGame
//
//  Created by Leon Li on 2026/5/30.
//

import AVFAudio
import CoreGraphics
import Foundation
import RagnarokCore
import RagnarokModels
import RagnarokReality
import RagnarokRenderAssets
import RagnarokResources
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
    var tileEntityManager: TileEntityManager?
    let tileSelectionRenderer: RealityTileSelectionRenderer

    let pathFinder: PathFinder

    let resourceManager: ResourceManager

    var objectEntities: [GameObjectID : Entity] = [:]
    var itemEntities: [GameObjectID : Entity] = [:]

    var soundEffectResourceCache: [String : AudioBufferResource] = [:]
    var soundEffectLoadTasks: [String : Task<AudioBufferResource?, Never>] = [:]

    private var currentPlayerGridPosition: SIMD2<Int>? {
        objectEntities[player.objectID]?.components[GridPositionComponent.self]?.position
    }

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

    public func load(progress: Progress) async throws {
        let worldAssetLoader = WorldAssetLoader()
        let worldAsset = try await worldAssetLoader.load(
            world: world,
            resourceManager: resourceManager,
            progress: progress
        )

        let worldEntity = try await Entity(from: worldAsset)
        worldEntity.name = mapName
        worldEntity.transform = Transform(rotation: simd_quatf(angle: radians(-180), axis: [1, 0, 0]))
        await playBGM(on: worldEntity)
        rootEntity.addChild(worldEntity)

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
            playerEntity.position = renderPosition(for: mapGrid.worldPosition(for: playerPosition))
            playerEntity.components.set(GridPositionComponent(position: playerPosition))
            playerEntity.components.set(MapObjectComponent(object: player))
            playerEntity.components.set(HealthPointsComponent(hp: character.hp, maxHp: character.maxHp))
            playerEntity.components.set(SpellPointsComponent(sp: character.sp, maxSp: character.maxSp))
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

        for task in soundEffectLoadTasks.values { task.cancel() }
        soundEffectLoadTasks.removeAll()
        soundEffectResourceCache.removeAll()
    }

    func renderPosition(for worldPosition: SIMD3<Float>) -> SIMD3<Float> {
        [
            worldPosition.x + 0.5,
            worldPosition.z,
            -worldPosition.y - 0.5,
        ]
    }

    func handleInteraction(_ result: GameHitTestResult) {
        switch result {
        case .ground(let position):
            selectGround(at: position)
        case .mapObject(let objectID):
            handleMapObjectInteraction(objectID: objectID)
        case .mapItem(let objectID):
            handleMapItemInteraction(objectID: objectID)
        }
    }

    func selectGround(at position: SIMD2<Int>) {
        objectEntities[player.objectID]?.components.remove(LockOnComponent.self)
        tileSelectionRenderer.showSelection(at: position, in: mapGrid)
        gameSession?.requestMove(to: position)
    }

    private func handleMapObjectInteraction(objectID: GameObjectID) {
        guard let entity = objectEntities[objectID],
              let object = entity.components[MapObjectComponent.self]?.object else {
            return
        }

        switch object.type {
        case .monster:
            guard let targetPosition = entity.components[GridPositionComponent.self]?.position else {
                return
            }
            movePlayerToward(targetPosition: targetPosition, within: 1) {
                self.gameSession?.requestAction(._repeat, onTarget: objectID)
            }
        case .npc:
            gameSession?.talkToNPC(npcID: objectID)
        default:
            break
        }
    }

    private func handleMapItemInteraction(objectID: GameObjectID) {
        guard let entity = itemEntities[objectID],
              let targetPosition = entity.components[GridPositionComponent.self]?.position else {
            gameSession?.pickUpItem(objectID: objectID)
            return
        }

        movePlayerToward(targetPosition: targetPosition, within: 1) {
            self.gameSession?.pickUpItem(objectID: objectID)
        }
    }

    private func movePlayerToward(targetPosition: SIMD2<Int>, within range: Int, onArrival: @escaping @MainActor () -> Void) {
        let startPosition = currentPlayerGridPosition ?? playerPosition
        let path = pathFinder.findPath(from: startPosition, to: targetPosition, within: range)

        if path == [startPosition] {
            onArrival()
        } else if path.count > 1 {
            objectEntities[player.objectID]?.components.set(LockOnComponent(action: onArrival))
            gameSession?.requestMove(to: path.last ?? targetPosition)
        }
    }

    private func setupWorldCamera(target: Entity) {
        let elevationBounds: ClosedRange<Float> = radians(15)...radians(60)

        var worldCameraComponent = WorldCameraComponent(
            azimuth: 0,
            elevation: .pi / 12,
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

        LockOnComponent.registerComponent()
        LockOnSystem.registerSystem()
        WalkingComponent.registerComponent()
        WalkingSystem.registerSystem()
        TileComponent.registerComponent()

        SpriteActionComponent.registerComponent()
        SpriteActionSystem.registerSystem()
        SpriteAnimationComponent.registerComponent()
        SpriteAnimationLibraryComponent.registerComponent()
        SpriteAnimationSystem.registerSystem()
        SpriteBillboardComponent.registerComponent()
        SpriteBillboardSystem.registerSystem()

        CombatTextComponent.registerComponent()
        CombatTextSystem.registerSystem()

        PlaySpriteAnimationAction.registerAction()
        PlaySpriteAnimationActionHandler.register { _ in
            PlaySpriteAnimationActionHandler()
        }
    }
}
