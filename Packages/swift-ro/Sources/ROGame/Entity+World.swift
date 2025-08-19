//
//  Entity+World.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2025/2/26.
//

import CoreGraphics
import RealityKit
import ROCore
import ROFileFormats
import RORenderers
import RORendering
import ROResources

extension Entity {
    public static func worldEntity(world: WorldResource, resourceManager: ResourceManager) async throws -> Entity {
        let groundEntity = try await Entity.groundEntity(gat: world.gat, gnd: world.gnd, resourceManager: resourceManager)

        let waterEntity = try await Entity.waterEntity(gnd: world.gnd, rsw: world.rsw, resourceManager: resourceManager)
        groundEntity.addChild(waterEntity)

        let uniqueModelNames = Set(world.rsw.models.map({ $0.modelName }))

        metric.beginMeasuring("Load model entities")

        let modelEntitiesByName = await withThrowingTaskGroup(
            of: Entity.self,
            returning: [String : Entity].self
        ) { taskGroup in
            for modelName in uniqueModelNames {
                taskGroup.addTask {
                    let components = modelName.split(separator: "\\").map(String.init)
                    let modelPath = ResourcePath.modelDirectory.appending(components)
                    let model = try await resourceManager.model(at: modelPath)
                    let modelEntity = try await Entity.modelEntity(model: model, name: modelName, resourceManager: resourceManager)
                    return modelEntity
                }
            }

            var modelEntitiesByName: [String : Entity] = [:]

            do {
                for try await modelEntity in taskGroup {
                    modelEntitiesByName[modelEntity.name] = modelEntity
                }
            } catch {
                logger.warning("\(error.localizedDescription)")
            }

            return modelEntitiesByName
        }

        metric.endMeasuring("Load model entities")

        for model in world.rsw.models {
            guard let modelEntity = modelEntitiesByName[model.modelName] else {
                continue
            }

            let modelEntityClone = modelEntity.clone(recursive: true)

            modelEntityClone.position = [
                model.position.x + Float(world.gnd.width),
                model.position.y,
                model.position.z + Float(world.gnd.height),
            ]
            modelEntityClone.orientation =
                simd_quatf(angle: radians(model.rotation.z), axis: [0, 0, 1]) *
                simd_quatf(angle: radians(model.rotation.x), axis: [1, 0, 0]) *
                simd_quatf(angle: radians(model.rotation.y), axis: [0, 1, 0])
            modelEntityClone.scale = model.scale

            groundEntity.addChild(modelEntityClone)
        }

        return groundEntity
    }

    public static func groundEntity(gat: GAT, gnd: GND, resourceManager: ResourceManager) async throws -> Entity {
        let ground = Ground(gat: gat, gnd: gnd)

        let textureResources = await withTaskGroup(
            of: (String, TextureResource?).self,
            returning: [String : TextureResource].self
        ) { taskGroup in
            for mesh in ground.meshes {
                let textureName = mesh.textureName
                taskGroup.addTask {
                    let components = textureName.split(separator: "\\").map(String.init)
                    let texturePath = ResourcePath.textureDirectory.appending(components)
                    let textureImage = try? await resourceManager.image(at: texturePath)
                    guard let textureImage else {
                        return (textureName, nil)
                    }

                    let textureResource = try? await TextureResource(
                        image: textureImage,
                        withName: textureName,
                        options: TextureResource.CreateOptions(semantic: .color)
                    )
                    return (textureName, textureResource)
                }
            }

            var textureResources: [String : TextureResource] = [:]
            for await (textureName, textureResource) in taskGroup {
                textureResources[textureName] = textureResource
            }
            return textureResources
        }

        let materials = ground.meshes.map { mesh -> any Material in
            if let textureResource = textureResources[mesh.textureName] {
                var material = PhysicallyBasedMaterial()
                material.baseColor = PhysicallyBasedMaterial.BaseColor(texture: MaterialParameters.Texture(textureResource))
                return material
            } else {
                let material = SimpleMaterial()
                return material
            }
        }

        let mesh = try await {
            var descriptors: [MeshDescriptor] = []
            for (index, mesh) in ground.meshes.enumerated() {
                var descriptor = MeshDescriptor(name: mesh.textureName)
                descriptor.positions = MeshBuffer(mesh.vertices.map({ $0.position }))
                descriptor.normals = MeshBuffer(mesh.vertices.map({ $0.normal }))
                descriptor.textureCoordinates = MeshBuffer(mesh.vertices.map({
                    SIMD2(x: $0.textureCoordinate.x, y: 1 - $0.textureCoordinate.y)
                }))

                let indices = (0..<descriptor.positions.count).map(UInt32.init)
                descriptor.primitives = .triangles(indices)

                descriptor.materials = .allFaces(UInt32(index))

                descriptors.append(descriptor)
            }

            let mesh = try await MeshResource(from: descriptors)
            return mesh
        }()

        let groundEntity = ModelEntity(mesh: mesh, materials: materials)
        return groundEntity
    }

    public static func waterEntity(gnd: GND, rsw: RSW, resourceManager: ResourceManager) async throws -> Entity {
        let water = Water(gnd: gnd, rsw: rsw)

        if water.mesh.vertices.isEmpty {
            return Entity()
        }

        let textureImage = await withTaskGroup(
            of: (Int, CGImage?).self,
            returning: CGImage?.self
        ) { taskGroup in
            for i in 0..<32 {
                let textureName = String(format: "water%03d.jpg", i)
                let texturePath = ResourcePath.textureDirectory.appending([K2L("워터"), textureName])
                taskGroup.addTask {
                    let image = try? await resourceManager.image(at: texturePath)
                    return (i, image)
                }
            }

            var textureImages: [Int : CGImage?] = [:]
            for await (index, image) in taskGroup {
                textureImages[index] = image
            }

            let size = CGSize(width: 128 * textureImages.count, height: 128)
            let renderer = CGImageRenderer(size: size, flipped: false)
            let image = renderer.image { cgContext in
                for textureIndex in 0..<textureImages.count {
                    if let image = textureImages[textureIndex], let image {
                        let rect = CGRect(x: 128 * textureIndex, y: 0, width: 128, height: 128)
                        cgContext.draw(image, in: rect)
                    }
                }
            }
            return image
        }

        let textureResource: TextureResource?
        if let textureImage {
            textureResource = try await TextureResource(
                image: textureImage,
                withName: "water",
                options: TextureResource.CreateOptions(semantic: .color)
            )
        } else {
            textureResource = nil
        }

        let materials: [any Material]
        if let textureResource {
            var material = PhysicallyBasedMaterial()
            material.baseColor = PhysicallyBasedMaterial.BaseColor(texture: MaterialParameters.Texture(textureResource))
            material.textureCoordinateTransform = MaterialParameterTypes.TextureCoordinateTransform(scale: [1 / Float(32), 1])
            materials = [material]
        } else {
            let material = SimpleMaterial()
            materials = [material]
        }

        let mesh = try await {
            var descriptor = MeshDescriptor(name: "water")
            descriptor.positions = MeshBuffer(water.mesh.vertices.map({ $0.position }))
            descriptor.textureCoordinates = MeshBuffer(water.mesh.vertices.map({
                SIMD2(x: $0.textureCoordinate.x, y: $0.textureCoordinate.y)
            }))

            let indices = (0..<descriptor.positions.count).map(UInt32.init)
            descriptor.primitives = .triangles(indices)

            descriptor.materials = .allFaces(0)

            let mesh = try await MeshResource(from: [descriptor])
            return mesh
        }()

        let waterEntity = Entity(components: [
            ModelComponent(mesh: mesh, materials: materials),
            OpacityComponent(opacity: 0.6),
        ])

        let frames: [SIMD2<Float>] = (0..<32).map { frameIndex in
            [Float(frameIndex) / 32, 0]
        }
        let animationDefinition = SampledAnimation(
            frames: frames,
            name: "flow",
            tweenMode: .hold,
            frameInterval: 1 / 30,
            isAdditive: false,
            bindTarget: .material(0).textureCoordinate.offset,
            repeatMode: .repeat
        )
        let animationResource = try AnimationResource.generate(with: animationDefinition)
        waterEntity.playAnimation(animationResource)

        return waterEntity
    }
}
