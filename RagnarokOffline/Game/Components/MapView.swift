//
//  MapView.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/9/10.
//

import RealityKit
import ROClientResources
import ROCore
import RODatabase
import ROFileFormats
import RONetwork
import RORenderers
import SwiftUI

@available(iOS 18.0, macOS 15.0, visionOS 2.0, *)
struct MapView: View {
    var mapSession: MapSession
    var mapName: String
    var position: SIMD2<Int16>

    @State private var root = Entity()
    @State private var player = Entity()
    @State private var camera = PerspectiveCamera()

    var body: some View {
        RealityView { content in
            content.add(root)

            guard let gatFile = await ClientResourceManager.default.gatFile(forMapName: mapName),
                  let gatData = gatFile.contents(),
                  let gat = try? GAT(data: gatData) else {
                return
            }

            guard let gndFile = await ClientResourceManager.default.gndFile(forMapName: mapName),
                  let gndData = gndFile.contents(),
                  let gnd = try? GND(data: gndData) else {
                return
            }

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
                groundEntity.transform = Transform(rotation: simd_quatf(angle: radians(-90), axis: [1, 0, 0]))

                groundEntity.generateCollisionShapes(recursive: false)

                groundEntity.components.set(InputTargetComponent())

                root.addChild(groundEntity)
            }

//            var meshDescriptors = [MeshDescriptor]()
//
//            for y in 0..<gat.height {
//                for x in 0..<gat.width {
//                    let tile = gat.tile(atX: Int(x), y: Int(y))
//
//                    guard tile.type == .walkable || tile.type == .walkable2 || tile.type == .walkable3 else {
//                        continue
//                    }
//
//                    let p0: SIMD3<Float> = [Float(x) + 0, tile.bottomLeftAltitude / 5, Float(y) + 0]
//                    let p1: SIMD3<Float> = [Float(x) + 1, tile.bottomRightAltitude / 5, Float(y) + 0]
//                    let p2: SIMD3<Float> = [Float(x) + 1, tile.topRightAltitude / 5, Float(y) + 1]
//                    let p3: SIMD3<Float> = [Float(x) + 1, tile.topRightAltitude / 5, Float(y) + 1]
//                    let p4: SIMD3<Float> = [Float(x) + 0, tile.topLeftAltitude / 5, Float(y) + 1]
//                    let p5: SIMD3<Float> = [Float(x) + 0, tile.bottomLeftAltitude / 5, Float(y) + 0]
//
//                    var meshDescriptor = MeshDescriptor()
//                    meshDescriptor.positions = MeshBuffer([p0, p1, p2, p3, p4, p5])
//                    meshDescriptor.primitives = .triangles([0, 1, 2, 3, 4, 5])
////                    meshDescriptor.materials = .allFaces(0)
//
//                    meshDescriptors.append(meshDescriptor)
//                }
//            }
//
//            if let mesh = try? MeshResource.generate(from: meshDescriptors) {
//                let tileEntity = ModelEntity(mesh: mesh)
//
//                tileEntity.transform = Transform(rotation: simd_quatf(angle: radians(-90), axis: [1, 0, 0]))
//
//                tileEntity.generateCollisionShapes(recursive: false)
//
//                tileEntity.components.set(InputTargetComponent())
//
//                root.addChild(tileEntity)
//            }

            var material = PhysicallyBasedMaterial()
            material.metallic = PhysicallyBasedMaterial.Metallic()
            material.baseColor = PhysicallyBasedMaterial.BaseColor(tint: .white)
            player.components.set(
                ModelComponent(mesh: .generateBox(width: 1, height: 1, depth: 2), materials: [material])
            )
            player.name = "player"
            player.position = [Float(position.x), Float(position.y), 0]
            root.addChild(player)

            camera.position = [Float(position.x), Float(position.y) - 50, 65]
            camera.look(at: [Float(position.x), Float(position.y), 0], from: camera.position, relativeTo: nil)
            root.addChild(camera)

            mapSession.notifyMapLoaded()
        } update: { content in

        } placeholder: {
            ProgressView()
        }
        .ignoresSafeArea()
        .overlay(alignment: .topLeading) {
            PlayerStatusOverlayView(mapSession: mapSession)
        }
        .overlay {
            NPCDialogOverlayView(mapSession: mapSession)
        }
        .overlay(alignment: .bottom) {
            VStack {
                Slider(value: $camera.position.x, in: 0...400)
                Slider(value: $camera.position.y, in: 0...400)
                Slider(value: $camera.position.z, in: 0...400)
            }
        }
        .toolbar {
            ToolbarItem(placement: .automatic) {
                Button {
                    camera.position = [Float(position.x), Float(position.y) - 50, 65]
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
            let translation: SIMD3<Float> = [
                Float(event.toPosition.x),
                Float(event.toPosition.y),
                0,
            ]
            player.move(to: Transform(translation: translation), relativeTo: nil, duration: 0.2)

            let cameraTranslation: SIMD3<Float> = [
                Float(event.toPosition.x - event.fromPosition.x),
                Float(event.toPosition.y - event.fromPosition.y),
                0,
            ]
            camera.move(to: Transform(translation: cameraTranslation), relativeTo: camera, duration: 0.2)
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
            entity.position = [Float(event.object.position.x), Float(event.object.position.y), 0]
            entity.isEnabled = (event.object.effectState != .cloak)

            let frames: [SIMD2<Float>] = [
                [0, 0],
                [0.1, 0],
            ]
            let bindTarget = BindTarget.material(0).textureCoordinate.offset
            let animationDefinition = SampledAnimation(
                frames: frames,
                name: "walk",
                tweenMode: .hold,
                frameInterval: 0.2,
                isAdditive: false,
                bindTarget: bindTarget,
                repeatMode: .repeat
            )
            if let animation = try? AnimationResource.generate(with: animationDefinition) {
                animation.store(in: entity)
            }

            root.addChild(entity)
        }
        .onReceive(mapSession.publisher(for: MapObjectEvents.Moved.self)) { event in
            if let entity = root.findEntity(named: "\(event.objectID)") {
                let translation: SIMD3<Float> = [
                    Float(event.toPosition.x),
                    Float(event.toPosition.y),
                    0,
                ]
                entity.move(to: Transform(translation: translation), relativeTo: nil, duration: 0.2)
            }
        }
        .onReceive(mapSession.publisher(for: MapObjectEvents.Stopped.self)) { event in
            if let entity = root.findEntity(named: "\(event.objectID)") {
                let translation: SIMD3<Float> = [
                    Float(event.position.x),
                    Float(event.position.y),
                    0,
                ]
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
}

//#Preview {
//    struct AsyncMapView: View {
//        @State private var scene: GameMapScene?
//
//        @Environment(\.gameSession) private var gameSession
//
//        var body: some View {
//            ZStack {
//                if let scene {
//                    MapView(scene: scene)
//                } else {
//                    ProgressView()
//                }
//            }
//            .task {
//                let map = try! await MapDatabase.renewal.map(forName: "iz_int")!
//                let grid = map.grid()!
//                self.scene = GameMapScene(name: "iz_int", grid: grid, position: [18, 26])
//            }
//        }
//    }
//
//    return AsyncMapView()
//}
