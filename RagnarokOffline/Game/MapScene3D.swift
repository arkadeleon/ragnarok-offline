//
//  MapScene3D.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2025/3/27.
//

import RealityKit
import ROCore
import ROGame
import RORendering
import ROResources
import Spatial

class MapScene3D: MapSceneProtocol {
    let mapName: String
    let world: WorldResource
    let position: SIMD2<Int16>

    let rootEntity = Entity()

    weak var mapSceneDelegate: (any MapSceneDelegate)?

    var distance: Float = 80 {
        didSet {
            camera.transform = cameraTransform(for: player.position)
        }
    }

    private let player = SpriteEntity()
    private let camera = Entity()
    private let cameraHelper = Entity()

    private let tileEntityManager: TileEntityManager
    private let monsterEntityManager: SpriteEntityManager

    init(mapName: String, world: WorldResource, position: SIMD2<Int16>) {
        self.mapName = mapName
        self.world = world
        self.position = position

        tileEntityManager = TileEntityManager(gat: world.gat, rootEntity: rootEntity)
        monsterEntityManager = SpriteEntityManager()

        SpriteComponent.registerComponent()
        TileComponent.registerComponent()

        FromToByAction<Transform>.subscribe(to: .terminated) { event in
            if let spriteEntity = event.targetEntity as? SpriteEntity {
                spriteEntity.runAction(0)
            }
        }
    }

    deinit {
        FromToByAction<Transform>.unsubscribeAll()

        rootEntity.stopAllAudio()
    }

    func load() async {
        rootEntity.addChild(cameraHelper)

        let group = ModelSortGroup()

        if let worldEntity = try? await Entity.worldEntity(world: world) {
            worldEntity.components.set(ModelSortGroupComponent(group: group, order: 0))
            worldEntity.transform = Transform(rotation: simd_quatf(angle: radians(-180), axis: [1, 0, 0]))
            rootEntity.addChild(worldEntity)
        }

        tileEntityManager.addTileEntities(for: position)

        do {
            let actions = try await SpriteAction.actions(for: 0, configuration: SpriteConfiguration())
            let spriteComponent = SpriteComponent(actions: actions)
            player.components.set(spriteComponent)
        } catch {
            logger.warning("\(error.localizedDescription)")
        }

        player.name = "player"
        player.transform = transform(for: position)
        player.runPlayerAction(.idle, direction: .south)

        rootEntity.addChild(player)

        let cameraComponent = PerspectiveCameraComponent(near: 2, far: 300, fieldOfViewInDegrees: 15)
        camera.components.set(cameraComponent)
        camera.transform = cameraTransform(for: position)
        rootEntity.addChild(camera)

        if let bgmPath = await ResourcePath(mapBGMPathWithMapName: mapName) {
            let bgmURL = ResourceManager.default.baseURL.appending(path: bgmPath)
            let configuration = AudioFileResource.Configuration(shouldLoop: true, calibration: .relative(dBSPL: 20 * log10(10)))
            if let audio = try? await AudioFileResource(contentsOf: bgmURL, withName: mapName, configuration: configuration) {
                rootEntity.playAudio(audio)
            }
        }

        mapSceneDelegate?.mapSceneDidFinishLoading(self)
    }

    private func transform(for position2D: SIMD2<Int16>) -> Transform {
        let scale: SIMD3<Float> = [1, sqrtf(2), 1]
        let rotation = simd_quatf(angle: radians(0), axis: [1, 0, 0])
        let translation = position3D(for: position2D)
        let transform = Transform(scale: scale, rotation: rotation, translation: translation)
        return transform
    }

    private func cameraTransform(for position2D: SIMD2<Int16>) -> Transform {
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

    private func position3D(for position2D: SIMD2<Int16>) -> SIMD3<Float> {
        let altitude = world.gat.tile(atX: Int(position2D.x), y: Int(position2D.y)).averageAltitude
        let position: SIMD3<Float> = [
            Float(position2D.x),
            -altitude / 5,
            -Float(position2D.y),
        ]
        return position + [0.5, 2, 0]
    }

    // MARK: - MapSceneProtocol

    func onPlayerMoved(_ event: PlayerEvents.Moved) {
        let transform = transform(for: event.toPosition)
        player.walk(to: transform, direction: .south, duration: 1)

        let cameraTransform = cameraTransform(for: event.toPosition)
        camera.move(to: cameraTransform, relativeTo: nil, duration: 1, timingFunction: .linear)

        tileEntityManager.updateTileEntities(for: event.toPosition)
    }

    func onMapObjectSpawned(_ event: MapObjectEvents.Spawned) {
        Task {
            let jobID = UniformJobID(rawValue: Int(event.object.job))
            if let monsterEntity = await monsterEntityManager.entity(forJobID: jobID) {
                monsterEntity.name = "\(event.object.id)"
                monsterEntity.transform = transform(for: event.object.position)
                monsterEntity.isEnabled = (event.object.effectState != .cloak)

                rootEntity.addChild(monsterEntity)

                monsterEntity.runPlayerAction(.idle, direction: .south)
            }
        }
    }

    func onMapObjectMoved(_ event: MapObjectEvents.Moved) {
        if let entity = rootEntity.findEntity(named: "\(event.objectID)") as? SpriteEntity {
            let transform = transform(for: event.toPosition)
            entity.walk(to: transform, direction: .south, duration: 1)
        }
    }

    func onMapObjectStopped(_ event: MapObjectEvents.Stopped) {
        if let entity = rootEntity.findEntity(named: "\(event.objectID)") as? SpriteEntity {
            let transform = transform(for: event.position)
            entity.walk(to: transform, direction: .south, duration: 0)
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
}
