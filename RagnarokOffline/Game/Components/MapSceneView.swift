//
//  MapSceneView.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2025/1/6.
//

import RealityKit
import ROClientResources
import ROCore
import RODatabase
import ROFileFormats
import RONetwork
import RORenderers
import Spatial
import SwiftUI

@available(iOS 18.0, macOS 15.0, visionOS 2.0, *)
struct MapSceneView: View {
    var mapSession: MapSession
    var gat: GAT
    var gnd: GND
    var position: SIMD2<Int16>

    @State private var root = Entity()
    @State private var player = Entity()
    @State private var camera = PerspectiveCamera()
    @State private var cameraHelper = Entity()

    @State private var distance: Float = 85

    var body: some View {
        RealityView { content in
            content.add(root)
            root.addChild(cameraHelper)

            let group = ModelSortGroup()

            let groundEntity = try? await Entity.loadGround(gat: gat, gnd: gnd) { textureName in
                let path = GRF.Path(components: ["data", "texture", textureName])
                let file = ClientResourceManager.default.grfEntryFile(at: path)
                guard let data = file?.contents() else {
                    return nil
                }
                let texture = CGImageCreateWithData(data)
                return texture
            }

            if let groundEntity {
                groundEntity.components.set(ModelSortGroupComponent(group: group, order: 0))
                groundEntity.transform = Transform(rotation: simd_quatf(angle: radians(-90), axis: [1, 0, 0]))
                root.addChild(groundEntity)
            }

            var meshDescriptors = [MeshDescriptor]()

            for y in 0..<gat.height {
                for x in 0..<gat.width {
                    let tile = gat.tile(atX: Int(x), y: Int(y))

                    guard tile.type == .walkable || tile.type == .walkable2 || tile.type == .walkable3 else {
                        continue
                    }

                    let p0: SIMD3<Float> = [Float(x) + 0, tile.bottomLeftAltitude / 5 - 0.1, Float(y) + 0]
                    let p1: SIMD3<Float> = [Float(x) + 1, tile.bottomRightAltitude / 5 - 0.1, Float(y) + 0]
                    let p2: SIMD3<Float> = [Float(x) + 1, tile.topRightAltitude / 5 - 0.1, Float(y) + 1]
                    let p3: SIMD3<Float> = [Float(x) + 1, tile.topRightAltitude / 5 - 0.1, Float(y) + 1]
                    let p4: SIMD3<Float> = [Float(x) + 0, tile.topLeftAltitude / 5 - 0.1, Float(y) + 1]
                    let p5: SIMD3<Float> = [Float(x) + 0, tile.bottomLeftAltitude / 5 - 0.1, Float(y) + 0]

                    var meshDescriptor = MeshDescriptor()
                    meshDescriptor.positions = MeshBuffer([p0, p1, p2, p3, p4, p5])
                    meshDescriptor.primitives = .triangles([0, 1, 2, 3, 4, 5])

                    meshDescriptors.append(meshDescriptor)
                }
            }

            if let mesh = try? MeshResource.generate(from: meshDescriptors) {
                var material = SimpleMaterial()
                material.color = SimpleMaterial.BaseColor(tint: .yellow)
                material.triangleFillMode = .lines

                let tileEntity = ModelEntity(mesh: mesh, materials: [material])
                tileEntity.components.set(ModelSortGroupComponent(group: group, order: 1))
                tileEntity.components.set(InputTargetComponent())
                tileEntity.transform = Transform(rotation: simd_quatf(angle: radians(-90), axis: [1, 0, 0]))
                tileEntity.generateCollisionShapes(recursive: false)
                root.addChild(tileEntity)
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

            camera.camera.fieldOfViewInDegrees = 15
            camera.transform = cameraTransform(for: position)
            root.addChild(camera)

            mapSession.notifyMapLoaded()
        } update: { content in
            
        } placeholder: {
            ProgressView()
        }
        .ignoresSafeArea()
        .overlay(alignment: .bottom) {
            Slider(value: $distance, in: 25...400)
        }
        .toolbar {
            ToolbarItem(placement: .automatic) {
                Button {
                    camera.transform = cameraTransform(for: position)
                } label: {
                    Text(verbatim: "Reset")
                }
            }
        }
        #if os(iOS) || os(macOS)
        .gesture(
            SpatialTapGesture()
                .targetedToAnyEntity()
                .onEnded { event in
                    if let position = event.unproject(\.location, to: .scene) {
                        mapSession.requestMove(x: Int16(position.x), y: Int16(position.y))
                    }
                }
        )
        #endif
        .onReceive(mapSession.publisher(for: PlayerEvents.Moved.self)) { event in
            let translation = position3D(for: event.toPosition)
            player.move(to: Transform(translation: translation), relativeTo: nil, duration: 0.2)

            let cameraTransform = cameraTransform(for: event.toPosition)
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

    private func cameraTransform(for position: SIMD2<Int16>) -> Transform {
        let target = position3D(for: position)

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
