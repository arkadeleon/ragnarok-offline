//
//  STREffectAsset.swift
//  RagnarokRenderAssets
//
//  Created by Leon Li on 2026/7/9.
//

import CoreGraphics
import RagnarokFileFormats
import RagnarokResources

public struct STREffectAsset: @unchecked Sendable {
    public let animation: STRAnimation
    public let textureImages: [String : CGImage]

    static func load(fileName: String, using resourceManager: ResourceManager, cache: EffectAssetCache) async throws -> STREffectAsset {
        try await cache.resource(forIdentifier: "STREffect/\(fileName)") {
            let strPath = ResourcePath.effectDirectory.appending(subpath: fileName)
            let strData = try await resourceManager.contentsOfResource(at: strPath)
            let str = try STR(data: strData)
            let animation = STRAnimation(str: str)

            var textureImages: [String : CGImage] = [:]
            for frame in animation.frames {
                for sprite in frame.sprites {
                    let textureName = sprite.textureName
                    guard textureImages[textureName] == nil else {
                        continue
                    }

                    let texturePath = ResourcePath.effectDirectory.appending(subpath: textureName)
                    let image = try await resourceManager.image(at: texturePath, removesMagentaPixels: true)

                    textureImages[textureName] = image.cgImage
                }
            }

            return STREffectAsset(animation: animation, textureImages: textureImages)
        }
    }
}
