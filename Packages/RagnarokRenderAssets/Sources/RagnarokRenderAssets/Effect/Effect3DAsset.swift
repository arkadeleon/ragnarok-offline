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
        public let duplicateID: Int
        public let delay: TimeInterval
        public let positionStart: SIMD3<Float>
        public let positionEnd: SIMD3<Float>
        public let movementPositionStart: SIMD3<Float>
        public let movementPositionEnd: SIMD3<Float>
        public let sizeStart: SIMD2<Float>
        public let sizeEnd: SIMD2<Float>
        public let baseAngle: Float
        public let arc: Float
        public let retreat: Float

        init(definition: Effect3DDefinition, duplicateID: Int, patternIndex: Int) {
            self.duplicateID = duplicateID

            self.delay = definition.delayStart
                + definition.delay
                + definition.delayOffset
                + definition.duplicate.delayOffsetDelta * TimeInterval(duplicateID)
                + definition.delayLate
                + definition.duplicate.delayLateDelta * TimeInterval(duplicateID)
                + definition.duplicate.interval * TimeInterval(duplicateID)

            var positionStart = definition.positionStart
            var positionEnd = definition.positionEnd
            var movementPositionStart = definition.offset
            var movementPositionEnd = definition.offset
            movementPositionStart.z += definition.zOffsetStart
            movementPositionEnd.z += definition.zOffsetEnd

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
                let random = Float.random(in: range)
                positionStart.x = random
                movementPositionStart.x += random
            }
            if let range = definition.positionStartYRandomRange {
                let random = Float.random(in: range)
                positionStart.y = random
                movementPositionStart.y += random
            }
            if let range = definition.positionStartZRandomRange {
                let random = Float.random(in: range)
                positionStart.z = random
                movementPositionStart.z += random
            }

            if let range = definition.positionEndXRandomRange {
                let random = Float.random(in: range)
                positionEnd.x = random
                movementPositionEnd.x += random
            }
            if let range = definition.positionEndYRandomRange {
                let random = Float.random(in: range)
                positionEnd.y = random
                movementPositionEnd.y += random
            }
            if let range = definition.positionEndZRandomRange {
                let random = Float.random(in: range)
                positionEnd.z = random
                movementPositionEnd.z += random
            }

            positionStart += definition.offset
            positionEnd += definition.offset
            positionStart.z += definition.zOffsetStart
            positionEnd.z += definition.zOffsetEnd

            var arc = definition.arc
            var retreat = definition.retreat
            var angle = definition.angle

            if definition.soulStrikePattern {
                let patternAngle = Float(patternIndex) * 72
                let patternRadius: Float = 2
                let patternOffset = SIMD2(
                    cos(radians(patternAngle)) * patternRadius,
                    sin(radians(patternAngle)) * patternRadius
                )

                positionStart.x += patternOffset.x
                positionStart.y += patternOffset.y
                movementPositionStart.x += patternOffset.x
                movementPositionStart.y += patternOffset.y

                arc *= 1 + Float(patternIndex) * 0.1
                retreat *= 1 + Float(patternIndex) * 0.2
                angle += patternAngle
            }

            self.positionStart = positionStart
            self.positionEnd = positionEnd
            self.movementPositionStart = movementPositionStart
            self.movementPositionEnd = movementPositionEnd
            self.arc = arc
            self.retreat = retreat

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

            self.baseAngle = angle
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
    public let frameDelay: TimeInterval
    public let images: [CGImage]
    public let frames: [Effect3DAsset.Frame]

    public func makeInstances() -> [Effect3DAsset.Instance] {
        let patternIndex = Int.random(in: 0..<5)
        return (0..<max(definition.duplicate.count, 1)).map { duplicateID in
            Effect3DAsset.Instance(definition: definition, duplicateID: duplicateID, patternIndex: patternIndex)
        }
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

        var frameDelay = definition.frameDelay

        var images: [CGImage] = []
        var frames: [Effect3DAsset.Frame] = []

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

        let asset = Effect3DAsset(
            definition: definition,
            soundName: soundName,
            sparkleCount: sparkleCount,
            frameDelay: frameDelay,
            images: images,
            frames: frames
        )
        return asset
    }
}
