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

    public func load(gat: GAT, gnd: GND, rsw: RSW, resourceManager: ResourceManager, progress: Progress? = nil) async throws -> WorldAsset {
        let uniqueModelNames = Set(rsw.models.map(\.modelName))
        let modelResources = await resourceManager.models(forNames: uniqueModelNames)

        let lighting = WorldLighting(light: rsw.light)

        var modelTextureNames: Set<String> = []
        for (_, modelResource) in modelResources {
            modelTextureNames.formUnion(modelResource.textureNames)
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

        let waterParameters = WaterParameters(gnd: gnd, rsw: rsw)
        async let waterTextureImages = resourceManager.waterTextureImages(type: waterParameters.type)

        let groundAsset = GroundRenderAsset(
            gat: gat,
            gnd: gnd,
            lighting: lighting,
            textureImages: await groundTextureImages
        )

        let waterAsset = WaterRenderAsset(
            gnd: gnd,
            parameters: waterParameters,
            lighting: lighting,
            textureImages: await waterTextureImages
        )

        let sharedModelTextureImages = await modelTextureImages

        var prototypeModelAssetsByName: [String : RSMModelRenderAsset] = [:]
        for (modelName, modelResource) in modelResources {
            let textureImages = modelResource.textureNames.reduce(into: [String : CGImage]()) { textureImages, textureName in
                if let textureImage = sharedModelTextureImages[textureName] {
                    textureImages[textureName] = textureImage
                }
            }

            prototypeModelAssetsByName[modelName] = RSMModelRenderAsset(
                name: modelName,
                rsm: modelResource.rsm,
                instance: .identity,
                lighting: lighting,
                textureImages: textureImages,
            )
        }

        var modelNamesInWorldOrder: [String] = []
        var seenModelNames: Set<String> = []
        var modelInstancesByName: [String : [RSMModelInstance]] = [:]
        for model in rsw.models {
            if seenModelNames.insert(model.modelName).inserted {
                modelNamesInWorldOrder.append(model.modelName)
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
            modelInstancesByName[model.modelName, default: []].append(instance)
        }

        let modelGroups: [RSMModelAssetGroup] = modelNamesInWorldOrder.compactMap { modelName in
            guard let prototype = prototypeModelAssetsByName[modelName],
                  let instances = modelInstancesByName[modelName] else {
                return nil
            }
            return RSMModelAssetGroup(prototype: prototype, instances: instances)
        }

        let worldAsset = WorldAsset(
            ground: groundAsset,
            water: waterAsset,
            modelGroups: modelGroups,
            lighting: lighting
        )
        return worldAsset
    }
}
