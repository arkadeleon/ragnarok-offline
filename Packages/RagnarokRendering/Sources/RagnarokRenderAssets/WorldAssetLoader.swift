//
//  WorldAssetLoader.swift
//  RagnarokRenderAssets
//
//  Created by Leon Li on 2026/3/21.
//

import CoreGraphics
import Foundation
import RagnarokFileFormats
import RagnarokResources

public struct WorldAssetLoader: Sendable {
    public init() {}

    public func load(
        gat: GAT,
        gnd: GND,
        rsw: RSW,
        resourceManager: ResourceManager,
        progress: Progress? = nil
    ) async throws -> WorldAsset {
        let uniqueModelNames = Set(rsw.models.map(\.modelName))
        let modelResources = await resourceManager.models(forNames: uniqueModelNames)

        let lighting = WorldLighting(light: rsw.light)

        var modelTextureNames: Set<String> = []
        for (_, modelResource) in modelResources {
            modelTextureNames.formUnion(modelResource.model.textureNames)
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
            gat: gat,
            gnd: gnd,
            lighting: lighting,
            textureImages: await groundTextureImages
        )

        let waterAsset = WaterRenderAsset(
            gnd: gnd,
            rsw: rsw,
            lighting: lighting,
            textureImage: try? await waterTextureImage
        )

        let sharedModelTextureImages = await modelTextureImages
        let modelAssets: [RSMModelRenderAsset] = rsw.models.compactMap { model in
            let modelName = model.modelName

            guard let modelResource = modelResources[modelName] else {
                return nil
            }

            let textureImages = modelResource.model.textureNames.reduce(into: [String : CGImage]()) { textureImages, textureName in
                if let textureImage = sharedModelTextureImages[textureName] {
                    textureImages[textureName] = textureImage
                }
            }

            let instance = RSMModelInstance(
                position: [
                    model.position.x + Float(gnd.width),
                    model.position.y,
                    model.position.z + Float(gnd.height),
                ],
                rotation: model.rotation,
                scale: model.scale
            )

            let modelAsset = RSMModelRenderAsset(
                name: modelName,
                model: modelResource.model,
                instance: instance,
                lighting: lighting,
                textureImages: textureImages,
            )
            return modelAsset
        }

        let worldAsset = WorldAsset(
            ground: groundAsset,
            water: waterAsset,
            models: modelAssets,
            lighting: lighting
        )
        return worldAsset
    }
}
