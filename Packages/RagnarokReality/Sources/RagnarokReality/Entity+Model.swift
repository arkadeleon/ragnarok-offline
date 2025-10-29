//
//  Entity+Model.swift
//  RagnarokReality
//
//  Created by Leon Li on 2025/2/26.
//

import RagnarokFileFormats
import RagnarokRenderers
import RealityKit

extension Entity {
    public static func modelEntity(model: ModelResource, name: String, textures: [String : TextureResource]) async throws -> Entity {
        let instance = Model.createInstance(
            position: .zero,
            rotation: .zero,
            scale: .one,
            width: 0,
            height: 0
        )

        let modelEntity = try await Entity.modelEntity(rsm: model.rsm, instance: instance, textures: textures)
        modelEntity.name = name
        return modelEntity
    }

    public static func modelEntity(rsm: RSM, instance: simd_float4x4, textures: [String : TextureResource]) async throws -> Entity {
        let model = Model(rsm: rsm, instance: instance)

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

        let materials = model.meshes.map { mesh -> any Material in
            if let texture = textures[mesh.textureName] {
                var material = PhysicallyBasedMaterial()
                material.baseColor = PhysicallyBasedMaterial.BaseColor(texture: MaterialParameters.Texture(texture))
                material.roughness = PhysicallyBasedMaterial.Roughness(floatLiteral: 0.8)
                material.opacityThreshold = 0.9999
                material.blending = .transparent(opacity: 1.0)
                return material
            } else {
                let material = SimpleMaterial()
                return material
            }
        }

        let modelEntity = ModelEntity(mesh: mesh, materials: materials)

        let scale = 2 / model.boundingBox.range.max()
        modelEntity.scale = [scale, scale, scale]

        return modelEntity
    }
}
