//
//  EffectAssetLoader.swift
//  RagnarokRenderAssets
//
//  Created by Leon Li on 2026/6/30.
//

import RagnarokEffects
import RagnarokResources

public struct EffectAssetLoader: Sendable {
    public let resourceManager: ResourceManager

    private let cache = EffectAssetCache()

    public init(resourceManager: ResourceManager) {
        self.resourceManager = resourceManager
    }

    public func loadAssetGroup(with definitions: [EffectDefinition]) async throws -> EffectAssetGroup {
        var assets: [EffectAsset] = []
        assets.reserveCapacity(definitions.count)
        for definition in definitions {
            let asset = try await loadAsset(with: definition)
            assets.append(asset)
        }
        return EffectAssetGroup(assets: assets)
    }

    private func loadAsset(with definition: EffectDefinition) async throws -> EffectAsset {
        switch definition {
        case .`2D`(let definition):
            let effect = TwoDEffect(definition: definition)
            let texturePath = ResourcePath.textureDirectory.appending(subpath: definition.fileName)
            let removesMagentaPixels = definition.fileName.lowercased().hasSuffix(".bmp")
            let image = try await resourceManager.image(at: texturePath, removesMagentaPixels: removesMagentaPixels)
            return .`2D`(effect, textureImage: image.cgImage)
        case .`3D`(let definition):
            let effect = ThreeDEffect(definition: definition)
            let asset: ThreeDEffectAsset
            if let spriteName = definition.spriteName {
                asset = try await ThreeDEffectAsset.load(
                    spriteName: spriteName,
                    playSprite: definition.playSprite,
                    using: resourceManager,
                    cache: cache
                )
            } else {
                let textureNames = definition.fileNames.isEmpty
                    ? definition.fileName.map { [$0] } ?? []
                    : definition.fileNames
                asset = try await ThreeDEffectAsset.load(
                    textureNames: textureNames,
                    using: resourceManager,
                    cache: cache
                )
            }
            return .`3D`(effect, asset)
        case .cylinder(let definition):
            let effect = CylinderEffect(definition: definition)
            let texturePath = ResourcePath.effectDirectory.appending(subpath: definition.textureName)
            let image = try await resourceManager.image(at: texturePath)
            return .cylinder(effect, textureImage: image.cgImage)
        case .spr(let definition):
            let effect = SPREffect(definition: definition)
            let asset = try await SPREffectAsset.load(
                fileName: definition.fileName,
                actionIndex: definition.actionIndex,
                using: resourceManager,
                cache: cache
            )
            return .spr(effect, asset)
        case .str(let definition):
            let effect = STREffect(definition: definition)
            let asset = try await STREffectAsset.load(
                fileName: effect.fileName,
                using: resourceManager,
                cache: cache
            )
            return .str(effect, asset)
        case .wav(let definition):
            let effect = WAVEffect(definition: definition)
            return .wav(effect)
        }
    }
}
