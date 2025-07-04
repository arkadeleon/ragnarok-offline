//
//  MapScene3D.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2025/3/27.
//

import AVFAudio
import RealityKit
import ROCore
import RONetwork
import RORendering
import ROResources
import Spatial
import SwiftUI

class MapScene3D: MapSceneProtocol {
    let mapName: String
    let world: WorldResource
    let player: MapObject
    let playerPosition: SIMD2<Int>

    let resourceManager: ResourceManager

    let rootEntity = Entity()

    weak var mapSceneDelegate: (any MapSceneDelegate)?

    var distance: Float = 80 {
        didSet {
            camera.transform = cameraTransform(for: playerEntity.position)
        }
    }

    private let playerEntity = SpriteEntity()
    private let camera = Entity()
    private let cameraHelper = Entity()

    private let tileEntityManager: TileEntityManager
    private let spriteEntityManager: SpriteEntityManager

    private let pathfinder: Pathfinder

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

        self.resourceManager = resourceManager

        self.tileEntityManager = TileEntityManager(gat: world.gat, rootEntity: rootEntity)
        self.spriteEntityManager = SpriteEntityManager(resourceManager: resourceManager)

        self.pathfinder = Pathfinder(gat: world.gat)

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
        FromToByAction<Transform>.subscribe(to: .terminated) { event in
            if let spriteEntity = event.targetEntity as? SpriteEntity {
                spriteEntity.playSpriteAnimation(at: 0, repeats: true)
            }
        }

        rootEntity.addChild(cameraHelper)

        let group = ModelSortGroup()

        if let worldEntity = try? await Entity.worldEntity(world: world, resourceManager: resourceManager) {
            worldEntity.components.set(ModelSortGroupComponent(group: group, order: 0))
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
            let composedSprite = await ComposedSprite(configuration: configuration, resourceManager: resourceManager)

            let animations = try await SpriteAnimation.animations(for: composedSprite)
            let spriteComponent = SpriteComponent(animations: animations)
            playerEntity.components.set(spriteComponent)
        } catch {
            logger.warning("\(error.localizedDescription)")
        }

        playerEntity.name = "\(player.objectID)"
        playerEntity.transform = transform(for: playerPosition)
        playerEntity.components.set(MapObjectComponent(mapObject: player, position: playerPosition))
        playerEntity.playSpriteAnimation(.idle, direction: .south, repeats: true)

        rootEntity.addChild(playerEntity)

        let cameraComponent = PerspectiveCameraComponent(near: 2, far: 300, fieldOfViewInDegrees: 15)
        camera.components.set(cameraComponent)
        camera.transform = cameraTransform(for: playerPosition)
        rootEntity.addChild(camera)

        mapSceneDelegate?.mapSceneDidFinishLoading(self)
    }

    func unload() {
        FromToByAction<Transform>.unsubscribeAll()

        rootEntity.stopAllAudio()
    }

    private func transform(for position2D: SIMD2<Int>) -> Transform {
        let scale: SIMD3<Float> = [1, sqrtf(2), 1]
        let rotation = simd_quatf(angle: radians(0), axis: [1, 0, 0])
        let translation = position3D(for: position2D)
        let transform = Transform(scale: scale, rotation: rotation, translation: translation)
        return transform
    }

    private func cameraTransform(for position2D: SIMD2<Int>) -> Transform {
        let target = position3D(for: position2D)
        let transform = cameraTransform(for: target)
        return transform
    }

    private func cameraTransform(for target: SIMD3<Float>) -> Transform {
        var position = target + [0, distance, 0]
        var point = Point3D(position)
        point = point.rotated(
            by: simd_quatd(angle: radians(45), axis: [1, 0, 0]),
            around: Point3D(target)
        )
        position = SIMD3(point)

        cameraHelper.look(at: target, from: position, upVector: [0, 0, -1], relativeTo: nil)
        return cameraHelper.transform
    }

    private func position3D(for position2D: SIMD2<Int>) -> SIMD3<Float> {
        let altitude = world.gat.tileAt(x: position2D.x, y: position2D.y).averageAltitude
        let position: SIMD3<Float> = [
            Float(position2D.x),
            -altitude / 5,
            -Float(position2D.y),
        ]
        return position + [0.5, 2, 0]
    }

    private func audioResource(forMapName: String) async -> AudioResource? {
        guard let mp3Name = await resourceManager.mp3NameTable().mp3Name(forMapName: mapName) else {
            return nil
        }

        let bgmPath: ResourcePath = ["BGM", mp3Name]
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

    // MARK: - MapSceneProtocol

    func onPlayerMoved(_ event: PlayerEvents.Moved) {
        let startPosition = playerEntity.components[MapObjectComponent.self]?.position ?? event.startPosition
        let endPosition = event.endPosition
        let path = pathfinder.findPath(from: startPosition, to: endPosition)
        let path2 = path.map({ ($0, transform(for: $0)) })

        playerEntity.walk(through: path2)

        do {
            let speed = TimeInterval(playerEntity.components[MapObjectComponent.self]?.mapObject.speed ?? 0) / 1000

            var cameraAnimationSequence: [AnimationResource] = []
            for i in 1..<path.count {
                let source = cameraTransform(for: path[i - 1])
                let target = cameraTransform(for: path[i])
                let moveAction = FromToByAction(from: source, to: target, timing: .linear)
                let moveAnimation = try AnimationResource.makeActionAnimation(for: moveAction, duration: speed, bindTarget: .transform)
                cameraAnimationSequence.append(moveAnimation)
            }
            let animationResource = try AnimationResource.sequence(with: cameraAnimationSequence)
            camera.playAnimation(animationResource)
        } catch {

        }

        tileEntityManager.updateTileEntities(forPosition: event.endPosition)
    }

    func onMapObjectSpawned(_ event: MapObjectEvents.Spawned) {
        if let entity = rootEntity.findEntity(named: "\(event.object.objectID)") as? SpriteEntity {
            let transform = transform(for: event.position)
            entity.transform = transform
            entity.components[MapObjectComponent.self]?.position = event.position
        } else {
            Task {
                if let entity = try? await spriteEntityManager.entity(for: event.object) {
                    entity.name = "\(event.object.objectID)"
                    entity.transform = transform(for: event.position)
                    entity.isEnabled = (event.object.effectState != .cloak)
                    entity.components.set(MapObjectComponent(mapObject: event.object, position: event.position))
                    entity.playSpriteAnimation(.idle, direction: .south, repeats: true)
                    rootEntity.addChild(entity)
                }
            }
        }
    }

    func onMapObjectMoved(_ event: MapObjectEvents.Moved) {
        if let entity = rootEntity.findEntity(named: "\(event.object.objectID)") as? SpriteEntity {
            let startPosition = entity.components[MapObjectComponent.self]?.position ?? event.startPosition
            let endPosition = event.endPosition
            let path = pathfinder.findPath(from: startPosition, to: endPosition)
            let path2 = path.map({ ($0, transform(for: $0)) })
            entity.walk(through: path2)
        } else {
            Task {
                if let entity = try? await spriteEntityManager.entity(for: event.object) {
                    entity.name = "\(event.object.objectID)"
                    entity.transform = transform(for: event.endPosition)
                    entity.isEnabled = (event.object.effectState != .cloak)
                    entity.components.set(MapObjectComponent(mapObject: event.object, position: event.endPosition))
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
            let pathGenerator = ResourcePathGenerator(resourceManager: resourceManager)
            guard let path = await pathGenerator.generateItemSpritePath(itemID: Int(event.item.itemID)) else {
                return
            }

            let sprite = try await resourceManager.sprite(at: path)
            let animation = try await SpriteAnimation(sprite: sprite, actionIndex: 0)

            let entity = SpriteEntity(animations: [animation])
            entity.name = "\(event.item.objectID)"
            entity.transform = transform(for: event.position)
            entity.components.set(MapItemComponent(mapItem: event.item, position: event.position))
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
