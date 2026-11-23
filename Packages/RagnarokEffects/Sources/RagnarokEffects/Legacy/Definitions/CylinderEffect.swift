//
//  CylinderEffect.swift
//  RagnarokEffects
//
//  Created by Leon Li on 2026/8/25.
//

import Foundation

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
    public let instances: [CylinderEffect.Instance]

    public init(definition: CylinderEffectDefinition) {
        self.definition = definition

        self.instances = (0..<definition.duplicate.count).map { duplicateID in
            CylinderEffect.Instance(definition: definition, duplicateID: duplicateID)
        }
    }
}
