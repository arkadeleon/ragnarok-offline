//
//  ThreeDEffect.swift
//  RagnarokEffects
//
//  Created by Leon Li on 2026/8/25.
//

import Foundation
import RagnarokCore

public struct ThreeDEffect: Sendable {
    public struct Instance: Sendable {
        public let duplicateID: Int
        public let sound: EffectSound?
        public let delay: TimeInterval
        public let sparkleCount: Float
        public let positionStart: SIMD3<Float>
        public let positionEnd: SIMD3<Float>
        public let movementPositionStart: SIMD3<Float>
        public let movementPositionEnd: SIMD3<Float>
        public let sizeStart: SIMD2<Float>
        public let sizeEnd: SIMD2<Float>
        public let baseAngle: Float
        public let arc: Float
        public let retreat: Float

        init(definition: ThreeDEffectDefinition, duplicateID: Int, patternIndex: Int) {
            self.duplicateID = duplicateID

            self.sound = definition.soundName.map { soundName in
                EffectSound(
                    name: soundName.replacingRandomNumber(in: definition.randomNumberRange),
                    delay: definition.duplicate.interval * TimeInterval(duplicateID) + definition.delaySound
                )
            }

            self.delay = definition.delayStart
                + definition.delay
                + definition.delayOffset
                + definition.duplicate.delayOffsetDelta * TimeInterval(duplicateID)
                + definition.delayLate
                + definition.duplicate.delayLateDelta * TimeInterval(duplicateID)
                + definition.duplicate.interval * TimeInterval(duplicateID)

            if definition.sparkleCount > 0 {
                self.sparkleCount = definition.sparkleCount
            } else if let range = definition.sparkleCountRandomRange {
                self.sparkleCount = Float.random(in: range)
            } else {
                self.sparkleCount = 1
            }

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

    public let definition: ThreeDEffectDefinition
    public let instances: [ThreeDEffect.Instance]

    public init(definition: ThreeDEffectDefinition) {
        self.definition = definition

        let patternIndex = Int.random(in: 0..<5)
        self.instances = (0..<definition.duplicate.count).map { duplicateID in
            ThreeDEffect.Instance(definition: definition, duplicateID: duplicateID, patternIndex: patternIndex)
        }
    }
}
