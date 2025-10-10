//
//  MapScene.swift
//  GameCore
//
//  Created by Leon Li on 2025/3/27.
//

import AVFAudio
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

    public let rootEntity = Entity()

    weak var mapSceneDelegate: (any MapSceneDelegate)?

    public var distance: Float = 80 {
        didSet {
            rootEntity.findEntity(named: "camera")?.components[WorldCameraComponent.self]?.radius = distance
        }
    }

    private let playerEntity = SpriteEntity()

    private let tileEntityManager: TileEntityManager
    private let spriteEntityManager: SpriteEntityManager

    private let pathfinder: Pathfinder

    #if os(visionOS)
    let elevation: Float = radians(15)
    #else
    let elevation: Float = radians(45)
    #endif

    public var tileTapGesture: some Gesture {
        SpatialTapGesture()
            .targetedToEntity(where: .has(TileComponent.self))
            .onEnded { [unowned self] event in
                if let position = event.entity.components[TileComponent.self]?.position {
                    self.mapSceneDelegate?.mapScene(self, didTapTileAt: position)
                }
            }
    }

    public var mapObjectTapGesture: some Gesture {
        SpatialTapGesture()
            .targetedToEntity(where: .has(MapObjectComponent.self))
            .onEnded { [unowned self] event in
                if let mapObject = event.entity.components[MapObjectComponent.self]?.mapObject {
                    self.mapSceneDelegate?.mapScene(self, didTapMapObject: mapObject)
                }
            }
    }

    public var mapItemTapGesture: some Gesture {
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

        self.tileEntityManager = TileEntityManager(gat: world.gat, rootEntity: rootEntity)
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

        FromToByAction<Transform>.subscribe(to: .terminated) { event in
            if let spriteEntity = event.targetEntity as? SpriteEntity {
                spriteEntity.playSpriteAnimation(at: 0, repeats: true)
            }
        }
    }

    func load() async {
        if let worldEntity = try? await Entity.worldEntity(world: world, resourceManager: resourceManager) {
            worldEntity.name = mapName
            worldEntity.transform = Transform(rotation: simd_quatf(angle: radians(-180), axis: [1, 0, 0]))

            if let audioResource = await audioResource(forMapName: mapName) {
                worldEntity.components.set(AudioLibraryComponent(resources: [
                    "BGM": audioResource
                ]))
                worldEntity.components.set(AmbientAudioComponent())
                worldEntity.playAudio(audioResource)
            }

            rootEntity.addChild(worldEntity)
        }

        tileEntityManager.addTileEntities(forPosition: playerPosition)

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
        playerEntity.scale = [1, 1 / cosf(elevation), 1]
        playerEntity.transform = transform(for: playerPosition)
        playerEntity.components.set([
            GridPositionComponent(gridPosition: playerPosition),
            MapGridComponent(mapGrid: mapGrid),
            MapObjectComponent(mapObject: player),
        ])
        playerEntity.playSpriteAnimation(.idle, direction: .south, repeats: true)

        rootEntity.addChild(playerEntity)

        setupLight()
        _ = setupWorldCamera(target: playerEntity)

        mapSceneDelegate?.mapSceneDidFinishLoading(self)
    }

    func unload() {
        if let worldEntity = rootEntity.findEntity(named: mapName) {
            worldEntity.stopAllAudio()
        }
    }

    private func setupLight() {
        let lightEntity = DirectionalLight()

        lightEntity.shadow = DirectionalLightComponent.Shadow(maximumDistance: 100)

        let target: SIMD3<Float> = [Float(mapGrid.width / 2), 0, -Float(mapGrid.height / 2)]
        var position: SIMD3<Float> = [Float(mapGrid.width / 2), 80, -Float(mapGrid.height / 2)]
        var point = Point3D(position)
        point = point.rotated(
            by: simd_quatd(angle: radians(25), axis: [1, 0, 1]),
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
        let elevationBounds: ClosedRange<Float> = (.zero)...radians(60)
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

        let simulationParent = PhysicsSimulationComponent.nearestSimulationEntity(for: target)
        worldCamera.setParent(simulationParent ?? target.parent)
        return worldCamera
    }

    private func transform(for gridPosition: SIMD2<Int>) -> Transform {
        let scale: SIMD3<Float> = [1, 1 / cosf(elevation), 1]
        let rotation = simd_quatf(angle: radians(0), axis: [1, 0, 0])
        let translation = position(for: gridPosition)
        let transform = Transform(scale: scale, rotation: rotation, translation: translation)
        return transform
    }

    private func position(for gridPosition: SIMD2<Int>) -> SIMD3<Float> {
        let altitude = mapGrid[gridPosition].altitude
        let position: SIMD3<Float> = [
            Float(gridPosition.x) + 0.5,
            -altitude / 5,
            -Float(gridPosition.y) - 0.5,
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
    func onPlayerMoved(_ event: PlayerEvents.Moved) {
        let startPosition = playerEntity.components[GridPositionComponent.self]?.gridPosition ?? event.startPosition
        let endPosition = event.endPosition
        let path = pathfinder.findPath(from: startPosition, to: endPosition)
        playerEntity.walk(through: path)

        tileEntityManager.updateTileEntities(forPosition: event.endPosition)
    }

    func onMapObjectSpawned(_ event: MapObjectEvents.Spawned) {
        if let entity = rootEntity.findEntity(named: "\(event.object.objectID)") as? SpriteEntity {
            let transform = transform(for: event.position)
            entity.transform = transform
            entity.components[GridPositionComponent.self]?.gridPosition = event.position
        } else {
            Task {
                if let entity = try? await spriteEntityManager.entity(for: event.object) {
                    entity.name = "\(event.object.objectID)"
                    entity.scale = [1, 1 / cosf(elevation), 1]
                    entity.transform = transform(for: event.position)
                    entity.isEnabled = (event.object.effectState != .cloak)
                    entity.components.set([
                        GridPositionComponent(gridPosition: event.position),
                        MapGridComponent(mapGrid: mapGrid),
                        MapObjectComponent(mapObject: event.object),
                    ])
                    entity.playSpriteAnimation(.idle, direction: .south, repeats: true)
                    rootEntity.addChild(entity)
                }
            }
        }
    }

    func onMapObjectMoved(_ event: MapObjectEvents.Moved) {
        if let entity = rootEntity.findEntity(named: "\(event.object.objectID)") as? SpriteEntity {
            let startPosition = entity.components[GridPositionComponent.self]?.gridPosition ?? event.startPosition
            let endPosition = event.endPosition
            let path = pathfinder.findPath(from: startPosition, to: endPosition)
            entity.walk(through: path)
        } else {
            Task {
                if let entity = try? await spriteEntityManager.entity(for: event.object) {
                    entity.name = "\(event.object.objectID)"
                    entity.scale = [1, 1 / cosf(elevation), 1]
                    entity.transform = transform(for: event.endPosition)
                    entity.isEnabled = (event.object.effectState != .cloak)
                    entity.components.set([
                        GridPositionComponent(gridPosition: event.endPosition),
                        MapGridComponent(mapGrid: mapGrid),
                        MapObjectComponent(mapObject: event.object),
                    ])
                    entity.playSpriteAnimation(.idle, direction: .south, repeats: true)
                    rootEntity.addChild(entity)
                }
            }
        }
    }

    func onMapObjectStopped(_ event: MapObjectEvents.Stopped) {
        if let entity = rootEntity.findEntity(named: "\(event.objectID)") as? SpriteEntity {
            let transform = transform(for: event.position)
            entity.transform = transform
        }
    }

    func onMapObjectVanished(_ event: MapObjectEvents.Vanished) {
        if let entity = rootEntity.findEntity(named: "\(event.objectID)") {
            entity.removeFromParent()
        }
    }

    func onMapObjectStateChanged(_ event: MapObjectEvents.StateChanged) {
        if let entity = rootEntity.findEntity(named: "\(event.objectID)") {
            entity.isEnabled = (event.effectState != .cloak)
        }
    }

    func onMapObjectActionPerformed(_ event: MapObjectEvents.ActionPerformed) {
        if let entity = rootEntity.findEntity(named: "\(event.sourceObjectID)") as? SpriteEntity {
            switch event.actionType {
            case .normal, .endure, .multi_hit, .multi_hit_endure, .critical, .lucy_dodge, .multi_hit_critical:
                entity.playSpriteAnimation(.attack, direction: .south, repeats: false)
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

    func onItemSpawned(_ event: ItemEvents.Spawned) {
        Task {
            let scriptContext = await resourceManager.scriptContext()
            guard let path = ResourcePath.generateItemSpritePath(itemID: Int(event.item.itemID), scriptContext: scriptContext) else {
                return
            }

            let sprite = try await resourceManager.sprite(at: path)
            let animation = try await SpriteAnimation(sprite: sprite, actionIndex: 0)

            let entity = SpriteEntity(animations: [animation])
            entity.name = "\(event.item.objectID)"
            entity.scale = [1, 1 / cosf(elevation), 1]
            entity.transform = transform(for: event.position)
            entity.components.set([
                GridPositionComponent(gridPosition: event.position),
                MapGridComponent(mapGrid: mapGrid),
                MapItemComponent(mapItem: event.item),
            ])
            entity.playSpriteAnimation(at: 0, repeats: true)
            rootEntity.addChild(entity)
        }
    }

    func onItemVanished(_ event: ItemEvents.Vanished) {
        if let entity = rootEntity.findEntity(named: "\(event.objectID)") {
            entity.removeFromParent()
        }
    }
}
