//
//  MapSceneView.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2025/1/6.
//

import RealityKit
import ROCore
import RODatabase
import ROFileFormats
import ROGame
import RONetwork
import RORenderers
import ROResources
import Spatial
import SwiftUI

struct MapSceneView: View {
    var mapSession: MapSession
    var mapName: String
    var gat: GAT
    var gnd: GND
    var position: SIMD2<Int16>

    @State private var root = Entity()
    @State private var player = Entity()
    @State private var camera = Entity()
    @State private var cameraHelper = Entity()

    @State private var distance: Float = 100

    @State private var tappedLocation: CGPoint?

    var body: some View {
        RealityView { content in
            content.add(root)
            root.addChild(cameraHelper)

            let group = ModelSortGroup()

            if let worldEntity = try? await GameResourceManager.default.worldEntity(mapName: mapName) {
                worldEntity.components.set(ModelSortGroupComponent(group: group, order: 0))
                worldEntity.transform = Transform(rotation: simd_quatf(angle: radians(-90), axis: [1, 0, 0]))
                root.addChild(worldEntity)
            }

            var gridPositions = [SIMD3<Float>]()
            var gridPositionIndices = [UInt32]()
            var index: UInt32 = 0
            for y in 0..<gat.height {
                for x in 0..<gat.width {
                    let tile = gat.tile(atX: Int(x), y: Int(y))

                    guard tile.type == .walkable || tile.type == .walkable2 || tile.type == .walkable3 else {
                        continue
                    }

                    let p0: SIMD3<Float> = [Float(x) + 0, tile.bottomLeftAltitude / 5, Float(y) + 0]
                    let p1: SIMD3<Float> = [Float(x) + 1, tile.bottomRightAltitude / 5, Float(y) + 0]
                    let p2: SIMD3<Float> = [Float(x) + 1, tile.topRightAltitude / 5, Float(y) + 1]
                    let p3: SIMD3<Float> = [Float(x) + 0, tile.topLeftAltitude / 5, Float(y) + 1]

                    gridPositions.append(contentsOf: [p0, p1, p2, p3])
                    gridPositionIndices.append(contentsOf: [index, index + 1, index + 2, index + 2, index + 3, index])
                    index += 4
                }
            }

            var meshDescriptor = MeshDescriptor(name: "grid")
            meshDescriptor.positions = MeshBuffers.Positions(gridPositions)
            meshDescriptor.primitives = .triangles(gridPositionIndices)
            if let mesh = try? MeshResource.generate(from: [meshDescriptor]) {
                var material = SimpleMaterial()
                material.color = SimpleMaterial.BaseColor(tint: .yellow)
                material.triangleFillMode = .lines

                let gridEntity = ModelEntity(mesh: mesh, materials: [material])
                gridEntity.name = "grid"
                gridEntity.components.set(ModelSortGroupComponent(group: group, order: 1))
                gridEntity.components.set(InputTargetComponent())
                gridEntity.transform = Transform(rotation: simd_quatf(angle: radians(-90), axis: [1, 0, 0]), translation: [0, 0, 0.0001])
                gridEntity.generateCollisionShapes(recursive: false)
                root.addChild(gridEntity)
            }

            var material = PhysicallyBasedMaterial()
            material.metallic = PhysicallyBasedMaterial.Metallic()
            material.baseColor = PhysicallyBasedMaterial.BaseColor(tint: .white)
            player.components.set(
                ModelComponent(mesh: .generateBox(width: 1, height: 1, depth: 2), materials: [material])
            )
            player.name = "player"
            player.position = position3D(for: position)
            root.addChild(player)

            let perspectiveCameraComponent = PerspectiveCameraComponent(near: 2, far: 300, fieldOfViewInDegrees: 15)
            camera.components.set(perspectiveCameraComponent)
            camera.transform = cameraTransform(for: player.position)
            root.addChild(camera)

            if let bgm = MapInfoTable.shared.mapBGM(forMapName: mapName) {
                let url = GameResourceManager.default.baseURL.appending(path: "BGM/\(bgm)")
                let configuration = AudioFileResource.Configuration(shouldLoop: true)
                if let audioResource = try? await AudioFileResource(contentsOf: url, withName: bgm, configuration: configuration) {
                    root.playAudio(audioResource)
                }
            }

            mapSession.notifyMapLoaded()
        } update: { content in
            #if os(iOS) || os(macOS)
            if let tappedLocation {
                if let ray = content.ray(through: tappedLocation, in: .global, to: .scene) {
                    Task {
                        if let hit = try await root.scene?.pixelCast(origin: ray.origin, direction: ray.direction, length: 300) {
                            if hit.entity.name == "grid" {
                                mapSession.requestMove(x: Int16(hit.position.x), y: Int16(hit.position.y))
                            }
                        }
                    }
                }
            }
            #endif
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
        #if os(iOS) || os(macOS)
        .gesture(
            SpatialTapGesture(coordinateSpace: .global)
                .onEnded { event in
                    tappedLocation = event.location
                }
        )
        #endif
        .onDisappear {
            root.stopAllAudio()
        }
        .onReceive(mapSession.publisher(for: PlayerEvents.Moved.self)) { event in
            let position = position3D(for: event.toPosition)
            player.move(to: Transform(translation: position), relativeTo: nil, duration: 0.2)

            let cameraTransform = cameraTransform(for: position)
            camera.move(to: cameraTransform, relativeTo: nil, duration: 0.2)
        }
        .onReceive(mapSession.publisher(for: MapObjectEvents.Spawned.self)) { event in
            var material = PhysicallyBasedMaterial()
            material.metallic = PhysicallyBasedMaterial.Metallic()
            material.baseColor = PhysicallyBasedMaterial.BaseColor(tint: .blue)

            let entity = ModelEntity(
                mesh: .generateBox(width: 1, height: 1, depth: 2),
                materials: [material]
            )
            entity.name = "\(event.object.id)"
            entity.position = position3D(for: event.object.position)
            entity.isEnabled = (event.object.effectState != .cloak)

            root.addChild(entity)
        }
        .onReceive(mapSession.publisher(for: MapObjectEvents.Moved.self)) { event in
            if let entity = root.findEntity(named: "\(event.objectID)") {
                let translation = position3D(for: event.toPosition)
                entity.move(to: Transform(translation: translation), relativeTo: nil, duration: 0.2)
            }
        }
        .onReceive(mapSession.publisher(for: MapObjectEvents.Stopped.self)) { event in
            if let entity = root.findEntity(named: "\(event.objectID)") {
                let translation = position3D(for: event.position)
                entity.move(to: Transform(translation: translation), relativeTo: nil)
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

    private func position3D(for position2D: SIMD2<Int16>) -> SIMD3<Float> {
        let altitude = gat.tile(atX: Int(position2D.x), y: Int(position2D.y)).averageAltitude
        return [
            Float(position2D.x),
            Float(position2D.y),
            -altitude / 5,
        ]
    }

    private func cameraTransform(for target: SIMD3<Float>) -> Transform {
        var position = target + [0, 0, distance]
        var point = Point3D(position)
        point = point.rotated(
            by: simd_quatd(angle: radians(30), axis: [1, 0, 0]),
            around: Point3D(target)
        )
        position = SIMD3(point)

        cameraHelper.look(at: target, from: position, relativeTo: nil)
        return cameraHelper.transform
    }
}
