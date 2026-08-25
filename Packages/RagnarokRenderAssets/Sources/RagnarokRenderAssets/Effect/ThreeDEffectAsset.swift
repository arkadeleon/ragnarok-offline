//
//  ThreeDEffectAsset.swift
//  RagnarokRenderAssets
//
//  Created by Leon Li on 2026/7/9.
//

import CoreGraphics
import Foundation
import RagnarokCore
import RagnarokEffects
import RagnarokFileFormats
import RagnarokResources

public struct ThreeDEffectAsset: Sendable {
    public let effect: ThreeDEffect
    public let images: [CGImage]

    static func load(with definition: ThreeDEffectDefinition, using resourceManager: ResourceManager) async throws -> ThreeDEffectAsset {
        var frameDelay = definition.frameDelay

        var images: [CGImage] = []
        var frames: [ThreeDEffect.Frame] = []

        if let spriteName = definition.spriteName {
            let spritePath = ResourcePath.spriteDirectory.appending(subpath: spriteName)

            async let actData = resourceManager.contentsOfResource(at: spritePath.appendingPathExtension("act"))
            async let sprData = resourceManager.contentsOfResource(at: spritePath.appendingPathExtension("spr"))

            let act = try await ACT(data: actData)
            let spr = try await SPR(data: sprData)
            let spriteImages = spr.imagesBySpriteType()
            let action = act.action(at: 0)
            let actionFrames = action?.frames ?? []
            let usedFrames = definition.playSprite ? actionFrames : Array(actionFrames.prefix(1))

            if definition.spriteFrameDelay > 0 {
                frameDelay = definition.spriteFrameDelay
            } else if let action {
                frameDelay = TimeInterval(action.frameInterval)
            }

            var imageIndicesBySprite: [SIMD2<Int> : Int] = [:]
            for frame in usedFrames {
                var layers: [ThreeDEffect.Layer] = []
                for layer in frame.layers where layer.spriteIndex >= 0 {
                    guard let spriteType = SPR.SpriteType(rawValue: Int(layer.spriteType)),
                          let typedImages = spriteImages[spriteType] else {
                        continue
                    }

                    let spriteIndex = Int(layer.spriteIndex)
                    guard typedImages.indices.contains(spriteIndex),
                          let image = typedImages[spriteIndex] else {
                        continue
                    }

                    let spriteKey = SIMD2<Int>(spriteType.rawValue, spriteIndex)
                    let imageIndex: Int
                    if let index = imageIndicesBySprite[spriteKey] {
                        imageIndex = index
                    } else {
                        imageIndex = images.count
                        images.append(image)
                        imageIndicesBySprite[spriteKey] = imageIndex
                    }

                    layers.append(ThreeDEffect.Layer(
                        imageIndex: imageIndex,
                        sizeFactor: [
                            Float(image.width) * layer.scale.x / 100,
                            Float(image.height) * layer.scale.y / 100,
                        ],
                        offset: [
                            Float(layer.offset.x),
                            Float(layer.offset.y),
                        ],
                        angle: Float(layer.rotationAngle),
                        color: [
                            Float(layer.color.red) / 255,
                            Float(layer.color.green) / 255,
                            Float(layer.color.blue) / 255,
                            Float(layer.color.alpha) / 255,
                        ],
                        isMirrored: layer.isMirrored != 0
                    ))
                }
                frames.append(ThreeDEffect.Frame(layers: layers))
            }
        } else {
            let textureNames: [String]
            if definition.fileNames.isEmpty {
                textureNames = definition.fileName.map { [$0] } ?? []
            } else {
                textureNames = definition.fileNames
            }

            for textureName in textureNames {
                let texturePath = ResourcePath.textureDirectory.appending(subpath: textureName)
                let removesMagentaPixels = textureName.lowercased().hasSuffix(".bmp")
                let image = try await resourceManager.image(at: texturePath, removesMagentaPixels: removesMagentaPixels)
                let layer = ThreeDEffect.Layer(imageIndex: images.count, sizeFactor: [1, 1])
                let frame = ThreeDEffect.Frame(layers: [layer])
                frames.append(frame)
                images.append(image.cgImage)
            }
        }

        let effect = ThreeDEffect(
            definition: definition,
            frameDelay: frameDelay,
            frames: frames
        )

        let asset = ThreeDEffectAsset(
            effect: effect,
            images: images
        )
        return asset
    }
}
