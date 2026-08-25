//
//  CylinderEffect.swift
//  RagnarokRenderAssets
//
//  Created by Leon Li on 2026/8/25.
//

import Foundation
import RagnarokEffects

public struct CylinderEffect: Sendable {
    public struct Instance: Sendable {
        public let duplicateID: Int
        public let sound: EffectSound?
        public let delay: TimeInterval
        public let rotationDegrees: SIMD3<Float>

        init(definition: CylinderEffectDefinition, duplicateID: Int) {
            self.duplicateID = duplicateID

            self.sound = definition.soundName.map { soundName in
                EffectSound(
                    name: soundName,
                    delay: definition.duplicate.interval * TimeInterval(duplicateID)
                )
            }

            self.delay = definition.delayStart
                + definition.delayOffset
                + definition.duplicate.delayOffsetDelta * TimeInterval(duplicateID)
                + definition.delayLate
                + definition.duplicate.delayLateDelta * TimeInterval(duplicateID)
                + definition.duplicate.interval * TimeInterval(duplicateID)

            var rotationDegrees = definition.rotationDegrees
            if let range = definition.rotationXRandomRange {
                rotationDegrees.x += Float.random(in: range)
            }
            if let range = definition.rotationYRandomRange {
                rotationDegrees.y += Float.random(in: range)
            }
            if let range = definition.rotationZRandomRange {
                rotationDegrees.z += Float.random(in: range)
            }
            self.rotationDegrees = rotationDegrees
        }
    }

    public let definition: CylinderEffectDefinition

    init(definition: CylinderEffectDefinition) {
        self.definition = definition
    }

    public func makeInstances() -> [CylinderEffect.Instance] {
        (0..<max(definition.duplicate.count, 1)).map { duplicateID in
            CylinderEffect.Instance(definition: definition, duplicateID: duplicateID)
        }
    }
}
