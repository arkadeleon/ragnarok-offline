//
//  Effect2DAsset.swift
//  RagnarokRenderAssets
//
//  Created by Leon Li on 2026/7/9.
//

import CoreGraphics
import RagnarokEffects
import RagnarokResources

public struct Effect2DAsset: Sendable {
    public let definition: Effect2DDefinition
    public let textureImage: CGImage

    static func load(with definition: Effect2DDefinition, using resourceManager: ResourceManager) async throws -> Effect2DAsset {
        let texturePath = ResourcePath.textureDirectory.appending(subpath: definition.fileName)
        let removesMagentaPixels = definition.fileName.lowercased().hasSuffix(".bmp")
        let image = try await resourceManager.image(at: texturePath, removesMagentaPixels: removesMagentaPixels)

        let asset = Effect2DAsset(definition: definition, textureImage: image.cgImage)
        return asset
    }
}
