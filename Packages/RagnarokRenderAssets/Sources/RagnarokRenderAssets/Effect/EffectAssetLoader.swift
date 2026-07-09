//
//  EffectAssetLoader.swift
//  RagnarokRenderAssets
//
//  Created by Leon Li on 2026/6/30.
//

import CoreGraphics
import Foundation
import RagnarokCore
import RagnarokEffects
import RagnarokFileFormats
import RagnarokResources

public struct EffectAssetLoader: Sendable {
    public let resourceManager: ResourceManager

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
            let asset = try await Effect2DAsset.load(with: definition, using: resourceManager)
            return .`2D`(asset)
        case .`3D`(let definition):
            let asset = try await Effect3DAsset.load(with: definition, using: resourceManager)
            return .`3D`(asset)
        case .cylinder(let definition):
            let asset = try await CylinderEffectAsset.load(with: definition, using: resourceManager)
            return .cylinder(asset)
        case .spr(let definition):
            let asset = try await SPREffectAsset.load(with: definition, using: resourceManager)
            return .spr(asset)
        case .str(let definition):
            let asset = try await STREffectAsset.load(with: definition, using: resourceManager)
            return .str(asset)
        }
    }
}
