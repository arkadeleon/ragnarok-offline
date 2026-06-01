//
//  RSMModelEntity.swift
//  RagnarokRealityRendering
//
//  Created by Leon Li on 2025/2/26.
//

import RagnarokRenderAssets
import RealityKit

extension Entity {
    public convenience init(from modelAsset: RSMModelRenderAsset) async throws {
        let textures = await withTaskGroup(
            of: (String, TextureResource?).self,
            returning: [String : TextureResource].self
        ) { taskGroup in
            for (textureName, textureImage) in modelAsset.textureImages {
                taskGroup.addTask {
                    let texture = try? await TextureResource(
                        image: textureImage,
                        withName: textureName,
                        options: TextureResource.CreateOptions(semantic: .raw)
                    )
                    return (textureName, texture)
                }
            }

            var textures: [String : TextureResource] = [:]
            for await (textureName, texture) in taskGroup {
                textures[textureName] = texture
            }
            return textures
        }

        self.init()

        let mesh = try await {
            var descriptors: [MeshDescriptor] = []
            for (index, mesh) in modelAsset.meshes.enumerated() {
                var descriptor = MeshDescriptor(name: mesh.textureName)
                descriptor.positions = MeshBuffer(mesh.vertices.map(\.position))
                descriptor.normals = MeshBuffer(mesh.vertices.map(\.normal))
                descriptor.textureCoordinates = MeshBuffer(mesh.vertices.map({
                    SIMD2(x: $0.textureCoordinate.x, y: 1 - $0.textureCoordinate.y)
                }))

                let indices = (0..<descriptor.positions.count).map(UInt32.init)
                descriptor.primitives = .triangles(indices + indices.reversed())

                descriptor.materials = .allFaces(UInt32(index))

                descriptors.append(descriptor)
            }

            return try await MeshResource(from: descriptors)
        }()

        let materials = modelAsset.meshes.map { mesh -> any Material in
            if let texture = textures[mesh.textureName] {
                var material = PhysicallyBasedMaterial()
                material.baseColor = PhysicallyBasedMaterial.BaseColor(texture: MaterialParameters.Texture(texture))
                material.roughness = PhysicallyBasedMaterial.Roughness(floatLiteral: 0.8)
                material.opacityThreshold = 0.9999
                material.blending = .transparent(opacity: 1.0)
                return material
            } else {
                return SimpleMaterial()
            }
        }

        components.set(ModelComponent(mesh: mesh, materials: materials))

        let scale = 2 / modelAsset.boundingBox.range.max()
        self.scale = [scale, scale, scale]

        self.name = modelAsset.name
    }
}
