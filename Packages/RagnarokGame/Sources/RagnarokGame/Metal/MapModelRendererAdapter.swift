//
//  MapModelRendererAdapter.swift
//  RagnarokGame
//
//  Created by Leon Li on 2026/3/23.
//

import Metal
import RagnarokMetalRendering
import RagnarokSceneAssets
import simd

final class MapModelRendererAdapter {
    private let renderer: ModelRenderer

    init(
        device: any MTLDevice,
        assets: [ModelRenderAsset],
        lighting: WorldLighting
    ) throws {
        let textures = ModelRenderAsset.makeTextures(from: assets, device: device)
        let models = ModelRenderAsset.makeModels(from: assets)

        self.renderer = try ModelRenderer(
            device: device,
            models: models,
            textures: textures,
            lighting: lighting
        )
    }

    func render(
        atTime time: CFTimeInterval,
        renderCommandEncoder: any MTLRenderCommandEncoder,
        matrices: MapRuntimeRenderer.RenderMatrices
    ) {
        renderer.render(
            atTime: time,
            renderCommandEncoder: renderCommandEncoder,
            modelMatrix: matrices.modelMatrix,
            viewMatrix: matrices.viewMatrix,
            projectionMatrix: matrices.projectionMatrix,
            normalMatrix: matrices.normalMatrix
        )
    }
}

extension ModelRenderAsset {
    static func makeTextures(
        from assets: [ModelRenderAsset],
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

                let texture = MapMetalTextureFactory.makeTexture(
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

    static func makeModels(from assets: [ModelRenderAsset]) -> [Model] {
        var models: [Model] = []

        for (assetIndex, asset) in assets.enumerated() {
            let namespace = textureNamespace(for: asset, assetIndex: assetIndex)
            for instance in asset.instances {
                models.append(
                    instantiatedModel(
                        from: asset.model,
                        instance: instance,
                        textureNamespace: namespace
                    )
                )
            }
        }

        return models
    }

    private static func instantiatedModel(
        from prototype: Model,
        instance: ModelRenderAsset.Instance,
        textureNamespace: String
    ) -> Model {
        let instanceMatrix = Model.createInstance(
            position: instance.position,
            rotation: instance.rotation,
            scale: instance.scale,
            width: 0,
            height: 0
        )
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
        for asset: ModelRenderAsset,
        assetIndex: Int
    ) -> String {
        "\(assetIndex)::\(asset.name)::"
    }
}
