//
//  RSMModelRenderResource.swift
//  RagnarokMetalRendering
//
//  Created by Leon Li on 2026/3/23.
//

import Metal
import RagnarokRenderAssets
import RagnarokShaders
import simd

public class RSMModelRenderResource {
    struct MeshResource {
        let vertexCount: Int
        let vertexBuffer: (any MTLBuffer)?
        let texture: (any MTLTexture)?
    }

    let meshes: [RSMModelRenderResource.MeshResource]

    var light = Light(
        opacity: 1,
        ambient: [1, 1, 1],
        diffuse: [0, 0, 0],
        direction: [0, 1, 0]
    )

    public init(device: any MTLDevice, asset: RSMModelRenderAsset) {
        let textures = Self.makeTextures(from: asset, device: device)
        let model = Self.instantiatedModel(
            from: asset.model,
            instance: asset.instance,
            textureNamespace: Self.textureNamespace(for: asset)
        )

        self.meshes = model.meshes.map { mesh in
            MeshResource(
                vertexCount: mesh.vertices.count,
                vertexBuffer: device.makeBuffer(
                    bytes: mesh.vertices,
                    length: mesh.vertices.count * MemoryLayout<ModelVertex>.stride,
                    options: []
                ),
                texture: textures[mesh.textureName]
            )
        }

        light.ambient = asset.lighting.ambient
        light.diffuse = asset.lighting.diffuse
        light.direction = asset.lighting.direction
        light.opacity = asset.lighting.opacity
    }
}

extension RSMModelRenderResource {
    private static func makeTextures(
        from asset: RSMModelRenderAsset,
        device: any MTLDevice
    ) -> [String : any MTLTexture] {
        var textures: [String : any MTLTexture] = [:]

        let namespace = textureNamespace(for: asset)
        for (textureName, textureImage) in asset.textureImages {
            let namespacedTextureName = namespace + textureName
            if textures[namespacedTextureName] != nil {
                continue
            }

            let texture = MetalTextureFactory.makeTexture(
                from: textureImage,
                device: device,
                label: namespacedTextureName
            )
            if let texture {
                textures[namespacedTextureName] = texture
            }
        }

        return textures
    }

    private static func instantiatedModel(
        from prototype: RSMModel,
        instance: RSMModelInstance,
        textureNamespace: String
    ) -> RSMModel {
        let instanceMatrix = instance.matrix
        let normalMatrix = simd_float3x3(instanceMatrix).inverse.transpose

        var model = prototype
        model.meshes = prototype.meshes.map { prototypeMesh in
            var mesh = prototypeMesh
            mesh.textureName = textureNamespace + prototypeMesh.textureName
            mesh.vertices = prototypeMesh.vertices.map { prototypeVertex in
                var vertex = prototypeVertex

                let transformedPosition = instanceMatrix * SIMD4<Float>(prototypeVertex.position, 1)
                vertex.position = SIMD3(
                    transformedPosition.x,
                    transformedPosition.y,
                    transformedPosition.z
                )

                let transformedNormal = normalMatrix * prototypeVertex.normal
                let normalLength = simd_length_squared(transformedNormal)
                if normalLength > .leastNonzeroMagnitude {
                    vertex.normal = simd_normalize(transformedNormal)
                }

                return vertex
            }
            return mesh
        }

        return model
    }

    private static func textureNamespace(for asset: RSMModelRenderAsset) -> String {
        "\(asset.name)::"
    }
}
