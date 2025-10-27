//
//  Entity+Ground.swift
//  WorldRendering
//
//  Created by Leon Li on 2025/9/28.
//

import RagnarokFileFormats
import MetalRenderers
import RealityKit

extension Entity {
    public static func groundEntity(gat: GAT, gnd: GND, textures: [String : TextureResource]) async throws -> Entity {
        let ground = Ground(gat: gat, gnd: gnd)

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

        let materials = ground.meshes.map { mesh -> any Material in
            if let texture = textures[mesh.textureName] {
                var material = PhysicallyBasedMaterial()
                material.baseColor = PhysicallyBasedMaterial.BaseColor(texture: MaterialParameters.Texture(texture))
                return material
            } else {
                let material = SimpleMaterial()
                return material
            }
        }

        let groundEntity = ModelEntity(mesh: mesh, materials: materials)
        return groundEntity
    }
}
