//
//  WorldAssetLoader.swift
//  RagnarokRenderAssets
//
//  Created by Leon Li on 2026/3/21.
//

import CoreGraphics
import Foundation
import RagnarokConstants
import RagnarokEffects
import RagnarokFileFormats
import RagnarokResources

public struct WorldAssetLoader: Sendable {
    public init() {}

    public func load(world: WorldResource, resourceManager: ResourceManager, progress: Progress? = nil) async throws -> WorldAsset {
        let gat = world.gat
        let gnd = world.gnd
        let rsw = world.rsw

        let light = WorldLight(light: rsw.light)

        let uniqueModelNames = Set(rsw.models.map(\.modelName))
        let modelResources = await resourceManager.models(forNames: uniqueModelNames)

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
            textureImages: await groundTextureImages
        )

        let waterAsset = WaterRenderAsset(
            gnd: gnd,
            parameters: waterParameters,
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

        let effects = await loadEffects(rsw: rsw, gnd: gnd, resourceManager: resourceManager)

        let worldAsset = WorldAsset(
            ground: groundAsset,
            water: waterAsset,
            modelGroups: modelGroups,
            effects: effects,
            light: light
        )
        return worldAsset
    }

    private func loadEffects(rsw: RSW, gnd: GND, resourceManager: ResourceManager) async -> [WorldEffectAsset] {
        let effectAssetLoader = EffectAssetLoader(resourceManager: resourceManager)

        var assetGroupsByEffectID: [EffectID : EffectAssetGroup] = [:]
        var effects: [WorldEffectAsset] = []

        for effect in rsw.effects {
            guard let effectID = EffectID(rawValue: Int(effect.id)) else {
                continue
            }

            let assetGroup: EffectAssetGroup
            if let loadedAssetGroup = assetGroupsByEffectID[effectID] {
                assetGroup = loadedAssetGroup
            } else {
                let definitions = EffectTable.definitions(for: effectID)
                guard let loadedAssetGroup = try? await effectAssetLoader.loadAssetGroup(with: definitions) else {
                    continue
                }
                assetGroupsByEffectID[effectID] = loadedAssetGroup
                assetGroup = loadedAssetGroup
            }

            let position: SIMD3<Float> = [
                effect.position.x + Float(gnd.width),
                effect.position.z + Float(gnd.height),
                -effect.position.y + 1,
            ]

            effects.append(
                WorldEffectAsset(
                    effectID: effectID,
                    position: position,
                    assetGroup: assetGroup
                )
            )
        }

        return effects
    }
}
