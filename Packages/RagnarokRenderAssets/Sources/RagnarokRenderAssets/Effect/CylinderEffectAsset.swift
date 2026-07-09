//
//  CylinderEffectAsset.swift
//  RagnarokRenderAssets
//
//  Created by Leon Li on 2026/7/9.
//

import CoreGraphics
import RagnarokEffects
import RagnarokResources

public struct CylinderEffectAsset: Sendable {
    public let definition: CylinderEffectDefinition
    public let textureImage: CGImage

    static func load(with definition: CylinderEffectDefinition, using resourceManager: ResourceManager) async throws -> CylinderEffectAsset {
        let texturePath = ResourcePath.effectDirectory
            .appending(definition.textureName)
            .appendingPathExtension("tga")
        let image = try await resourceManager.image(at: texturePath)

        let asset = CylinderEffectAsset(definition: definition, textureImage: image.cgImage)
        return asset
    }
}
