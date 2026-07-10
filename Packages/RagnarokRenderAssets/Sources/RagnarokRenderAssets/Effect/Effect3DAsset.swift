//
//  Effect3DAsset.swift
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

public struct Effect3DAsset: Sendable {
    public struct Instance: Sendable {
        public let positionStart: SIMD3<Float>
        public let positionEnd: SIMD3<Float>
        public let sizeStart: SIMD2<Float>
        public let sizeEnd: SIMD2<Float>
        public let baseAngle: Float

        init(definition: Effect3DDefinition, duplicateID: Int) {
            var positionStart = definition.positionStart
            var positionEnd = definition.positionEnd

            if let range = definition.positionXRandomRange {
                let random = Float.random(in: range)
                positionStart.x = random
                positionEnd.x = random
            }
            if let range = definition.positionYRandomRange {
                let random = Float.random(in: range)
                positionStart.y = random
                positionEnd.y = random
            }
            if let range = definition.positionZRandomRange {
                let random = Float.random(in: range)
                positionStart.z = random
                positionEnd.z = random
            }

            if let range = definition.positionXRandomDifferenceRange {
                positionStart.x = Float.random(in: range)
                positionEnd.x = Float.random(in: range)
            }
            if let range = definition.positionYRandomDifferenceRange {
                positionStart.y = Float.random(in: range)
                positionEnd.y = Float.random(in: range)
            }
            if let range = definition.positionZRandomDifferenceRange {
                positionStart.z = Float.random(in: range)
                positionEnd.z = Float.random(in: range)
            }

            if let range = definition.positionStartXRandomRange {
                positionStart.x = Float.random(in: range)
            }
            if let range = definition.positionStartYRandomRange {
                positionStart.y = Float.random(in: range)
            }
            if let range = definition.positionStartZRandomRange {
                positionStart.z = Float.random(in: range)
            }

            if let range = definition.positionEndXRandomRange {
                positionEnd.x = Float.random(in: range)
            }
            if let range = definition.positionEndYRandomRange {
                positionEnd.y = Float.random(in: range)
            }
            if let range = definition.positionEndZRandomRange {
                positionEnd.z = Float.random(in: range)
            }

            positionStart += definition.offset
            positionEnd += definition.offset
            positionStart.z += definition.zOffsetStart
            positionEnd.z += definition.zOffsetEnd

            self.positionStart = positionStart
            self.positionEnd = positionEnd

            var sizeStart = definition.sizeStart ?? definition.size
            var sizeEnd = definition.sizeEnd ?? definition.size

            if let range = definition.sizeXRandomRange {
                let random = Float.random(in: range)
                sizeStart.x = random
                sizeEnd.x = random
            }
            if let range = definition.sizeYRandomRange {
                let random = Float.random(in: range)
                sizeStart.y = random
                sizeEnd.y = random
            }

            if definition.duplicate.sizeDelta != 0 {
                let delta = definition.duplicate.sizeDelta * Float(duplicateID)
                sizeStart += [delta, delta]
                sizeEnd += [delta, delta]
            }

            self.sizeStart = sizeStart
            self.sizeEnd = sizeEnd

            var baseAngle = definition.angle
            if definition.rotatesToTarget {
                baseAngle += 90 - degrees(atan2(positionEnd.y - positionStart.y, positionEnd.x - positionStart.x))
            }
            self.baseAngle = baseAngle
        }
    }

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
    public let soundName: String?
    public let sparkleCount: Float
    public let images: [CGImage]
    public let frames: [Effect3DAsset.Frame]
    public let instances: [Effect3DAsset.Instance]

    public func instance(forDuplicateID duplicateID: Int) -> Effect3DAsset.Instance {
        instances[min(max(duplicateID, 0), instances.count - 1)]
    }

    static func load(with definition: Effect3DDefinition, using resourceManager: ResourceManager) async throws -> Effect3DAsset {
        var fileName = definition.fileName
        var fileNames = definition.fileNames
        var soundName = definition.soundName
        if let randomNumberRange = definition.randomNumberRange {
            let randomNumber = Int.random(in: randomNumberRange)
            fileName = fileName?.replacingOccurrences(of: "%d", with: "\(randomNumber)")
            fileNames = fileNames.map {
                $0.replacingOccurrences(of: "%d", with: "\(randomNumber)")
            }
            soundName = soundName?.replacingOccurrences(of: "%d", with: "\(randomNumber)")
        }

        let sparkleCount: Float
        if let sparkleCountRandomRange = definition.sparkleCountRandomRange {
            sparkleCount = Float.random(in: sparkleCountRandomRange)
        } else {
            sparkleCount = definition.sparkleCount
        }

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
            if fileNames.isEmpty {
                textureNames = fileName.map { [$0] } ?? []
            } else {
                textureNames = fileNames
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

        let instances = (0..<max(definition.duplicate.count, 1)).map { duplicateID in
            Effect3DAsset.Instance(definition: definition, duplicateID: duplicateID)
        }

        let asset = Effect3DAsset(
            definition: definition,
            soundName: soundName,
            sparkleCount: sparkleCount,
            images: images,
            frames: frames,
            instances: instances
        )
        return asset
    }
}
