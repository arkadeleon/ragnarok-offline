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
    public static func worldEntity(world: WorldResource) async throws -> Entity {
        let groundEntity = try await Entity.groundEntity(gat: world.gat, gnd: world.gnd)

        let uniqueModelNames = Set(world.rsw.models.map({ $0.modelName }))

        let modelEntitiesByName = await withThrowingTaskGroup(
            of: (modelName: String, modelEntity: Entity).self,
            returning: [String : Entity].self
        ) { taskGroup in
            for modelName in uniqueModelNames {
                taskGroup.addTask {
                    let components = modelName.split(separator: "\\").map(String.init)
                    let modelPath = ResourcePath.modelPath.appending(components: components)
                    let model = try await ResourceManager.default.model(at: modelPath)
                    let modelEntity = try await Entity.modelEntity(model: model)
                    return (modelName, modelEntity)
                }
            }

            var modelEntitiesByName: [String : Entity] = [:]
            while !taskGroup.isEmpty {
                if let result = try? await taskGroup.next() {
                    modelEntitiesByName[result.modelName] = result.modelEntity
                }
            }
            return modelEntitiesByName
        }

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

    public static func groundEntity(gat: GAT, gnd: GND) async throws -> Entity {
        var textureNames = [String]()
        let ground = Ground(gat: gat, gnd: gnd) { textureName in
            textureNames.append(textureName)
            return nil
        }

        var materials: [any Material] = []
        for textureName in textureNames {
            let components = textureName.split(separator: "\\").map(String.init)
            let texturePath = ResourcePath.texturePath.appending(components: components)
            let textureImage = try? await ResourceManager.default.image(at: texturePath)

            guard let textureImage else {
                materials.append(SimpleMaterial())
                continue
            }

            let textureResource = try? await TextureResource(image: textureImage, withName: textureName, options: .init(semantic: .color))

            guard let textureResource else {
                materials.append(SimpleMaterial())
                continue
            }

            var material = PhysicallyBasedMaterial()
            material.baseColor = .init(texture: .init(textureResource))
            materials.append(material)
        }

        let meshDescriptors = ground.meshes.enumerated().map { (index, mesh) in
            var meshDescriptor = MeshDescriptor()
            meshDescriptor.positions = MeshBuffer(mesh.vertices.map({ $0.position }))
            meshDescriptor.normals = MeshBuffer(mesh.vertices.map({ $0.normal }))
            meshDescriptor.textureCoordinates = MeshBuffer(mesh.vertices.map({ SIMD2($0.textureCoordinate.x, 1.0 - $0.textureCoordinate.y) }))

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
