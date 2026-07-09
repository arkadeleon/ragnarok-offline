//
//  STREffectAsset.swift
//  RagnarokRenderAssets
//
//  Created by Leon Li on 2026/7/9.
//

import CoreGraphics
import RagnarokEffects
import RagnarokFileFormats
import RagnarokResources

public struct STREffectAsset: @unchecked Sendable {
    public let definition: STREffectDefinition
    public let effect: STREffect
    public let textureImages: [String : CGImage]

    static func load(with definition: STREffectDefinition, using resourceManager: ResourceManager) async throws -> STREffectAsset {
        let strPath = ResourcePath.effectDirectory.appending(subpath: definition.fileName)
        let strData = try await resourceManager.contentsOfResource(at: strPath)
        let str = try STR(data: strData)
        let effect = STREffect(str: str)

        var textureImages: [String : CGImage] = [:]
        for frame in effect.frames {
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

        let asset = STREffectAsset(definition: definition, effect: effect, textureImages: textureImages)
        return asset
    }
}
