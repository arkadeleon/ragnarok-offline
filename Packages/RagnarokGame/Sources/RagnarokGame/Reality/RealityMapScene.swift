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

// MARK: - Event Handlers

extension RealityMapScene {
    func onPlayerMoved(startPosition: SIMD2<Int>, endPosition: SIMD2<Int>) {
        guard let playerEntity = objectEntities[player.objectID] else {
            return
        }

        let path = pathFinder.findPath(from: startPosition, to: endPosition)
        if path.count > 1 {
            playerEntity.components.set(WalkingComponent(path: path, mapGrid: mapGrid))
        }

        tileEntityManager?.updateTileEntities(forCenter: endPosition)
    }

    func onPlayerParameterChanged(_ packet: PACKET_ZC_PAR_CHANGE) {
        guard let playerEntity = objectEntities[player.objectID],
              let sp = StatusProperty(rawValue: Int(packet.varID)) else {
            return
        }

        switch sp {
        case .hp:
            playerEntity.components[HealthPointsComponent.self]?.hp = Int(packet.count)
        case .maxhp:
            playerEntity.components[HealthPointsComponent.self]?.maxHp = Int(packet.count)
        case .sp:
            playerEntity.components[SpellPointsComponent.self]?.sp = Int(packet.count)
        case .maxsp:
            playerEntity.components[SpellPointsComponent.self]?.maxSp = Int(packet.count)
        default:
            break
        }
    }

    func onPlayerHealthPointsRecovered(hp: Int, amount: Int) {
        objectEntities[player.objectID]?.components[HealthPointsComponent.self]?.hp = hp
    }

    func onPlayerSpellPointsRecovered(sp: Int, amount: Int) {
        objectEntities[player.objectID]?.components[SpellPointsComponent.self]?.sp = sp
    }

    func onMapObjectSpawned(object: MapObject, position: SIMD2<Int>, direction: Direction, headDirection: HeadDirection) {
        Task {
            let (entity, isNew) = try await spriteEntityManager.entity(for: object)
            if isNew {
                let worldPosition = mapGrid.worldPosition(for: position)
                entity.position = worldPosition
                entity.components.set(GridPositionComponent(position: position))
                entity.components.set(MapObjectComponent(object: object))
                entity.components.set(HealthPointsComponent(hp: object.hp, maxHp: object.maxHp))
                let spriteDirection = SpriteDirection(direction: direction)
                entity.playSpriteAnimation(.idle, direction: spriteDirection)
                rootEntity.addChild(entity)
            }
            objectEntities[object.objectID] = entity
        }
    }

    func onMapObjectMoved(object: MapObject, startPosition: SIMD2<Int>, endPosition: SIMD2<Int>) {
        Task {
            let (entity, isNew) = try await spriteEntityManager.entity(for: object)
            if isNew {
                let worldPosition = mapGrid.worldPosition(for: startPosition)
                entity.position = worldPosition
                entity.components.set(GridPositionComponent(position: startPosition))
                entity.components.set(MapObjectComponent(object: object))
                entity.components.set(HealthPointsComponent(hp: object.hp, maxHp: object.maxHp))
                rootEntity.addChild(entity)
            }
            objectEntities[object.objectID] = entity

            let path = pathFinder.findPath(from: startPosition, to: endPosition)
            if path.count > 1 {
                entity.components.set(WalkingComponent(path: path, mapGrid: mapGrid))
            }
        }
    }

    func onMapObjectStopped(objectID: GameObjectID, position: SIMD2<Int>) {
        guard let entity = objectEntities[objectID] else {
            return
        }

        entity.components.remove(WalkingComponent.self)
        entity.components[GridPositionComponent.self]?.position = position
        entity.position = mapGrid.worldPosition(for: position)

        let direction = entity.findEntity(named: "sprite")?.components[SpriteActionComponent.self]?.direction ?? .south
        entity.playSpriteAnimation(.idle, direction: direction)
    }

    func onMapObjectVanished(objectID: GameObjectID, type: UInt8) {
        if type == 1 && objectID == player.objectID {
            let direction = objectEntities[objectID]?.findEntity(named: "sprite")?.components[SpriteActionComponent.self]?.direction ?? .south
            objectEntities[objectID]?.playSpriteAnimation(.die, direction: direction)
        } else {
            Task {
                try? await spriteEntityManager.removeEntity(for: objectID)
                objectEntities.removeValue(forKey: objectID)
            }
        }
    }

    func onMapObjectResurrected(objectID: GameObjectID) {
        guard let entity = objectEntities[objectID] else {
            return
        }

        let direction = entity.findEntity(named: "sprite")?.components[SpriteActionComponent.self]?.direction ?? .south
        entity.playSpriteAnimation(.idle, direction: direction)
    }

    func onMapObjectDirectionChanged(objectID: GameObjectID, direction: Direction, headDirection: HeadDirection) {
        guard let entity = objectEntities[objectID] else {
            return
        }

        let spriteDirection = SpriteDirection(direction: direction)
        entity.playSpriteAnimation(.idle, direction: spriteDirection)
    }

    func onMapObjectSpriteChanged(_ packet: PACKET_ZC_SPRITE_CHANGE) {
        // MapObject is immutable; full entity reload deferred to a later phase.
    }

    func onMapObjectStateChanged(objectID: GameObjectID, bodyState: StatusChangeOption1, healthState: StatusChangeOption2, effectState: StatusChangeOption) {
        objectEntities[objectID]?.isEnabled = effectState != .cloak
    }

    func onMapObjectActionPerformed(objectAction: MapObjectAction) {
        guard let entity = objectEntities[objectAction.sourceObjectID] else {
            return
        }

        let direction = entity.findEntity(named: "sprite")?.components[SpriteActionComponent.self]?.direction ?? .south

        switch objectAction.type {
        case .sit_down:
            entity.playSpriteAnimation(.sit, direction: direction)
        case .stand_up:
            entity.playSpriteAnimation(.idle, direction: direction)
        case .pickup_item:
            entity.playSpriteAnimation(.pickup, direction: direction, nextActionType: .idle)
        case .normal, .endure, .critical, .multi_hit, .multi_hit_endure, .multi_hit_critical, .lucy_dodge:
            entity.attack(direction: direction)
        default:
            break
        }
    }

    func onMapObjectSkillPerformed(_ packet: PACKET_ZC_NOTIFY_SKILL) {
        guard let entity = objectEntities[packet.AID] else {
            return
        }

        let direction = entity.findEntity(named: "sprite")?.components[SpriteActionComponent.self]?.direction ?? .south
        entity.castSkill(direction: direction)
    }

    func onMapObjectHealthUpdated(_ packet: PACKET_ZC_HP_INFO) {
        guard let entity = objectEntities[packet.GID] else {
            return
        }

        entity.components[HealthPointsComponent.self]?.hp = Int(packet.HP)
        entity.components[HealthPointsComponent.self]?.maxHp = Int(packet.maxHP)
    }

    func onItemSpawned(item: MapItem, position: SIMD2<Int>) {
        Task {
            let itemEntity = Entity()
            itemEntity.position = mapGrid.worldPosition(for: position)
            itemEntity.components.set(GridPositionComponent(position: position))
            itemEntity.components.set(MapItemComponent(item: item))

            let spriteEntity = try await SpriteEntity(forItemID: Int(item.itemID), using: resourceManager)
            if let animation = spriteEntity.components[SpriteAnimationLibraryComponent.self]?.defaultAnimation {
                spriteEntity.setSpriteAnimation(animation)
                spriteEntity.generateModelAndCollisionShape(for: animation)
            }
            itemEntity.addChild(spriteEntity)

            rootEntity.addChild(itemEntity)
            itemEntities[item.objectID] = itemEntity
        }
    }

    func onItemVanished(objectID: GameObjectID) {
        if let entity = itemEntities.removeValue(forKey: objectID) {
            entity.removeFromParent()
        }
    }

    func onGroundSkillCast(_ packet: PACKET_ZC_NOTIFY_GROUNDSKILL) {
    }
}

#endif
