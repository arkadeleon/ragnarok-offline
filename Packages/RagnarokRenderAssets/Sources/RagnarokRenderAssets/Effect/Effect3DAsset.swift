//
//  Effect3DAsset.swift
//  RagnarokRenderAssets
//
//  Created by Leon Li on 2026/7/9.
//

import CoreGraphics
import RagnarokEffects
import RagnarokFileFormats
import RagnarokResources

public struct Effect3DAsset: Sendable {
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
        public let layers: [Effect3DAsset.Layer]
    }

    public let definition: Effect3DDefinition
    public let images: [CGImage]
    public let frames: [Effect3DAsset.Frame]

    static func load(with definition: Effect3DDefinition, using resourceManager: ResourceManager) async throws -> Effect3DAsset {
        var images: [CGImage] = []
        var frames: [Effect3DAsset.Frame] = []

        if let spriteName = definition.spriteName {
            let spritePath = ResourcePath.spriteDirectory.appending(subpath: spriteName)

            async let actData = resourceManager.contentsOfResource(at: spritePath.appendingPathExtension("act"))
            async let sprData = resourceManager.contentsOfResource(at: spritePath.appendingPathExtension("spr"))

            let act = try await ACT(data: actData)
            let spr = try await SPR(data: sprData)
            let spriteImages = spr.imagesBySpriteType()
            let actionFrames = act.action(at: 0)?.frames ?? []
            let usedFrames = definition.playSprite ? actionFrames : Array(actionFrames.prefix(1))

            var imageIndicesBySprite: [SIMD2<Int> : Int] = [:]
            for frame in usedFrames {
                var layers: [Effect3DAsset.Layer] = []
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

                    layers.append(Effect3DAsset.Layer(
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
                frames.append(Effect3DAsset.Frame(layers: layers))
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
                let layer = Effect3DAsset.Layer(imageIndex: images.count, sizeFactor: [1, 1])
                let frame = Effect3DAsset.Frame(layers: [layer])
                frames.append(frame)
                images.append(image.cgImage)
            }
        }

        let asset = Effect3DAsset(definition: definition, images: images, frames: frames)
        return asset
    }
}
