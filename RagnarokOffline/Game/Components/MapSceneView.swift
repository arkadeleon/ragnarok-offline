//
//  MapSceneView.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2025/1/6.
//

import RealityKit
import ROCore
import ROGame
import RONetwork
import RORendering
import ROResources
import Spatial
import SwiftUI

struct MapSceneView: View {
    var mapSession: MapSession
    var mapName: String
    var world: WorldResource
    var position: SIMD2<Int16>

    private let root = Entity()
    private let player = SpriteEntity()
    private let camera = Entity()
    private let cameraHelper = Entity()

    private let tileEntityManager: TileEntityManager
    private let monsterEntityManager: SpriteEntityManager

    @State private var distance: Float = 80

    var body: some View {
        RealityView { content in
            content.add(root)
            root.addChild(cameraHelper)

            let group = ModelSortGroup()

            if let worldEntity = try? await Entity.worldEntity(world: world) {
                worldEntity.components.set(ModelSortGroupComponent(group: group, order: 0))
                worldEntity.transform = Transform(rotation: simd_quatf(angle: radians(-180), axis: [1, 0, 0]))
                root.addChild(worldEntity)
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
            player.runPlayerAction(.walk, direction: .south)

            root.addChild(player)

            let perspectiveCameraComponent = PerspectiveCameraComponent(near: 2, far: 300, fieldOfViewInDegrees: 15)
            camera.components.set(perspectiveCameraComponent)
            camera.transform = cameraTransform(for: position)
            root.addChild(camera)

            if let bgmPath = await ResourcePath(mapBGMPathWithMapName: mapName) {
                let bgmURL = ResourceManager.default.baseURL.appending(path: bgmPath)
                let configuration = AudioFileResource.Configuration(shouldLoop: true, calibration: .relative(dBSPL: 20 * log10(10)))
                if let audio = try? await AudioFileResource(contentsOf: bgmURL, withName: mapName, configuration: configuration) {
                    root.playAudio(audio)
                }
            }

            mapSession.notifyMapLoaded()
        } update: { content in
        } placeholder: {
            ProgressView()
        }
        .ignoresSafeArea()
        .overlay(alignment: .bottom) {
            Slider(value: $distance, in: 2...300)
                .onChange(of: distance) { oldValue, newValue in
                    camera.transform = cameraTransform(for: player.position)
                }
        }
        .gesture(
            SpatialTapGesture()
                .targetedToEntity(where: .has(TileComponent.self))
                .onEnded { event in
                    if let tileComponent = event.entity.components[TileComponent.self] {
                        mapSession.requestMove(x: Int16(tileComponent.x), y: Int16(tileComponent.y))
                    }
                }
        )
        .gesture(
            SpatialTapGesture()
                .targetedToEntity(where: .has(SpriteComponent.self))
                .onEnded { event in
                    logger.info("Tap sprite entity: \(event.entity.name)")
                }
        )
        .onDisappear {
            root.stopAllAudio()
        }
        .onReceive(mapSession.publisher(for: PlayerEvents.Moved.self)) { event in
            let transform = transform(for: event.toPosition)
            player.move(to: transform, relativeTo: nil, duration: 1)

            let cameraTransform = cameraTransform(for: event.toPosition)
            camera.move(to: cameraTransform, relativeTo: nil, duration: 1)

            tileEntityManager.updateTileEntities(for: event.toPosition)
        }
        .onReceive(mapSession.publisher(for: MapObjectEvents.Spawned.self)) { event in
            Task {
                let jobID = UniformJobID(rawValue: Int(event.object.job))
                if let monsterEntity = await monsterEntityManager.entity(forJobID: jobID) {
                    monsterEntity.name = "\(event.object.id)"
                    monsterEntity.transform = transform(for: event.object.position)
                    monsterEntity.isEnabled = (event.object.effectState != .cloak)

                    root.addChild(monsterEntity)

                    monsterEntity.runPlayerAction(.idle, direction: .south)
                }
            }
        }
        .onReceive(mapSession.publisher(for: MapObjectEvents.Moved.self)) { event in
            if let entity = root.findEntity(named: "\(event.objectID)") {
                let transform = transform(for: event.toPosition)
                entity.move(to: transform, relativeTo: nil, duration: 1)
            }
        }
        .onReceive(mapSession.publisher(for: MapObjectEvents.Stopped.self)) { event in
            if let entity = root.findEntity(named: "\(event.objectID)") {
                let transform = transform(for: event.position)
                entity.move(to: transform, relativeTo: nil)
            }
        }
        .onReceive(mapSession.publisher(for: MapObjectEvents.Vanished.self)) { event in
            if let entity = root.findEntity(named: "\(event.objectID)") {
                entity.removeFromParent()
            }
        }
        .onReceive(mapSession.publisher(for: MapObjectEvents.StateChanged.self)) { event in
            if let entity = root.findEntity(named: "\(event.objectID)") {
                entity.isEnabled = (event.effectState != .cloak)
            }
        }
    }

    init(mapSession: MapSession, mapName: String, world: WorldResource, position: SIMD2<Int16>) {
        self.mapSession = mapSession
        self.mapName = mapName
        self.world = world
        self.position = position

        tileEntityManager = TileEntityManager(gat: world.gat, rootEntity: root)
        monsterEntityManager = SpriteEntityManager()

        SpriteComponent.registerComponent()
        TileComponent.registerComponent()
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
}
