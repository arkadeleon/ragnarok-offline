//
//  GroundEntity.swift
//  RagnarokReality
//
//  Created by Leon Li on 2025/9/28.
//

import RagnarokRenderAssets
import RealityKit

extension Entity {
    public convenience init(from groundAsset: GroundRenderAsset) async throws {
        self.init()

        let mesh = try await {
            var descriptor = MeshDescriptor(name: "ground-mesh")
            descriptor.positions = MeshBuffer(groundAsset.mesh.vertices.map(\.position))
            descriptor.normals = MeshBuffer(groundAsset.mesh.vertices.map(\.normal))
            descriptor.textureCoordinates = MeshBuffer(groundAsset.mesh.vertices.map({
                SIMD2(x: $0.textureCoordinate.x, y: 1 - $0.textureCoordinate.y)
            }))

            let indices = (0..<groundAsset.mesh.vertices.count).map(UInt32.init)
            descriptor.primitives = .triangles(indices)

            descriptor.materials = .allFaces(0)

            return try await MeshResource(from: [descriptor])
        }()

        var material = PhysicallyBasedMaterial()
        if let textureImage = groundAsset.baseColorTextureImage {
            let texture = try await TextureResource(
                image: textureImage,
                withName: "ground-base-color-texture",
                options: TextureResource.CreateOptions(semantic: .color)
            )
            material.baseColor = PhysicallyBasedMaterial.BaseColor(texture: MaterialParameters.Texture(texture))
            material.roughness = PhysicallyBasedMaterial.Roughness(floatLiteral: 0.9)
        }

        components.set(ModelComponent(mesh: mesh, materials: [material]))
    }
}
