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
        let textures = await withTaskGroup(
            of: (String, TextureResource?).self,
            returning: [String : TextureResource].self
        ) { taskGroup in
            for (textureName, textureImage) in groundAsset.textureImages {
                taskGroup.addTask {
                    let texture = try? await TextureResource(
                        image: textureImage,
                        withName: textureName,
                        options: TextureResource.CreateOptions(semantic: .color)
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

        var descriptors: [MeshDescriptor] = []
        descriptors.reserveCapacity(groundAsset.meshes.count)
        for (index, groundMesh) in groundAsset.meshes.enumerated() {
            var descriptor = MeshDescriptor(name: groundMesh.textureName)
            descriptor.positions = MeshBuffer(groundMesh.vertices.map(\.position))
            descriptor.normals = MeshBuffer(groundMesh.vertices.map(\.normal))
            descriptor.textureCoordinates = MeshBuffer(groundMesh.vertices.map({
                SIMD2(x: $0.textureCoordinate.x, y: 1 - $0.textureCoordinate.y)
            }))

            let indices = (0..<groundMesh.vertices.count).map(UInt32.init)
            descriptor.primitives = .triangles(indices)

            descriptor.materials = .allFaces(UInt32(index))

            descriptors.append(descriptor)
        }

        let mesh = try await MeshResource(from: descriptors)

        let materials = groundAsset.meshes.map { groundMesh -> any Material in
            var material = PhysicallyBasedMaterial()
            if let texture = textures[groundMesh.textureName] {
                material.baseColor = PhysicallyBasedMaterial.BaseColor(texture: MaterialParameters.Texture(texture))
            }
            material.roughness = PhysicallyBasedMaterial.Roughness(floatLiteral: 0.9)
            return material
        }

        components.set(ModelComponent(mesh: mesh, materials: materials))
    }
}
