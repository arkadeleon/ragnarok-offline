//
//  MapScene.swift
//  GameCore
//
//  Created by Leon Li on 2025/3/27.
//

import AVFAudio
import Constants
import NetworkClient
import RealityKit
import ResourceManagement
import SGLMath
import Spatial
import SpriteRendering
import SwiftUI
import WorldCamera
import WorldRendering

@MainActor
protocol MapSceneDelegate: AnyObject {
    func mapSceneDidFinishLoading(_ scene: MapScene)
    func mapScene(_ scene: MapScene, didTapTileAt position: SIMD2<Int>)
    func mapScene(_ scene: MapScene, didTapMapObject object: MapObject)
    func mapScene(_ scene: MapScene, didTapMapObjectWith objectID: UInt32)
    func mapScene(_ scene: MapScene, didTapMapItem item: MapItem)
}

@MainActor
public class MapScene {
    let mapName: String
    let world: WorldResource
    let player: MapObject
    let playerPosition: SIMD2<Int>

    let mapGrid: MapGrid

    let resourceManager: ResourceManager

    let rootEntity = Entity()

    weak var mapSceneDelegate: (any MapSceneDelegate)?

    var distance: Float = 80 {
        didSet {
            rootEntity.findEntity(named: "camera")?.components[WorldCameraComponent.self]?.radius = distance
        }
    }

    private let playerEntity = SpriteEntity()

    private let tileEntityManager: TileEntityManager
    private let spriteEntityManager: SpriteEntityManager

    private let pathfinder: Pathfinder

    #if os(visionOS)
    let elevation: Float = radians(-75)
    #else
    let elevation: Float = radians(-45)
    #endif

    var tileTapGesture: some Gesture {
        SpatialTapGesture()
            .targetedToEntity(where: .has(TileComponent.self))
            .onEnded { [unowned self] event in
                if let position = event.entity.components[TileComponent.self]?.position {
                    self.mapSceneDelegate?.mapScene(self, didTapTileAt: position)
                }
            }
    }

    var mapObjectTapGesture: some Gesture {
        SpatialTapGesture()
            .targetedToEntity(where: .has(MapObjectComponent.self))
            .onEnded { [unowned self] event in
                if let mapObject = event.entity.components[MapObjectComponent.self]?.mapObject {
                    self.mapSceneDelegate?.mapScene(self, didTapMapObject: mapObject)
                }
            }
    }

    var mapItemTapGesture: some Gesture {
        SpatialTapGesture()
            .targetedToEntity(where: .has(MapItemComponent.self))
            .onEnded { [unowned self] event in
                if let mapItem = event.entity.components[MapItemComponent.self]?.mapItem {
                    self.mapSceneDelegate?.mapScene(self, didTapMapItem: mapItem)
                }
            }
    }

    init(mapName: String, world: WorldResource, player: MapObject, playerPosition: SIMD2<Int>, resourceManager: ResourceManager) {
        self.mapName = mapName
        self.world = world
        self.player = player
        self.playerPosition = playerPosition

        self.mapGrid = MapGrid(gat: world.gat)

        self.resourceManager = resourceManager

        self.tileEntityManager = TileEntityManager(mapGrid: mapGrid, rootEntity: rootEntity)
        self.spriteEntityManager = SpriteEntityManager(resourceManager: resourceManager)

        self.pathfinder = Pathfinder(mapGrid: mapGrid)

        GridPositionComponent.registerComponent()
        MapGridComponent.registerComponent()
        MapItemComponent.registerComponent()
        MapObjectComponent.registerComponent()
        SpriteComponent.registerComponent()
        TileComponent.registerComponent()

        PlaySpriteAnimationAction.registerAction()
        PlaySpriteAnimationActionHandler.register { _ in
            PlaySpriteAnimationActionHandler()
        }
    }

    func load() async {
        if let worldEntity = try? await Entity.worldEntity(world: world, resourceManager: resourceManager) {
            worldEntity.name = mapName
            worldEntity.transform = Transform(rotation: simd_quatf(angle: radians(-90), axis: [1, 0, 0]))

            if let audioResource = await audioResource(forMapName: mapName) {
                worldEntity.components.set(AudioLibraryComponent(resources: [
                    "BGM": audioResource
                ]))
                worldEntity.components.set(AmbientAudioComponent())
                worldEntity.playAudio(audioResource)
            }

            rootEntity.addChild(worldEntity)
        }

        tileEntityManager.addTileEntities(forCenter: playerPosition)

        do {
            let configuration = ComposedSprite.Configuration(mapObject: player)
            let composedSprite = try await ComposedSprite(configuration: configuration, resourceManager: resourceManager)

            let animations = try await SpriteAnimation.animations(for: composedSprite)
            let spriteComponent = SpriteComponent(animations: animations)
            playerEntity.components.set(spriteComponent)
        } catch {
            logger.warning("\(error)")
        }

        playerEntity.name = "\(player.objectID)"
        playerEntity.transform = transform(for: playerPosition)
        playerEntity.components.set([
            GridPositionComponent(gridPosition: playerPosition),
            MapGridComponent(mapGrid: mapGrid),
            MapObjectComponent(mapObject: player),
        ])
        playerEntity.playSpriteAnimation(.idle, direction: .south, repeats: true)

        rootEntity.addChild(playerEntity)

        setupLighting()
        _ = setupWorldCamera(target: playerEntity)

        mapSceneDelegate?.mapSceneDidFinishLoading(self)
    }

    func unload() {
        if let worldEntity = rootEntity.findEntity(named: mapName) {
            worldEntity.stopAllAudio()
        }
    }

    func hitEntity(_ entity: Entity) {
        if let mapObject = entity.components[MapObjectComponent.self]?.mapObject {
            mapSceneDelegate?.mapScene(self, didTapMapObject: mapObject)
        } else if let mapItem = entity.components[MapItemComponent.self]?.mapItem {
            mapSceneDelegate?.mapScene(self, didTapMapItem: mapItem)
        }
    }

    func raycast(origin: SIMD3<Float>, direction: SIMD3<Float>) {
        var point = origin
        for i in 0..<200 {
            point = origin + direction * Float(i)

            let x = point.x + 0.5
            let y = point.y + 0.5

            let position: SIMD2<Int> = [Int(x), Int(y)]

            guard 0..<mapGrid.width ~= position.x, 0..<mapGrid.height ~= position.y else {
                continue
            }

            let cell = mapGrid[position]

            let xr = x.truncatingRemainder(dividingBy: 1)
            let yr = y.truncatingRemainder(dividingBy: 1)

            let x1 = cell.bottomLeftAltitude + (cell.bottomRightAltitude - cell.bottomLeftAltitude) * xr
            let x2 = cell.topLeftAltitude + (cell.topRightAltitude - cell.topLeftAltitude) * xr

            let altitude = x1 + (x2 - x1) * yr

            if fabsf(altitude - point.z) < 0.5 {
                mapSceneDelegate?.mapScene(self, didTapTileAt: position)
                break
            }
        }
    }

    private func setupLighting() {
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
        let lightComponent = DirectionalLightComponent(color: lightColor)

        let lightShadowComponent = DirectionalLightComponent.Shadow(maximumDistance: 100)

        lightEntity.components.set([lightComponent, lightShadowComponent])

        // Default longitude(45), latitude(45) makes shadow too long.
        let longitude = radians(Double(world.rsw.light.longitude)) / 2
        let latitude = radians(Double(world.rsw.light.latitude)) / 2

        let target: SIMD3<Float> = [0, 0, 0]
        var position: SIMD3<Float> = [0, 0, 1]
        var point = Point3D(position)
        point = point.rotated(
            by: simd_quatd(angle: latitude, axis: [1, 0, 0]),
            around: Point3D(target)
        )
        point = point.rotated(
            by: simd_quatd(angle: -longitude, axis: [0, 1, 0]),
            around: Point3D(target)
        )
        position = SIMD3(point)

        lightEntity.look(at: target, from: position, relativeTo: nil)

        rootEntity.addChild(lightEntity)
    }

    /// Performs any necessary setup of the world camera.
    /// - Parameter target: The entity to orient the camera toward.
    private func setupWorldCamera(target: Entity) -> Entity {
        // Set the available bounds for the camera orientation.
        let elevationBounds: ClosedRange<Float> = radians(-75)...radians(-45)
        let initialElevation = elevation

        // Create a world camera component, which acts as a target camera,
        // where it repositions the scene to orient toward the owning entity.
        var worldCameraComponent = WorldCameraComponent(
            azimuth: 0,
            elevation: initialElevation,
            radius: 3,
            bounds: WorldCameraComponent.CameraBounds(elevation: elevationBounds)
        )
        #if os(visionOS)
        // The way that RealityKit orients immersive views isn't the same as a portal.
        // This offset brings the target a bit closer to the center of the view.
        // The system also modifies this in `PyroPandaView/RealityView`.
        worldCameraComponent.radius = 15
        worldCameraComponent.targetOffset = [0, -0.75, 0]
        #else
        worldCameraComponent.radius = 80
        worldCameraComponent.targetOffset = [0, 0.5, 0]
        #endif

        let followComponent = FollowComponent(targetId: target.id, smoothing: [3, 1.2, 3])

        let worldCamera = Entity(components: worldCameraComponent, followComponent)
        worldCamera.name = "camera"
        #if !os(visionOS)
        worldCamera.addChild(Entity(components: PerspectiveCameraComponent(near: 2, far: 300, fieldOfViewInDegrees: 15)))
        #endif

        let simulationEntity = PhysicsSimulationComponent.nearestSimulationEntity(for: target)
        let parentEntity = simulationEntity ?? target.parent
        worldCamera.setParent(parentEntity)

        worldCamera.position = target.position(relativeTo: parentEntity)

        return worldCamera
    }

    private func transform(for gridPosition: SIMD2<Int>) -> Transform {
        let scale: SIMD3<Float> = [1, 1 / cosf(radians(90) + elevation), 1]
        let rotation = simd_quatf(angle: radians(90), axis: [1, 0, 0])
        let translation = position(for: gridPosition)
        let transform = Transform(scale: scale, rotation: rotation, translation: translation)
        return transform
    }

    private func position(for gridPosition: SIMD2<Int>) -> SIMD3<Float> {
        let altitude = mapGrid[gridPosition].averageAltitude
        let position: SIMD3<Float> = [
            Float(gridPosition.x) + 0.5,
            Float(gridPosition.y) + 0.5,
            altitude,
        ]
        return position
    }

    private func audioResource(forMapName mapName: String) async -> AudioResource? {
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
        let audioResource = try? AudioBufferResource(buffer: audioBuffer, configuration: configuration)
        return audioResource
    }

    private func audioBuffer(with data: Data) -> AVAudioBuffer? {
        // Create a temporary file
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

            // Clean up
            try? FileManager.default.removeItem(at: tempURL)

            return buffer
        } catch {
            try? FileManager.default.removeItem(at: tempURL)
            return nil
        }
    }
}

extension MapScene: MapEventHandlerProtocol {
    func onPlayerMoved(startPosition: SIMD2<Int>, endPosition: SIMD2<Int>) {
        let startPosition = playerEntity.components[GridPositionComponent.self]?.gridPosition ?? startPosition
        let endPosition = endPosition
        let path = pathfinder.findPath(from: startPosition, to: endPosition)
        playerEntity.walk(through: path)

        tileEntityManager.updateTileEntities(forCenter: endPosition)
    }

    func onMapObjectSpawned(object: MapObject, position: SIMD2<Int>, direction: Direction, headDirection: HeadDirection) {
        if let entity = rootEntity.findEntity(named: "\(object.objectID)") as? SpriteEntity {
            let transform = transform(for: position)
            entity.transform = transform
            entity.components[GridPositionComponent.self]?.gridPosition = position
        } else {
            Task {
                do {
                    let entity = try await spriteEntityManager.entity(for: object)
                    entity.name = "\(object.objectID)"
                    entity.transform = transform(for: position)
                    entity.isEnabled = (object.effectState != .cloak)
                    entity.components.set([
                        GridPositionComponent(gridPosition: position),
                        MapGridComponent(mapGrid: mapGrid),
                        MapObjectComponent(mapObject: object),
                    ])
                    entity.playSpriteAnimation(.idle, direction: CharacterDirection(direction: direction), repeats: true)
                    rootEntity.addChild(entity)
                } catch {
                    logger.info("\(error)")
                }
            }
        }
    }

    func onMapObjectMoved(object: MapObject, startPosition: SIMD2<Int>, endPosition: SIMD2<Int>) {
        if let entity = rootEntity.findEntity(named: "\(object.objectID)") as? SpriteEntity {
            let startPosition = entity.components[GridPositionComponent.self]?.gridPosition ?? startPosition
            let endPosition = endPosition
            let path = pathfinder.findPath(from: startPosition, to: endPosition)
            entity.walk(through: path)
        } else {
            Task {
                do {
                    let entity = try await spriteEntityManager.entity(for: object)
                    entity.name = "\(object.objectID)"
                    entity.transform = transform(for: endPosition)
                    entity.isEnabled = (object.effectState != .cloak)
                    entity.components.set([
                        GridPositionComponent(gridPosition: endPosition),
                        MapGridComponent(mapGrid: mapGrid),
                        MapObjectComponent(mapObject: object),
                    ])
                    entity.playSpriteAnimation(.idle, direction: .south, repeats: true)
                    rootEntity.addChild(entity)
                } catch {
                    logger.info("\(error)")
                }
            }
        }
    }

    func onMapObjectStopped(objectID: UInt32, position: SIMD2<Int>) {
        if let entity = rootEntity.findEntity(named: "\(objectID)") as? SpriteEntity {
            let transform = transform(for: position)
            entity.transform = transform
            entity.playSpriteAnimation(.idle, direction: .south, repeats: true)
        }
    }

    func onMapObjectVanished(objectID: UInt32) {
        if let entity = rootEntity.findEntity(named: "\(objectID)") {
            entity.removeFromParent()
        }
    }

    func onMapObjectStateChanged(objectID: UInt32, bodyState: StatusChangeOption1, healthState: StatusChangeOption2, effectState: StatusChangeOption) {
        if let entity = rootEntity.findEntity(named: "\(objectID)") {
            entity.isEnabled = (effectState != .cloak)
        }
    }

    func onMapObjectActionPerformed(sourceObjectID: UInt32, targetObjectID: UInt32, actionType: DamageType) {
        if let entity = rootEntity.findEntity(named: "\(sourceObjectID)") as? SpriteEntity {
            switch actionType {
            case .normal, .endure, .multi_hit, .multi_hit_endure, .critical, .lucy_dodge, .multi_hit_critical:
                entity.attack(direction: .south)
            case .pickup_item:
                entity.playSpriteAnimation(.pickup, direction: .south, repeats: false)
            case .sit_down:
                entity.playSpriteAnimation(.sit, direction: .south, repeats: true)
            case .stand_up:
                entity.playSpriteAnimation(.idle, direction: .south, repeats: true)
            default:
                break
            }
        }
    }

    func onItemSpawned(item: MapItem, position: SIMD2<Int>) {
        Task {
            let scriptContext = await resourceManager.scriptContext()
            guard let path = ResourcePath.generateItemSpritePath(itemID: Int(item.itemID), scriptContext: scriptContext) else {
                return
            }

            let sprite = try await resourceManager.sprite(at: path)
            let animation = try await SpriteAnimation(sprite: sprite, actionIndex: 0)

            let entity = SpriteEntity(animations: [animation])
            entity.name = "\(item.objectID)"
            entity.transform = transform(for: position)
            entity.components.set([
                GridPositionComponent(gridPosition: position),
                MapGridComponent(mapGrid: mapGrid),
                MapItemComponent(mapItem: item),
            ])
            entity.playSpriteAnimation(atIndex: 0, repeats: true)
            rootEntity.addChild(entity)
        }
    }

    func onItemVanished(objectID: UInt32) {
        if let entity = rootEntity.findEntity(named: "\(objectID)") {
            entity.removeFromParent()
        }
    }
}
