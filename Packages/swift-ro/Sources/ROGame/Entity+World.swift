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

        let meshDescriptors = ground.meshes.enumerated().map { (index, mesh) in
            var meshDescriptor = MeshDescriptor()
            meshDescriptor.positions = MeshBuffer(mesh.vertices.map({ $0.position }))
            meshDescriptor.normals = MeshBuffer(mesh.vertices.map({ $0.normal }))
            meshDescriptor.textureCoordinates = MeshBuffer(mesh.vertices.map({ SIMD2(x: $0.textureCoordinate.x, y: 1.0 - $0.textureCoordinate.y) }))

            let indices = (0..<meshDescriptor.positions.count).map(UInt32.init)
            meshDescriptor.primitives = .triangles(indices)

            meshDescriptor.materials = .allFaces(UInt32(index))

            return meshDescriptor
        }
        let mesh = try MeshResource.generate(from: meshDescriptors)

        let groundEntity = ModelEntity(mesh: mesh, materials: materials)
        return groundEntity
    }
}
