//
//  ThreeDEffectAsset.swift
//  RagnarokRenderAssets
//
//  Created by Leon Li on 2026/7/9.
//

import CoreGraphics
import Foundation
import RagnarokFileFormats
import RagnarokResources

public struct ThreeDEffectAsset: @unchecked Sendable {
    public struct Layer: Sendable {
        public let imageIndex: Int
        public let sizeFactor: SIMD2<Float>
        public let offset: SIMD2<Float>
        public let angle: Float
        public let color: SIMD4<Float>
        public let isMirrored: Bool

        init(
            imageIndex: Int,
            sizeFactor: SIMD2<Float>,
            offset: SIMD2<Float> = .zero,
            angle: Float = 0,
            color: SIMD4<Float> = [1, 1, 1, 1],
            isMirrored: Bool = false
        ) {
            self.imageIndex = imageIndex
            self.sizeFactor = sizeFactor
            self.offset = offset
            self.angle = angle
            self.color = color
            self.isMirrored = isMirrored
        }
    }

    public struct Frame: Sendable {
        public let layers: [ThreeDEffectAsset.Layer]
    }

    public let images: [CGImage]
    public let frames: [ThreeDEffectAsset.Frame]
    public let frameInterval: TimeInterval?

    static func load(spriteName: String, playSprite: Bool, using resourceManager: ResourceManager, cache: EffectAssetCache) async throws -> ThreeDEffectAsset {
        try await cache.resource(forIdentifier: "3DEffect/sprite/\(spriteName)#\(playSprite)") {
            let spritePath = ResourcePath.spriteDirectory.appending(subpath: spriteName)

            async let actData = resourceManager.contentsOfResource(at: spritePath.appendingPathExtension("act"))
            async let sprData = resourceManager.contentsOfResource(at: spritePath.appendingPathExtension("spr"))

            let act = try await ACT(data: actData)
            let spr = try await SPR(data: sprData)
            let spriteImages = spr.imagesBySpriteType()
            let action = act.action(at: 0)
            let actionFrames = action?.frames ?? []
            let usedFrames = playSprite ? actionFrames : Array(actionFrames.prefix(1))

            var images: [CGImage] = []
            var frames: [ThreeDEffectAsset.Frame] = []
            var imageIndicesBySprite: [SIMD2<Int> : Int] = [:]

            for frame in usedFrames {
                var layers: [ThreeDEffectAsset.Layer] = []
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

                    layers.append(ThreeDEffectAsset.Layer(
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
                frames.append(ThreeDEffectAsset.Frame(layers: layers))
            }

            return ThreeDEffectAsset(
                images: images,
                frames: frames,
                frameInterval: action.map { TimeInterval($0.frameInterval) }
            )
        }
    }

    static func load(textureNames: [String], using resourceManager: ResourceManager, cache: EffectAssetCache) async throws -> ThreeDEffectAsset {
        try await cache.resource(forIdentifier: "3DEffect/textures/\(textureNames.joined(separator: "|"))") {
            var images: [CGImage] = []
            var frames: [ThreeDEffectAsset.Frame] = []

            for textureName in textureNames {
                let texturePath = ResourcePath.textureDirectory.appending(subpath: textureName)
                let removesMagentaPixels = textureName.lowercased().hasSuffix(".bmp")
                let image = try await resourceManager.image(at: texturePath, removesMagentaPixels: removesMagentaPixels)
                let layer = ThreeDEffectAsset.Layer(imageIndex: images.count, sizeFactor: [1, 1])
                frames.append(ThreeDEffectAsset.Frame(layers: [layer]))
                images.append(image.cgImage)
            }

            return ThreeDEffectAsset(images: images, frames: frames, frameInterval: nil)
        }
    }
}
