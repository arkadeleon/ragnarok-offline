//
//  Effect2DAsset.swift
//  RagnarokRenderAssets
//
//  Created by Leon Li on 2026/7/9.
//

import CoreGraphics
import Foundation
import RagnarokCore
import RagnarokEffects
import RagnarokResources

public struct Effect2DAsset: Sendable {
    public struct Instance: Sendable {
        public let duration: TimeInterval
        public let positionStart: SIMD3<Float>
        public let positionEnd: SIMD3<Float>
        public let sizeStart: SIMD2<Float>
        public let sizeEnd: SIMD2<Float>
        public let baseAngle: Float
        public let targetAngle: Float

        init(definition: Effect2DDefinition, duplicateID: Int) {
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

            positionStart += definition.positionOffset
            positionEnd += definition.positionOffset

            var baseAngle = definition.angle + definition.duplicate.angleDelta * Float(duplicateID)
            let targetAngle = definition.targetAngle + definition.duplicate.angleDelta * Float(duplicateID)

            if definition.rotatesToTarget {
                baseAngle += 90 - degrees(atan2(positionEnd.y - positionStart.y, positionEnd.x - positionStart.x))
            }

            if let angleRandomRange = definition.angleRandomRange {
                baseAngle = Float.random(in: angleRandomRange)
            }

            if definition.circlePattern, let circleOuterSizeRandomRange = definition.circleOuterSizeRandomRange {
                let distance = Float.random(in: circleOuterSizeRandomRange)
                let angle = radians(baseAngle)
                positionEnd.x = sin(angle) * distance
                positionEnd.y = cos(angle) * distance
                positionStart.x = sin(angle) * definition.circleInnerSize
                positionStart.y = cos(angle) * definition.circleInnerSize
            }

            self.positionStart = positionStart
            self.positionEnd = positionEnd
            self.baseAngle = baseAngle
            self.targetAngle = targetAngle

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

            if let sizeStartXRandomRange = definition.sizeStartXRandomRange {
                sizeStart.x = Float.random(in: sizeStartXRandomRange)
            }
            if let sizeStartYRandomRange = definition.sizeStartYRandomRange {
                sizeStart.y = Float.random(in: sizeStartYRandomRange)
            }
            if let sizeEndXRandomRange = definition.sizeEndXRandomRange {
                sizeEnd.x = Float.random(in: sizeEndXRandomRange)
            }
            if let sizeEndYRandomRange = definition.sizeEndYRandomRange {
                sizeEnd.y = Float.random(in: sizeEndYRandomRange)
            }

            self.sizeStart = sizeStart
            self.sizeEnd = sizeEnd

            if let durationRandomRange = definition.durationRandomRange {
                self.duration = TimeInterval.random(in: durationRandomRange)
            } else {
                self.duration = definition.duration
            }
        }
    }

    public let definition: Effect2DDefinition
    public let soundName: String?
    public let textureImage: CGImage
    public let instances: [Effect2DAsset.Instance]

    public func instance(forDuplicateID duplicateID: Int) -> Effect2DAsset.Instance {
        instances[min(max(duplicateID, 0), instances.count - 1)]
    }

    static func load(with definition: Effect2DDefinition, using resourceManager: ResourceManager) async throws -> Effect2DAsset {
        var fileName = definition.fileName
        var soundName = definition.soundName
        if let randomNumberRange = definition.randomNumberRange {
            let randomNumber = Int.random(in: randomNumberRange)
            fileName = fileName.replacingOccurrences(of: "%d", with: "\(randomNumber)")
            soundName = soundName?.replacingOccurrences(of: "%d", with: "\(randomNumber)")
        }

        let texturePath = ResourcePath.textureDirectory.appending(subpath: fileName)
        let removesMagentaPixels = fileName.lowercased().hasSuffix(".bmp")
        let image = try await resourceManager.image(at: texturePath, removesMagentaPixels: removesMagentaPixels)

        let instances = (0..<max(definition.duplicate.count, 1)).map { duplicateID in
            Effect2DAsset.Instance(definition: definition, duplicateID: duplicateID)
        }

        let asset = Effect2DAsset(
            definition: definition,
            soundName: soundName,
            textureImage: image.cgImage,
            instances: instances
        )
        return asset
    }
}
