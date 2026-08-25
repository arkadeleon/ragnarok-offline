//
//  TwoDEffectAsset.swift
//  RagnarokRenderAssets
//
//  Created by Leon Li on 2026/7/9.
//

import CoreGraphics
import RagnarokResources

public struct TwoDEffectAsset: Sendable {
    public let textureImage: CGImage

    static func load(fileName: String, using resourceManager: ResourceManager) async throws -> TwoDEffectAsset {
        let texturePath = ResourcePath.textureDirectory.appending(subpath: fileName)
        let removesMagentaPixels = fileName.lowercased().hasSuffix(".bmp")
        let image = try await resourceManager.image(at: texturePath, removesMagentaPixels: removesMagentaPixels)

        return TwoDEffectAsset(textureImage: image.cgImage)
    }
}
