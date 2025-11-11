//
//  ModelEntity.swift
//  RagnarokReality
//
//  Created by Leon Li on 2025/2/26.
//

import RagnarokFileFormats
import RagnarokRenderers
import RealityKit

extension Entity {
    public convenience init(from resource: ModelResource, name: String, textures: [String : TextureResource]) async throws {
        let instance = Model.createInstance(
            position: .zero,
            rotation: .zero,
            scale: .one,
            width: 0,
            height: 0
        )

        let model = Model(rsm: resource.rsm, instance: instance)

        try await self.init(from: model, textures: textures)

        self.name = name
    }

    public convenience init(from model: Model, textures: [String : TextureResource]) async throws {
        self.init()

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

        components.set(ModelComponent(mesh: mesh, materials: materials))

        let scale = 2 / model.boundingBox.range.max()
        self.scale = [scale, scale, scale]
    }
}
