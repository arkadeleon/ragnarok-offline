//
//  MapWorldAssetLoader.swift
//  RagnarokRenderAssets
//
//  Created by Leon Li on 2026/3/21.
//

import CoreGraphics
import Foundation
import RagnarokFileFormats
import RagnarokResources

public struct MapWorldAssetLoader: Sendable {
    public init() {}

    public func load(
        gat: GAT,
        gnd: GND,
        rsw: RSW,
        resourceManager: ResourceManager,
        progress: Progress? = nil
    ) async throws -> MapWorldAsset {
        let uniqueModelNames = Set(rsw.models.map({ $0.modelName }))
        let models = await resourceManager.models(forNames: uniqueModelNames)

        let ground = Ground(gat: gat, gnd: gnd)
        let water = Water(gnd: gnd, rsw: rsw)
        let lighting = WorldLighting(light: rsw.light)

        var modelTextureNames: Set<String> = []
        for (_, model) in models {
            for node in model.rsm.nodes {
                modelTextureNames.formUnion(node.textures)
            }
        }

        if let progress {
            Task { @MainActor in
                progress.totalUnitCount = Int64(gnd.textures.count + modelTextureNames.count)
                progress.completedUnitCount = 0
            }
        }

        async let groundTextureImages = resourceManager.textureImages(forNames: gnd.textures, removesMagentaPixels: false) { _, _ in
            if let progress {
                Task { @MainActor in
                    progress.completedUnitCount += 1
                }
            }
        }

        async let modelTextureImages = resourceManager.textureImages(forNames: modelTextureNames, removesMagentaPixels: true) { _, _ in
            if let progress {
                Task { @MainActor in
                    progress.completedUnitCount += 1
                }
            }
        }

        async let waterTextureImage = resourceManager.waterTextureImage()

        let groundAsset = GroundRenderAsset(
            ground: ground,
            textureImages: await groundTextureImages
        )

        let waterAsset = WaterRenderAsset(
            water: water,
            textureImage: try? await waterTextureImage
        )

        let sharedModelTextureImages = await modelTextureImages
        let modelAssets: [ModelRenderAsset] = uniqueModelNames.compactMap { modelName in
            guard let model = models[modelName] else {
                return nil
            }

            let prototype = Model(
                rsm: model.rsm,
                instance: Model.createInstance(
                    position: .zero,
                    rotation: .zero,
                    scale: .one,
                    width: 0,
                    height: 0
                )
            )

            let textureImages = model.rsm.nodes.reduce(into: [String : CGImage]()) { textureImages, node in
                for textureName in node.textures {
                    if let textureImage = sharedModelTextureImages[textureName] {
                        textureImages[textureName] = textureImage
                    }
                }
            }

            let instances = rsw.models
                .filter {
                    $0.modelName == modelName
                }
                .map { model in
                    ModelRenderAsset.Instance(
                        position: [
                            model.position.x + Float(gnd.width),
                            model.position.y,
                            model.position.z + Float(gnd.height),
                        ],
                        rotation: model.rotation,
                        scale: model.scale
                    )
                }

            let modelAsset = ModelRenderAsset(
                name: modelName,
                model: prototype,
                textureImages: textureImages,
                instances: instances
            )
            return modelAsset
        }

        let worldAsset = MapWorldAsset(
            ground: groundAsset,
            water: waterAsset,
            models: modelAssets,
            lighting: lighting
        )
        return worldAsset
    }
}
