//
//  CylinderEffectAsset.swift
//  RagnarokRenderAssets
//
//  Created by Leon Li on 2026/7/9.
//

import CoreGraphics
import RagnarokResources

public struct CylinderEffectAsset: Sendable {
    public let textureImage: CGImage

    static func load(textureName: String, using resourceManager: ResourceManager) async throws -> CylinderEffectAsset {
        let texturePath = ResourcePath.effectDirectory.appending(subpath: textureName)
        let image = try await resourceManager.image(at: texturePath)

        return CylinderEffectAsset(textureImage: image.cgImage)
    }
}
