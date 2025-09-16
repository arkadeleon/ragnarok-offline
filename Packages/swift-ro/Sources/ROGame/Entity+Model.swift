//
//  Entity+Model.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2025/2/26.
//

import CoreGraphics
import FileFormats
import MetalRenderers
import RealityKit
import RORendering
import ROResources

extension Entity {
    public static func modelEntity(model: ModelResource, name: String, resourceManager: ResourceManager) async throws -> Entity {
        let instance = Model.createInstance(
            position: .zero,
            rotation: .zero,
            scale: .one,
            width: 0,
            height: 0
        )

        let modelEntity = try await Entity.modelEntity(rsm: model.rsm, instance: instance, resourceManager: resourceManager)
        modelEntity.name = name
        return modelEntity
    }

    public static func modelEntity(rsm: RSM, instance: simd_float4x4, resourceManager: ResourceManager) async throws -> Entity {
        let model = Model(rsm: rsm, instance: instance)

        let textureResources = await withTaskGroup(
            of: (String, TextureResource?).self,
            returning: [String : TextureResource].self
        ) { taskGroup in
            for mesh in model.meshes {
                let textureName = mesh.textureName
                taskGroup.addTask {
                    let components = textureName.split(separator: "\\").map(String.init)
                    let texturePath = ResourcePath.textureDirectory.appending(components)
                    let textureImage = try? await resourceManager.image(at: texturePath, removesMagentaPixels: true)
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

        let materials = model.meshes.map { mesh -> any Material in
            if let textureResource = textureResources[mesh.textureName] {
                var material = PhysicallyBasedMaterial()
                material.baseColor = PhysicallyBasedMaterial.BaseColor(texture: MaterialParameters.Texture(textureResource))
                material.blending = .transparent(opacity: 1.0)
                material.opacityThreshold = 0.9999
                return material
            } else {
                let material = SimpleMaterial()
                return material
            }
        }

        let mesh = try await {
            var descriptors: [MeshDescriptor] = []
            for (index, mesh) in model.meshes.enumerated() {
                var descriptor = MeshDescriptor(name: mesh.textureName)
                descriptor.positions = MeshBuffer(mesh.vertices.map({ $0.position }))
                descriptor.normals = MeshBuffer(mesh.vertices.map({ $0.normal }))
                descriptor.textureCoordinates = MeshBuffer(mesh.vertices.map({
                    SIMD2(x: $0.textureCoordinate.x, y: 1 - $0.textureCoordinate.y)
                }))

                let indices = (0..<descriptor.positions.count).map(UInt32.init)
                descriptor.primitives = .triangles(indices + indices.reversed())

                descriptor.materials = .allFaces(UInt32(index))

                descriptors.append(descriptor)
            }

            let mesh = try await MeshResource(from: descriptors)
            return mesh
        }()

        let modelEntity = ModelEntity(mesh: mesh, materials: materials)

        let scale = 2 / model.boundingBox.range.max()
        modelEntity.scale = [scale, scale, scale]

        return modelEntity
    }
}
