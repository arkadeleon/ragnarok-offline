//
//  STREffectAsset.swift
//  RagnarokRenderAssets
//
//  Created by Leon Li on 2026/7/9.
//

import CoreGraphics
import Foundation
import RagnarokEffects
import RagnarokFileFormats
import RagnarokResources

public struct STREffectAsset: @unchecked Sendable {
    public let definition: STREffectDefinition
    public let sound: EffectSound?
    public let effect: STREffect
    public let textureImages: [String : CGImage]

    static func load(with definition: STREffectDefinition, using resourceManager: ResourceManager) async throws -> STREffectAsset {
        let sound = definition.soundName.map { soundName in
            EffectSound(
                name: soundName.replacingRandomNumber(in: definition.randomNumberRange),
                delay: 0
            )
        }

        let fileName = definition.fileName.replacingRandomNumber(in: definition.randomNumberRange)
        let strPath = ResourcePath.effectDirectory.appending(subpath: fileName)
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

        let asset = STREffectAsset(
            definition: definition,
            sound: sound,
            effect: effect,
            textureImages: textureImages
        )
        return asset
    }
}
