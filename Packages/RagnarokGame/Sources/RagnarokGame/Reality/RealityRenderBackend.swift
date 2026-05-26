//
//  RealityRenderBackend.swift
//  RagnarokGame
//
//  Created by Leon Li on 2026/3/21.
//

import CoreGraphics
import Foundation
import RagnarokConstants
import RagnarokCore
import RagnarokModels
import RagnarokRealityRendering
import RagnarokRenderAssets
import RagnarokResources
import RagnarokSprite
import RealityKit
import Spatial
import SwiftUI
import WorldCamera

final class RealityRenderBackend: GameRenderBackend {
    weak var scene: MapScene?

    let resourceManager: ResourceManager

    let rootEntity = Entity()
    let entityCache: RealityEntityCache
    let audioPlayer: RealityMapAudioPlayer

    private let tileSelectionRenderer: RealityTileSelectionRenderer
    private let sampler = MapObjectPresentationSampler()

    private let worldCameraEntity = Entity()
    private var snapshotTask: Task<Void, Never>?
    private var tileEntities: [SIMD2<Int>: Entity] = [:]
    private let tileRange = 17

    #if os(iOS) || os(macOS)
    weak var arView: ARView?
    private var anchorEntity: AnchorEntity?
    #endif

    init(resourceManager: ResourceManager) {
        self.resourceManager = resourceManager
        self.entityCache = RealityEntityCache(resourceManager: resourceManager)
        self.audioPlayer = RealityMapAudioPlayer(resourceManager: resourceManager, entityCache: entityCache)
        self.tileSelectionRenderer = RealityTileSelectionRenderer(resourceManager: resourceManager)

        registerRealityComponents()
        rootEntity.addChild(tileSelectionRenderer.entity)
    }

    func attach(scene: MapScene) {
        self.scene = scene
    }

    func detach() {
        audioPlayer.stopSoundEffects()
        teardownSceneState()
        scene = nil
        #if os(iOS) || os(macOS)
        arView = nil
        anchorEntity?.removeFromParent()
        anchorEntity = nil
        #endif
    }

    func load(progress: Progress) async {
        guard let scene else {
            return
        }

        teardownSceneState()

        let worldEntity = try? await Entity(from: scene.world, resourceManager: scene.resourceManager, progress: progress)
        if let worldEntity {
            worldEntity.name = scene.mapName
            worldEntity.transform = Transform(rotation: simd_quatf(angle: radians(-180), axis: [1, 0, 0]))

            await audioPlayer.playBGM(forMapName: scene.mapName, on: worldEntity)

            rootEntity.addChild(worldEntity)
        }

        let skyboxConfiguration = SkyboxConfiguration.generate(
            light: scene.world.rsw.light,
            mapWidth: scene.mapGrid.width,
            mapHeight: scene.mapGrid.height
        )
        let skyboxEntity = try? await SkyboxEntity(configuration: skyboxConfiguration)
        if let skyboxEntity {
            skyboxEntity.name = "skybox"
            rootEntity.addChild(skyboxEntity)
        }

        updateTileEntities(forCenter: scene.playerPosition, mapGrid: scene.mapGrid)

        await tileSelectionRenderer.prepare()

        let player = scene.state.player
        let playerEntity = entityCache.objectEntity(for: player)
        playerEntity.name = "\(player.objectID)"
        playerEntity.transform = Transform(translation: scene.mapGrid.worldPosition(for: scene.playerPosition))
        playerEntity.isEnabled = player.effectState != .cloak
        playerEntity.components.set([
            GridPositionComponent(gridPosition: scene.playerPosition),
            MapSceneObjectComponent(object: player),
        ])
        rootEntity.addChild(playerEntity)
        loadObjectSpriteEntity(for: player, parent: playerEntity)

        setupWorldCamera(target: playerEntity, cameraState: scene.cameraState)

        setupLighting(world: scene.world)
    }

    func unload() {
        if let scene,
           let worldEntity = rootEntity.findEntity(named: scene.mapName) {
            worldEntity.stopAllAudio()
        }

        audioPlayer.stopSoundEffects()
        teardownSceneState()
    }

    func applySnapshot(_ state: MapSceneState) {
        guard let scene else {
            return
        }

        updateCameraState(scene.cameraState)
        updateTileEntities(forCenter: state.player.gridPosition, mapGrid: scene.mapGrid)

        snapshotTask?.cancel()
        snapshotTask = Task { @MainActor [weak self, weak scene] in
            guard let self, let scene else {
                return
            }
            await syncEntities(with: state, scene: scene)
        }
    }

    func showSelection(at position: SIMD2<Int>, mapGrid: MapGrid) {
        tileSelectionRenderer.showSelection(at: position, in: mapGrid)
    }

    func addCombatText(_ combatText: MapSceneCombatText) {
        let combatTextEntity = Entity.makeCombatTextEntity(for: combatText)
        combatTextEntity.setParent(rootEntity)
    }

    func addEffect(_ effect: MapSceneEffect) {
    }

    func playSound(named soundName: String, on objectID: GameObjectID) {
        audioPlayer.playSound(named: soundName, on: objectID)
    }

    func updateCameraState(_ cameraState: MapCameraState) {
        worldCameraEntity.components[WorldCameraComponent.self]?.azimuth = cameraState.azimuth
        #if !os(visionOS)
        worldCameraEntity.components[WorldCameraComponent.self]?.elevation = cameraState.elevation
        #endif
        worldCameraEntity.components[WorldCameraComponent.self]?.radius = cameraState.distance
    }

    #if os(iOS) || os(macOS)
    func configure(arView: ARView) {
        if anchorEntity == nil {
            let anchorEntity = AnchorEntity(world: .zero)
            anchorEntity.addChild(rootEntity)
            self.anchorEntity = anchorEntity
        }

        if let anchorEntity, anchorEntity.scene == nil {
            arView.scene.addAnchor(anchorEntity)
        }

        self.arView = arView
    }

    func syncAndProjectOverlay() {
        guard let scene else {
            return
        }

        for objectID in scene.state.overlay.gauges.keys {
            guard var worldPosition = presentationWorldPosition(for: objectID) else {
                continue
            }

            worldPosition += [0, -0.8, 0]
            scene.state.overlay.gauges[objectID]?.worldPosition = worldPosition

            let screenPosition = project(worldPosition)
            scene.state.overlay.gauges[objectID]?.screenPosition = screenPosition
        }
    }
    #endif

    private func registerRealityComponents() {
        GridPositionComponent.registerComponent()
        MapSceneObjectComponent.registerComponent()
        MapSceneItemComponent.registerComponent()
        TileComponent.registerComponent()

        CombatTextComponent.registerComponent()
        CombatTextSystem.registerSystem()

        SpriteActionComponent.registerComponent()
        SpriteActionSystem.registerSystem()
        SpriteAnimationComponent.registerComponent()
        SpriteAnimationTimingComponent.registerComponent()
        SpriteAnimationLibraryComponent.registerComponent()
        SpriteAnimationSystem.registerSystem()
        SpriteBillboardComponent.registerComponent()
        SpriteBillboardSystem.registerSystem()
        SpriteConfigurationComponent.registerComponent()

        MapObjectSnapshotPresentationComponent.registerComponent()
        MapObjectSnapshotPresentationSystem.registerSystem()

        PlaySpriteAnimationAction.registerAction()
        PlaySpriteAnimationActionHandler.register { _ in
            PlaySpriteAnimationActionHandler()
        }
    }

    private func updateTileEntities(forCenter center: SIMD2<Int>, mapGrid: MapGrid) {
        #if os(visionOS)
        for offsetX in (-tileRange)...(tileRange) {
            for offsetY in (-tileRange)...(tileRange) {
                let key = SIMD2<Int>(offsetX, offsetY)
                let x = center.x + offsetX
                let y = center.y + offsetY

                let tileEntity: Entity
                if let existing = tileEntities[key] {
                    tileEntity = existing
                } else {
                    tileEntity = Entity()
                    tileEntity.name = "tile"

                    let mesh = MeshResource.generatePlane(width: 1, depth: 1)

                    var material = SimpleMaterial()
                    material.color = SimpleMaterial.BaseColor(tint: .yellow)
                    material.triangleFillMode = .lines

                    tileEntity.components.set(ModelComponent(mesh: mesh, materials: [material]))
                    tileEntity.components.set(CollisionComponent(shapes: [
                        .generateBox(width: 1, height: 0, depth: 1)
                    ]))
                    tileEntity.components.set(InputTargetComponent())
                    tileEntity.components.set(HoverEffectComponent())

                    tileEntities[key] = tileEntity
                    rootEntity.addChild(tileEntity)
                }

                tileEntity.components.set(TileComponent(position: [x, y]))

                let position = SIMD2(x, y)
                if mapGrid.contains(position) {
                    let cell = mapGrid[position]
                    tileEntity.position = [
                        Float(x) + 0.5,
                        cell.averageAltitude + 0.0001,
                        -Float(y) - 0.5,
                    ]
                    tileEntity.isEnabled = cell.isWalkable
                } else {
                    tileEntity.position = [
                        Float(x) + 0.5,
                        0,
                        -Float(y) - 0.5,
                    ]
                    tileEntity.isEnabled = false
                }
            }
        }
        #endif
    }

    private func setupLighting(world: WorldResource) {
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
        var position: SIMD3<Float> = [0, 1, 0]
        var point = Point3D(position)
        point = point.rotated(
            by: simd_quatd(angle: latitude, axis: [1, 0, 0]),
            around: Point3D(target)
        )
        point = point.rotated(
            by: simd_quatd(angle: longitude, axis: [0, 0, 1]),
            around: Point3D(target)
        )
        position = SIMD3(point)

        lightEntity.look(at: target, from: position, relativeTo: nil)
        rootEntity.addChild(lightEntity)
    }

    private func teardownSceneState() {
        snapshotTask?.cancel()
        snapshotTask = nil

        tileSelectionRenderer.hideSelection()
        worldCameraEntity.removeFromParent()
        for child in Array(worldCameraEntity.children) {
            child.removeFromParent()
        }
        entityCache.clear()

        for child in Array(rootEntity.children) where child !== tileSelectionRenderer.entity {
            child.stopAllAudio()
            child.removeFromParent()
        }

        tileEntities.removeAll()
    }

    private func setupWorldCamera(target: Entity, cameraState: MapCameraState) {
        let elevationBounds: ClosedRange<Float> = radians(15)...radians(60)

        var worldCameraComponent = WorldCameraComponent(
            azimuth: cameraState.azimuth,
            elevation: cameraState.elevation,
            radius: cameraState.distance,
            bounds: WorldCameraComponent.CameraBounds(elevation: elevationBounds)
        )
        #if os(visionOS)
        worldCameraComponent.radius = 15
        worldCameraComponent.targetOffset = [0, -0.75, 0]
        #else
        worldCameraComponent.targetOffset = [0, 0.5, 0]
        #endif

        let followComponent = FollowComponent(targetId: target.id, smoothing: [3, 1.2, 3])

        worldCameraEntity.components.set([worldCameraComponent, followComponent])
        worldCameraEntity.name = "camera"
        #if !os(visionOS)
        worldCameraEntity.addChild(
            Entity(components: PerspectiveCameraComponent(near: 2, far: 1000, fieldOfViewInDegrees: 15))
        )
        #endif

        let simulationEntity = PhysicsSimulationComponent.nearestSimulationEntity(for: target)
        let parentEntity = simulationEntity ?? target.parent
        worldCameraEntity.setParent(parentEntity)
        worldCameraEntity.position = target.position(relativeTo: parentEntity)
    }

    private func presentationWorldPosition(for objectID: GameObjectID) -> SIMD3<Float>? {
        entityCache.objectEntities[objectID]?.position(relativeTo: nil)
    }

    private func syncEntities(with state: MapSceneState, scene: MapScene) async {
        let objects = Array(state.objects.values)
        let desiredObjectIDs = Set(objects.map(\.objectID))

        for objectID in Set(entityCache.objectEntities.keys).subtracting(desiredObjectIDs) {
            entityCache.removeObjectEntity(for: objectID)
        }

        for object in objects {
            syncObjectEntity(for: object, scene: scene)
        }

        let desiredItemIDs = Set(state.items.keys)
        for objectID in Set(entityCache.itemEntities.keys).subtracting(desiredItemIDs) {
            entityCache.removeItemEntity(for: objectID)
        }

        for item in state.items.values {
            syncItemEntity(for: item, scene: scene)
        }
    }

    private func syncObjectEntity(for object: MapSceneObject, scene: MapScene) {
        let entity = entityCache.objectEntity(for: object)
        let isNew = entity.parent == nil

        entity.name = "\(object.objectID)"
        entity.transform = Transform(
            translation: sampler.sample(
                for: object,
                position: { scene.mapGrid.worldPosition(for: $0) },
                now: .now
            ).worldPosition
        )
        entity.isEnabled = object.effectState != .cloak
        entity.components.set(GridPositionComponent(gridPosition: object.gridPosition))
        entity.components.set(MapSceneObjectComponent(object: object))
        entity.components.set(MapObjectSnapshotPresentationComponent(
            logicalWorldPosition: scene.mapGrid.worldPosition(for: object.gridPosition),
            timeline: MapObjectMovementTimeline(for: object, position: { scene.mapGrid.worldPosition(for: $0) }),
            presentation: object.presentation
        ))

        if isNew {
            rootEntity.addChild(entity)
        }

        let configuration = ComposedSprite.Configuration(object: object)
        if isNew || entity.components[SpriteConfigurationComponent.self]?.configuration != configuration {
            entity.components.set(SpriteConfigurationComponent(configuration: configuration))
            loadObjectSpriteEntity(for: object, parent: entity)
        }
    }

    private func loadObjectSpriteEntity(for object: MapSceneObject, parent entity: Entity) {
        Task { [weak entityCache, weak entity] in
            guard let entityCache else {
                return
            }

            do {
                let configuration = ComposedSprite.Configuration(object: object)
                let spriteEntity = try await entityCache.objectSpriteEntity(for: configuration)
                if let entity, configuration == entity.components[SpriteConfigurationComponent.self]?.configuration {
                    entity.findEntity(named: "sprite")?.removeFromParent()
                    entity.addChild(spriteEntity)
                }
            } catch {
                logger.warning("\(error)")
            }
        }
    }

    private func syncItemEntity(for item: MapSceneItem, scene: MapScene) {
        let entity = entityCache.itemEntity(for: item)

        let isNew = entity.parent == nil

        entity.name = "\(item.objectID)"
        entity.transform = Transform(translation: scene.mapGrid.worldPosition(for: item.gridPosition))
        entity.components.set(GridPositionComponent(gridPosition: item.gridPosition))
        entity.components.set(MapSceneItemComponent(item: item))

        if isNew {
            rootEntity.addChild(entity)
            loadItemSpriteEntity(for: item, parent: entity)
        }
    }

    private func loadItemSpriteEntity(for item: MapSceneItem, parent entity: Entity) {
        Task { [weak entityCache, weak entity] in
            guard let entityCache else {
                return
            }

            do {
                let spriteEntity = try await entityCache.itemSpriteEntity(forItemID: item.itemID)
                if let entity {
                    entity.addChild(spriteEntity)
                    entity.playDefaultSpriteAnimation()
                }
            } catch {
                logger.warning("\(error)")
            }
        }
    }
}
