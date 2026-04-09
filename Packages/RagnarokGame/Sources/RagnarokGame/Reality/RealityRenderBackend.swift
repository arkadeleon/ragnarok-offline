//
//  RealityRenderBackend.swift
//  RagnarokGame
//
//  Created by Leon Li on 2026/3/21.
//

import AVFAudio
import CoreGraphics
import Foundation
import RagnarokConstants
import RagnarokModels
import RagnarokRealityRendering
import RagnarokRenderAssets
import RagnarokResources
import RagnarokSprite
import RealityKit
import SGLMath
import Spatial
import SwiftUI
import WorldCamera

final class RealityRenderBackend: GameRenderBackend {
    weak var scene: MapScene?

    let rootEntity = Entity()

    private let entityCache: RealityEntityCache
    private let tileSelectionRenderer: RealityTileSelectionRenderer

    private let worldCameraEntity = Entity()
    private var renderedDamageEffectIDs: Set<UUID> = []
    private var snapshotTask: Task<Void, Never>?
    private var tileEntities: [SIMD2<Int>: Entity] = [:]
    private let tileRange = 17

    #if os(iOS) || os(macOS)
    weak var arView: ARView?
    private var anchorEntity: AnchorEntity?
    #endif

    init(resourceManager: ResourceManager) {
        let factory = RealitySpriteNodeFactory(resourceManager: resourceManager)
        self.entityCache = RealityEntityCache(factory: factory)
        self.tileSelectionRenderer = RealityTileSelectionRenderer(resourceManager: resourceManager)

        registerRealityComponents()
        rootEntity.addChild(tileSelectionRenderer.entity)
    }

    func attach(scene: MapScene) {
        self.scene = scene
    }

    func detach() {
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

            let audioResource = await audioResource(forMapName: scene.mapName, resourceManager: scene.resourceManager)
            if let audioResource {
                worldEntity.components.set(AudioLibraryComponent(resources: [
                    "BGM": audioResource
                ]))
                worldEntity.components.set(AmbientAudioComponent())
                worldEntity.playAudio(audioResource)
            }

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

        do {
            let (playerEntity, _) = try await entityCache.objectEntity(for: scene.player)
            playerEntity.name = "\(scene.player.objectID)"
            playerEntity.transform = Transform(translation: scene.position(for: scene.playerPosition))
            playerEntity.isEnabled = scene.player.effectState != .cloak
            playerEntity.components.set([
                GridPositionComponent(gridPosition: scene.playerPosition),
                MapObjectComponent(mapObject: scene.player),
                HealthPointsComponent(hp: scene.character.hp, maxHp: scene.character.maxHp),
                SpellPointsComponent(sp: scene.character.sp, maxSp: scene.character.maxSp),
            ])
            playerEntity.playSpriteAnimation(.idle, direction: .south)
            rootEntity.addChild(playerEntity)

            setupWorldCamera(target: playerEntity, cameraState: scene.cameraState)
        } catch {
            logger.warning("\(error)")
        }

        setupLighting(world: scene.world)
    }

    func unload() {
        if let scene,
           let worldEntity = rootEntity.findEntity(named: scene.mapName) {
            worldEntity.stopAllAudio()
        }

        teardownSceneState()
    }

    func applySnapshot(_ state: MapSceneState) {
        guard let scene else {
            return
        }

        updateCameraState(scene.cameraState)
        updateTileEntities(forCenter: state.player.gridPosition, mapGrid: scene.mapGrid)
        tileSelectionRenderer.syncSelection(state.selection, mapGrid: scene.mapGrid)

        snapshotTask?.cancel()
        snapshotTask = Task { @MainActor [weak self, weak scene] in
            guard let self, let scene else {
                return
            }
            await syncEntities(with: state, scene: scene)
            guard !Task.isCancelled else {
                return
            }
            await syncDamageEffects(with: state)
        }
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
        MapItemComponent.registerComponent()
        MapObjectComponent.registerComponent()
        TileComponent.registerComponent()
        HealthPointsComponent.registerComponent()
        SpellPointsComponent.registerComponent()

        DamageDigitComponent.registerComponent()
        DamageDigitSystem.registerSystem()

        SpriteActionComponent.registerComponent()
        SpriteActionSystem.registerSystem()
        SpriteAnimationComponent.registerComponent()
        SpriteAnimationTimingComponent.registerComponent()
        SpriteAnimationLibraryComponent.registerComponent()
        SpriteAnimationSystem.registerSystem()
        SpriteBillboardComponent.registerComponent()
        SpriteBillboardSystem.registerSystem()

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

                if 0..<mapGrid.width ~= x && 0..<mapGrid.height ~= y {
                    let cell = mapGrid[[x, y]]
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

        renderedDamageEffectIDs.removeAll()
        tileSelectionRenderer.entity.isEnabled = false
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

    private func syncDamageEffects(with state: MapSceneState) async {
        let activeEffectIDs = Set(state.damageEffects.map(\.id))
        renderedDamageEffectIDs.formIntersection(activeEffectIDs)

        for effect in state.damageEffects where !renderedDamageEffectIDs.contains(effect.id) {
            guard !Task.isCancelled else {
                return
            }

            renderedDamageEffectIDs.insert(effect.id)
            let rendered = await renderDamageEffect(effect)
            if !rendered {
                renderedDamageEffectIDs.remove(effect.id)
            }
        }
    }

    private func renderDamageEffect(_ effect: MapDamageEffect) async -> Bool {
        guard let targetEntity = try? await entityCache.objectEntity(for: effect.targetObjectID) else {
            return false
        }

        let damageEntity = Entity.makeDamageEntity(
            for: effect.amount,
            delay: effect.delay,
            targetEntity: targetEntity
        )
        damageEntity.setParent(rootEntity)
        return true
    }

    private func audioResource(forMapName mapName: String, resourceManager: ResourceManager) async -> AudioResource? {
        let mp3NameTable = await resourceManager.mp3NameTable()
        guard let mp3Name = mp3NameTable.mp3Name(forMapName: mapName) else {
            return nil
        }

        let bgmPath = ResourcePath(components: ["BGM", mp3Name])
        guard let bgmData = try? await resourceManager.contentsOfResource(at: bgmPath) else {
            return nil
        }

        guard let audioBuffer = audioBuffer(with: bgmData) else {
            return nil
        }

        let configuration = AudioBufferResource.Configuration(shouldLoop: true)
        return try? AudioBufferResource(buffer: audioBuffer, configuration: configuration)
    }

    private func audioBuffer(with data: Data) -> AVAudioBuffer? {
        let uuid = UUID().uuidString
        let tempURL = URL.temporaryDirectory.appending(path: uuid)

        do {
            try data.write(to: tempURL)
            let audioFile = try AVAudioFile(forReading: tempURL)
            let buffer = AVAudioPCMBuffer(
                pcmFormat: audioFile.processingFormat,
                frameCapacity: AVAudioFrameCount(audioFile.length)
            )

            if let buffer {
                try audioFile.read(into: buffer)
            }

            try? FileManager.default.removeItem(at: tempURL)
            return buffer
        } catch {
            try? FileManager.default.removeItem(at: tempURL)
            return nil
        }
    }

    private func presentationWorldPosition(for objectID: GameObjectID) -> SIMD3<Float>? {
        entityCache.loadedObjectEntity(for: objectID)?.position(relativeTo: nil)
    }

    private func syncEntities(with state: MapSceneState, scene: MapScene) async {
        let objectStates: [MapObjectState] = [state.player] + Array(state.objects.values)
        let desiredObjectIDs = Set(objectStates.map(\.id))

        for objectID in entityCache.objectIDs.subtracting(desiredObjectIDs) {
            do {
                try await entityCache.removeObjectEntity(for: objectID)
            } catch {
                logger.warning("\(error)")
            }
        }

        for objectState in objectStates {
            guard !Task.isCancelled else {
                return
            }
            await syncObjectEntity(for: objectState, scene: scene)
        }

        let desiredItemIDs = Set(state.items.keys)
        for objectID in entityCache.itemIDs.subtracting(desiredItemIDs) {
            do {
                try await entityCache.removeItemEntity(for: objectID)
            } catch {
                logger.warning("\(error)")
            }
        }

        for itemState in state.items.values {
            guard !Task.isCancelled else {
                return
            }
            await syncItemEntity(for: itemState, scene: scene)
        }
    }

    private func syncObjectEntity(for objectState: MapObjectState, scene: MapScene) async {
        do {
            let (entity, isNew) = try await entityCache.objectEntity(for: objectState.object)
            guard !Task.isCancelled else {
                return
            }

            if isNew || entity.parent == nil {
                rootEntity.addChild(entity)
            }

            entity.name = "\(objectState.id)"
            entity.transform = Transform(translation: presentationWorldPosition(for: objectState, scene: scene))
            entity.isEnabled = objectState.isVisible
            entity.components.set(GridPositionComponent(gridPosition: objectState.gridPosition))
            entity.components.set(MapObjectComponent(mapObject: objectState.object))
            entity.components.set(makePresentationComponent(for: objectState, scene: scene))

            if scene.player.objectID == objectState.id || objectState.object.type == .monster {
                entity.components.set(HealthPointsComponent(hp: objectState.hp, maxHp: objectState.maxHp))
            } else {
                entity.components.remove(HealthPointsComponent.self)
            }

            if let sp = objectState.sp, let maxSp = objectState.maxSp {
                entity.components.set(SpellPointsComponent(sp: sp, maxSp: maxSp))
            } else {
                entity.components.remove(SpellPointsComponent.self)
            }
        } catch {
            logger.warning("\(error)")
        }
    }

    private func syncItemEntity(for itemState: MapItemState, scene: MapScene) async {
        do {
            let entity = try await entityCache.itemEntity(for: itemState.item)
            guard !Task.isCancelled else {
                return
            }

            let isNew = entity.parent == nil

            entity.name = "\(itemState.id)"
            entity.transform = Transform(translation: scene.position(for: itemState.gridPosition))
            entity.components.set(GridPositionComponent(gridPosition: itemState.gridPosition))
            entity.components.set(MapItemComponent(mapItem: itemState.item))

            if isNew {
                entity.playDefaultSpriteAnimation()
                rootEntity.addChild(entity)
            }
        } catch {
            logger.warning("\(error)")
        }
    }

    private func makePresentationComponent(for objectState: MapObjectState, scene: MapScene) -> MapObjectSnapshotPresentationComponent {
        return MapObjectSnapshotPresentationComponent(
            logicalWorldPosition: scene.position(for: objectState.gridPosition),
            timeline: MapObjectPresentationEvaluator.makePresentationTimeline(
                for: objectState,
                position: { scene.position(for: $0) }
            ),
            presentation: objectState.presentation
        )
    }

    private func presentationWorldPosition(for objectState: MapObjectState, scene: MapScene) -> SIMD3<Float> {
        MapObjectPresentationEvaluator.resolvedPresentation(
            for: objectState,
            now: .now,
            position: { scene.position(for: $0) }
        ).worldPosition
    }
}
