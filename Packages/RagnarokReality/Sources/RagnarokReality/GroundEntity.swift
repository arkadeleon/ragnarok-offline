//
//  GroundEntity.swift
//  RagnarokReality
//
//  Created by Leon Li on 2025/9/28.
//

import CoreGraphics
import RagnarokRenderers
import RealityKit

extension Entity {
    public convenience init(from ground: Ground, textureImages: [String : CGImage]) async throws {
        self.init()

        let mesh = try await {
            var descriptor = MeshDescriptor(name: "ground-mesh")
            descriptor.positions = MeshBuffer(ground.mesh.vertices.map({ $0.position }))
            descriptor.normals = MeshBuffer(ground.mesh.vertices.map({ $0.normal }))
            descriptor.textureCoordinates = MeshBuffer(ground.mesh.vertices.map({ $0.textureCoordinate }))

            let indices = (0..<descriptor.positions.count).map(UInt32.init)
            descriptor.primitives = .triangles(indices)

            descriptor.materials = .allFaces(0)

            let mesh = try await MeshResource(from: [descriptor])
            return mesh
        }()

        var material = PhysicallyBasedMaterial()
        if let textureImage = ground.textureAtlas.makeCGImage(textureImages: textureImages) {
            let texture = try await TextureResource(
                image: textureImage,
                withName: "ground-texture",
                options: TextureResource.CreateOptions(semantic: .color)
            )
            material.baseColor = PhysicallyBasedMaterial.BaseColor(texture: MaterialParameters.Texture(texture))
            material.roughness = PhysicallyBasedMaterial.Roughness(floatLiteral: 0.9)
        }

        components.set(ModelComponent(mesh: mesh, materials: [material]))
    }
}
