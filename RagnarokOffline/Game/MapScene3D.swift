//
//  MapScene3D.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2025/3/27.
//

import RealityKit
import ROCore
import ROGame
import RONetwork
import RORendering
import ROResources
import Spatial
import SwiftUI

class MapScene3D: MapSceneProtocol {
    let mapName: String
    let world: WorldResource
    let player: MapObject

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
    private let monsterEntityManager: SpriteEntityManager

    var tileTapGesture: some Gesture {
        SpatialTapGesture()
            .targetedToEntity(where: .has(TileComponent.self))
            .onEnded { [unowned self] event in
                if let component = event.entity.components[TileComponent.self] {
                    let position = SIMD2(Int16(component.x), Int16(component.y))
                    self.mapSceneDelegate?.mapScene(self, didTapTileAt: position)
                }
            }
    }

    var mapObjectTapGesture: some Gesture {
        SpatialTapGesture()
            .targetedToEntity(where: .has(MapObjectComponent.self))
            .onEnded { [unowned self] event in
                if let component = event.entity.components[MapObjectComponent.self] {
                    self.mapSceneDelegate?.mapScene(self, didTapMapObject: component.object)
                }
            }
    }

    var mapItemTapGesture: some Gesture {
        SpatialTapGesture()
            .targetedToEntity(where: .has(MapItemComponent.self))
            .onEnded { [unowned self] event in
                if let component = event.entity.components[MapItemComponent.self] {
                    self.mapSceneDelegate?.mapScene(self, didTapMapItem: component.item)
                }
            }
    }

    init(mapName: String, world: WorldResource, player: MapObject) {
        self.mapName = mapName
        self.world = world
        self.player = player

        tileEntityManager = TileEntityManager(gat: world.gat, rootEntity: rootEntity)
        monsterEntityManager = SpriteEntityManager()

        MapItemComponent.registerComponent()
        MapObjectComponent.registerComponent()
        SpriteComponent.registerComponent()
        TileComponent.registerComponent()

        FromToByAction<Transform>.subscribe(to: .terminated) { event in
            if let spriteEntity = event.targetEntity as? SpriteEntity {
                spriteEntity.runAction(0, repeats: true)
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

        tileEntityManager.addTileEntities(for: player.position)

        do {
            let actions = try await SpriteAction.actions(forJobID: 0, configuration: SpriteConfiguration())
            let spriteComponent = SpriteComponent(actions: actions)
            playerEntity.components.set(spriteComponent)
        } catch {
            logger.warning("\(error.localizedDescription)")
        }

        playerEntity.name = "\(player.objectID)"
        playerEntity.transform = transform(for: player.position)
        playerEntity.runPlayerAction(.idle, direction: .south, repeats: true)

        rootEntity.addChild(playerEntity)

        let cameraComponent = PerspectiveCameraComponent(near: 2, far: 300, fieldOfViewInDegrees: 15)
        camera.components.set(cameraComponent)
        camera.transform = cameraTransform(for: player.position)
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
        playerEntity.walk(to: transform, direction: .south, duration: 1)

        let cameraTransform = cameraTransform(for: event.toPosition)
        camera.move(to: cameraTransform, relativeTo: nil, duration: 1, timingFunction: .linear)

        tileEntityManager.updateTileEntities(for: event.toPosition)
    }

    func onMapObjectSpawned(_ event: MapObjectEvents.Spawned) {
        if let entity = rootEntity.findEntity(named: "\(event.object.objectID)") as? SpriteEntity {
            let transform = transform(for: event.object.position)
            entity.transform = transform
        } else {
            Task {
                let jobID = UniformJobID(rawValue: event.object.job)
                if let monsterEntity = await monsterEntityManager.entity(forJobID: jobID) {
                    monsterEntity.name = "\(event.object.objectID)"
                    monsterEntity.transform = transform(for: event.object.position)
                    monsterEntity.isEnabled = (event.object.effectState != .cloak)
                    monsterEntity.components.set(MapObjectComponent(object: event.object))
                    monsterEntity.runPlayerAction(.idle, direction: .south, repeats: true)
                    rootEntity.addChild(monsterEntity)
                }
            }
        }
    }

    func onMapObjectMoved(_ event: MapObjectEvents.Moved) {
        if let entity = rootEntity.findEntity(named: "\(event.object.objectID)") as? SpriteEntity {
            let transform = transform(for: event.toPosition)
            entity.walk(to: transform, direction: .south, duration: 1)
        } else {
            Task {
                let jobID = UniformJobID(rawValue: event.object.job)
                if let monsterEntity = await monsterEntityManager.entity(forJobID: jobID) {
                    monsterEntity.name = "\(event.object.objectID)"
                    monsterEntity.transform = transform(for: event.toPosition)
                    monsterEntity.isEnabled = (event.object.effectState != .cloak)
                    monsterEntity.components.set(MapObjectComponent(object: event.object))
                    monsterEntity.runPlayerAction(.idle, direction: .south, repeats: true)
                    rootEntity.addChild(monsterEntity)
                }
            }
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

    func onMapObjectActionPerformed(_ event: MapObjectEvents.ActionPerformed) {
        if let entity = rootEntity.findEntity(named: "\(event.sourceObjectID)") as? SpriteEntity {
            switch event.actionType {
            case .normal, .endure, .multi_hit, .multi_hit_endure, .critical, .lucy_dodge, .multi_hit_critical:
                entity.runPlayerAction(.attack, direction: .south, repeats: false)
            case .pickup_item:
                entity.runPlayerAction(.pickup, direction: .south, repeats: false)
            case .sit_down:
                entity.runPlayerAction(.sit, direction: .south, repeats: true)
            case .stand_up:
                entity.runPlayerAction(.idle, direction: .south, repeats: true)
            default:
                break
            }
        }
    }

    func onItemSpawned(_ event: ItemEvents.Spawned) {
        Task {
            let actions = try await SpriteAction.actions(forItemID: Int(event.item.itemID))
            let entity = SpriteEntity(actions: actions)
            entity.name = "\(event.item.objectID)"
            entity.transform = transform(for: event.item.position)
            entity.components.set(MapItemComponent(item: event.item))
            entity.runAction(0, repeats: true)
            rootEntity.addChild(entity)
        }
    }

    func onItemVanished(_ event: ItemEvents.Vanished) {
        if let entity = rootEntity.findEntity(named: "\(event.objectID)") {
            entity.removeFromParent()
        }
    }
}
