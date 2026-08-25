//
//  TwoDEffectAsset.swift
//  RagnarokRenderAssets
//
//  Created by Leon Li on 2026/7/9.
//

import CoreGraphics
import RagnarokEffects
import RagnarokResources

public struct TwoDEffectAsset: Sendable {
    public let effect: TwoDEffect
    public let textureImage: CGImage

    static func load(with definition: TwoDEffectDefinition, using resourceManager: ResourceManager) async throws -> TwoDEffectAsset {
        let fileName = definition.fileName
        let texturePath = ResourcePath.textureDirectory.appending(subpath: fileName)
        let removesMagentaPixels = fileName.lowercased().hasSuffix(".bmp")
        let image = try await resourceManager.image(at: texturePath, removesMagentaPixels: removesMagentaPixels)

        let asset = TwoDEffectAsset(
            effect: TwoDEffect(definition: definition),
            textureImage: image.cgImage
        )
        return asset
    }
}
