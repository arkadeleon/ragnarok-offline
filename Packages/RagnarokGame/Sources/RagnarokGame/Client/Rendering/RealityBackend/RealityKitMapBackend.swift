//
//  RealityKitMapBackend.swift
//  RagnarokGame
//
//  Created by Leon Li on 2026/3/21.
//

import AVFAudio
import CoreGraphics
import Foundation
import RagnarokConstants
import RagnarokModels
import RagnarokPackets
import RagnarokReality
import RagnarokResources
import RagnarokSprite
import RealityKit
import SGLMath
import Spatial
import SwiftUI
import WorldCamera

final class RealityKitMapBackend: MapSceneRuntimeBackend, MapRealityViewBackend {
    private weak var scene: MapScene?

    let rootEntity = Entity()

    var overlay: MapSceneOverlay?

    private let entityCache: RealityEntityCache
    private let tileSelectionRenderer: RealityTileSelectionRenderer

    private let worldCameraEntity = Entity()
    private var pathfinder: Pathfinder?
    private var tileEntities: [SIMD2<Int>: Entity] = [:]
    private let tileRange = 17

    #if os(iOS) || os(macOS)
    private var realityMapProjector: RealityMapProjector?
    private var realityMapHitTester: RealityMapHitTester?
    private var anchorEntity: AnchorEntity?
    #endif

    var projector: (any MapProjector)? {
        #if os(iOS) || os(macOS)
        realityMapProjector
        #else
        nil
        #endif
    }

    init(resourceManager: ResourceManager) {
        let factory = RealitySpriteNodeFactory(resourceManager: resourceManager)
        self.entityCache = RealityEntityCache(factory: factory)
        self.tileSelectionRenderer = RealityTileSelectionRenderer(resourceManager: resourceManager)

        registerRealityComponents()
        rootEntity.addChild(tileSelectionRenderer.entity)
    }

    func attach(scene: MapScene) {
        self.scene = scene
        self.pathfinder = Pathfinder(mapGrid: scene.mapGrid)
    }

    func detach() {
        scene = nil
        overlay = nil
        pathfinder = nil
        #if os(iOS) || os(macOS)
        realityMapProjector = nil
        realityMapHitTester = nil
        anchorEntity = nil
        #endif
    }

    func load(progress: Progress) async {
        guard let scene else {
            return
        }

        if let worldEntity = try? await Entity(from: scene.world, resourceManager: scene.resourceManager, progress: progress) {
            worldEntity.name = scene.mapName
            worldEntity.transform = Transform(rotation: simd_quatf(angle: radians(-180), axis: [1, 0, 0]))

            if let audioResource = await audioResource(forMapName: scene.mapName, resourceManager: scene.resourceManager) {
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
        if let skyboxEntity = try? await SkyboxEntity(configuration: skyboxConfiguration) {
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
        guard let scene,
              let worldEntity = rootEntity.findEntity(named: scene.mapName) else {
            return
        }
        worldEntity.stopAllAudio()
    }

    func applySnapshot(_ state: MapSceneState) {
        guard let scene else {
            return
        }

        updateCameraState(scene.cameraState)
        tileSelectionRenderer.syncSelection(state.selection.selectedPosition, mapGrid: scene.mapGrid)
    }

    func hitTest(at screenPoint: CGPoint) -> MapHitTestResult? {
        #if os(iOS) || os(macOS)
        realityMapHitTester?.hitTest(at: screenPoint)
        #else
        nil
        #endif
    }

    func updateCameraState(_ cameraState: MapCameraState) {
        worldCameraEntity.components[WorldCameraComponent.self]?.azimuth = cameraState.azimuth
        #if !os(visionOS)
        worldCameraEntity.components[WorldCameraComponent.self]?.elevation = cameraState.elevation
        #endif
        worldCameraEntity.components[WorldCameraComponent.self]?.radius = cameraState.distance
    }

    func updateHealthAndSpellPoints(
        for objectID: UInt32,
        hp: Int?,
        maxHp: Int?,
        sp: Int?,
        maxSp: Int?
    ) async {
        guard let entity = try? await entityCache.objectEntity(forObjectID: objectID) else {
            return
        }

        if let hp {
            entity.components[HealthPointsComponent.self]?.hp = hp
        }
        if let maxHp {
            entity.components[HealthPointsComponent.self]?.maxHp = maxHp
        }
        if let sp {
            entity.components[SpellPointsComponent.self]?.sp = sp
        }
        if let maxSp {
            entity.components[SpellPointsComponent.self]?.maxSp = maxSp
        }
    }

    func movePlayer(from startPosition: SIMD2<Int>, to endPosition: SIMD2<Int>) async {
        guard let scene,
              let playerEntity = try? await entityCache.objectEntity(forObjectID: scene.player.objectID) else {
            return
        }

        updateWalkingComponent(for: playerEntity, startPosition: startPosition, endPosition: endPosition, mapGrid: scene.mapGrid)
        updateTileEntities(forCenter: endPosition, mapGrid: scene.mapGrid)
        applySnapshot(scene.state)
    }

    func spawnMapObject(_ object: MapObject, position: SIMD2<Int>, direction: Direction) async {
        guard let scene else {
            return
        }

        do {
            let (entity, isNew) = try await entityCache.objectEntity(for: object)

            if isNew {
                entity.name = "\(object.objectID)"
                entity.transform = Transform(translation: scene.position(for: position))
                entity.isEnabled = object.effectState != .cloak
                entity.components.set([
                    GridPositionComponent(gridPosition: position),
                    MapObjectComponent(mapObject: object),
                ])
                if object.type == .monster {
                    entity.components.set([
                        HealthPointsComponent(hp: object.hp, maxHp: object.maxHp),
                    ])
                }
                rootEntity.addChild(entity)
            } else {
                entity.transform = Transform(translation: scene.position(for: position))
                entity.components[GridPositionComponent.self]?.gridPosition = position
                entity.components[MapObjectComponent.self]?.mapObject = object
                entity.components.remove(WalkingComponent.self)
            }

            entity.playSpriteAnimation(.idle, direction: CharacterDirection(direction: direction))
        } catch {
            logger.warning("\(error)")
        }
    }

    func moveMapObject(_ object: MapObject, startPosition: SIMD2<Int>, endPosition: SIMD2<Int>) async {
        guard let scene else {
            return
        }

        do {
            let (entity, isNew) = try await entityCache.objectEntity(for: object)

            if isNew {
                entity.name = "\(object.objectID)"
                entity.transform = Transform(translation: scene.position(for: endPosition))
                entity.isEnabled = object.effectState != .cloak
                entity.components.set([
                    GridPositionComponent(gridPosition: startPosition),
                    MapObjectComponent(mapObject: object),
                ])
                if object.type == .monster {
                    entity.components.set([
                        HealthPointsComponent(hp: object.hp, maxHp: object.maxHp),
                    ])
                }
                rootEntity.addChild(entity)
            } else {
                entity.components[MapObjectComponent.self]?.mapObject = object
            }

            updateWalkingComponent(for: entity, startPosition: startPosition, endPosition: endPosition, mapGrid: scene.mapGrid)
        } catch {
            logger.warning("\(error)")
        }
    }

    func stopMapObject(objectID: UInt32, position: SIMD2<Int>) async {
        guard let scene,
              let entity = try? await entityCache.objectEntity(forObjectID: objectID) else {
            return
        }

        entity.transform = Transform(translation: scene.position(for: position))
        entity.components[GridPositionComponent.self]?.gridPosition = position
        entity.components.remove(WalkingComponent.self)
        entity.playSpriteAnimation(.idle, direction: .south)
    }

    func removeMapObject(objectID: UInt32) async {
        do {
            try await entityCache.removeObjectEntity(forObjectID: objectID)
        } catch {
            logger.warning("\(error)")
        }
    }

    func setVisibility(forObjectID objectID: UInt32, isVisible: Bool) async {
        guard let entity = try? await entityCache.objectEntity(forObjectID: objectID) else {
            return
        }

        entity.isEnabled = isVisible
    }

    func performMapObjectAction(_ objectAction: MapObjectAction) async {
        guard let sourceEntity = try? await entityCache.objectEntity(forObjectID: objectAction.sourceObjectID) else {
            return
        }

        switch objectAction.type {
        case .pickup_item:
            sourceEntity.playSpriteAnimation(.pickup, direction: .south, nextActionType: .idle)
        case .sit_down:
            sourceEntity.playSpriteAnimation(.sit, direction: .south)
        case .stand_up:
            sourceEntity.playSpriteAnimation(.idle, direction: .south)
        case .normal, .endure, .critical:
            sourceEntity.attack(direction: .south)
            await renderDamageEffect(
                targetObjectID: objectAction.targetObjectID,
                amounts: [objectAction.damage, objectAction.damage2].filter { $0 > 0 },
                delays: [
                    TimeInterval(objectAction.sourceSpeed),
                    TimeInterval(objectAction.sourceSpeed) + 200 * 1.75
                ]
            )
        case .multi_hit, .multi_hit_endure, .multi_hit_critical:
            sourceEntity.attack(direction: .south)
            let count = objectAction.damage > 1 ? 2 : 1
            var amounts: [Int] = []
            var delays: [TimeInterval] = []
            if count == 2 {
                amounts.append(objectAction.damage / count)
                delays.append(TimeInterval(objectAction.sourceSpeed))
            }
            if objectAction.damage2 > 0 {
                amounts.append(objectAction.damage / count)
                delays.append(TimeInterval(objectAction.sourceSpeed) + 200 / 2)
                amounts.append(objectAction.damage2)
                delays.append(TimeInterval(objectAction.sourceSpeed) + 200 * 1.75)
            } else {
                amounts.append(objectAction.damage / count)
                delays.append(TimeInterval(objectAction.sourceSpeed) + 200)
            }
            await renderDamageEffect(
                targetObjectID: objectAction.targetObjectID,
                amounts: amounts,
                delays: delays
            )
        case .lucy_dodge:
            sourceEntity.attack(direction: .south)
        default:
            break
        }
    }

    func performSkill(_ packet: PACKET_ZC_NOTIFY_SKILL) async {
        let sourceEntity = try? await entityCache.objectEntity(forObjectID: packet.AID)
        let targetEntity = try? await entityCache.objectEntity(forObjectID: packet.targetID)

        if let sourceEntity {
            if let mapObject = sourceEntity.components[MapObjectComponent.self]?.mapObject,
               mapObject.type != .monster {
                // TODO: Show dialog with skill name
            }

            sourceEntity.castSkill(direction: .south)
        }

        guard let targetEntity, packet.damage >= 0 else {
            return
        }

        let count = Int(packet.count)
        let damage = Int(packet.damage)

        for i in 0..<count {
            let damageEntity = Entity.makeDamageEntity(
                for: damage / count,
                delay: TimeInterval(packet.attackMT) + TimeInterval(200 * i),
                targetEntity: targetEntity
            )
            damageEntity.setParent(rootEntity)
        }
    }

    func spawnItem(_ item: MapItem, position: SIMD2<Int>) async {
        guard let scene else {
            return
        }

        do {
            let entity = try await entityCache.itemEntity(for: item)
            entity.name = "\(item.objectID)"
            entity.transform = Transform(translation: scene.position(for: position))
            entity.components.set([
                GridPositionComponent(gridPosition: position),
                MapItemComponent(mapItem: item),
            ])
            entity.playDefaultSpriteAnimation()
            rootEntity.addChild(entity)
        } catch {
            logger.warning("\(error)")
        }
    }

    func removeItem(objectID: UInt32) async {
        do {
            try await entityCache.removeItemEntity(forObjectID: objectID)
        } catch {
            logger.warning("\(error)")
        }
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

        realityMapProjector = RealityMapProjector(arView: arView)
        realityMapHitTester = RealityMapHitTester(arView: arView, scene: scene)
    }

    func syncAndProjectOverlay() {
        guard let scene, let arView = realityMapProjector?.arView else {
            return
        }

        let query = EntityQuery(where: .has(HealthPointsComponent.self))
        for entity in arView.scene.performQuery(query) {
            guard let mapObject = entity.components[MapObjectComponent.self]?.mapObject,
                  scene.state.overlaySnapshot.anchors[mapObject.objectID] != nil else {
                continue
            }

            let worldPosition = entity.position(relativeTo: nil)
            scene.state.overlaySnapshot.anchors[mapObject.objectID]?.gaugePosition = worldPosition + [0, -0.8, 0]
        }

        guard let overlay, let projector = realityMapProjector else {
            return
        }

        var gauges: [UInt32: MapSceneOverlay.Gauge] = [:]
        for anchor in scene.state.overlaySnapshot.anchors.values {
            guard let gaugePosition = anchor.gaugePosition,
                  let screenPoint = projector.project(gaugePosition) else {
                continue
            }

            gauges[anchor.id] = MapSceneOverlay.Gauge(
                objectID: anchor.id,
                hp: anchor.hp,
                maxHp: anchor.maxHp,
                sp: anchor.sp,
                maxSp: anchor.maxSp,
                objectType: anchor.objectType,
                screenPosition: screenPoint
            )
        }
        overlay.gauges = gauges
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
        SpriteAnimationLibraryComponent.registerComponent()
        SpriteAnimationSystem.registerSystem()
        SpriteBillboardComponent.registerComponent()
        SpriteBillboardSystem.registerSystem()

        WalkingComponent.registerComponent()
        WalkingSystem.registerSystem()

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

    private func updateWalkingComponent(
        for entity: Entity,
        startPosition: SIMD2<Int>,
        endPosition: SIMD2<Int>,
        mapGrid: MapGrid
    ) {
        guard let pathfinder else {
            return
        }

        if var walkingComponent = entity.components[WalkingComponent.self],
           walkingComponent.path.count > 1 {
            let currentPosition = walkingComponent.path[1]
            let path = pathfinder.findPath(from: currentPosition, to: endPosition)
            walkingComponent.path = [walkingComponent.path[0]] + path
            entity.components.set(walkingComponent)
        } else {
            let path = pathfinder.findPath(from: startPosition, to: endPosition)
            let walkingComponent = WalkingComponent(path: path, mapGrid: mapGrid)
            entity.components.set(walkingComponent)
        }
    }

    private func renderDamageEffect(targetObjectID: UInt32, amounts: [Int], delays: [TimeInterval]) async {
        guard let targetEntity = try? await entityCache.objectEntity(forObjectID: targetObjectID) else {
            return
        }

        for (amount, delay) in zip(amounts, delays) {
            let damageEntity = Entity.makeDamageEntity(
                for: amount,
                delay: delay,
                targetEntity: targetEntity
            )
            damageEntity.setParent(rootEntity)
        }
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
}
