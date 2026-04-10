//
//  RSMModelRenderAssetAdapter.swift
//  RagnarokGame
//
//  Created by Leon Li on 2026/3/23.
//

import Metal
import RagnarokMetalRendering
import RagnarokRenderAssets
import simd

final class RSMModelRenderAssetAdapter {
    let assets: [RSMModelRenderAsset]
    let textures: [String : any MTLTexture]
    let models: [RSMModel]

    init(device: any MTLDevice, assets: [RSMModelRenderAsset]) {
        self.assets = assets
        self.textures = RSMModelRenderAsset.makeTextures(from: assets, device: device)
        self.models = RSMModelRenderAsset.makeModels(from: assets)
    }
}

extension RSMModelRenderAsset {
    static func makeTextures(
        from assets: [RSMModelRenderAsset],
        device: any MTLDevice
    ) -> [String : any MTLTexture] {
        var textures: [String : any MTLTexture] = [:]

        for (assetIndex, asset) in assets.enumerated() {
            let namespace = textureNamespace(for: asset, assetIndex: assetIndex)
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
        }

        return textures
    }

    static func makeModels(from modelAssets: [RSMModelRenderAsset]) -> [RSMModel] {
        var models: [RSMModel] = []

        for (assetIndex, modelAsset) in modelAssets.enumerated() {
            let namespace = textureNamespace(for: modelAsset, assetIndex: assetIndex)
            for instance in modelAsset.instances {
                models.append(
                    instantiatedModel(
                        from: modelAsset.model,
                        instance: instance,
                        textureNamespace: namespace
                    )
                )
            }
        }

        return models
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

    private static func textureNamespace(
        for modelAsset: RSMModelRenderAsset,
        assetIndex: Int
    ) -> String {
        "\(assetIndex)::\(modelAsset.name)::"
    }
}
