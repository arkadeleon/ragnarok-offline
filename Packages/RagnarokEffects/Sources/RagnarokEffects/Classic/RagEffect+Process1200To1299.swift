//
//  RagEffect+Process1200To1299.swift
//  RagnarokEffects
//
//  Created by Leon Li on 2026/11/26.
//

import Foundation
import RagnarokCore
import simd

extension RagEffect {
    nonisolated static let proceduralEffectIDs1200To1299: [EffectID] = [
        .ef_blink_body,
    ]

    func process1200To1299(context: EffectTickContext) -> Bool {
        switch effectID {
        case .ef_blink_body:
            if stateCnt < 61, let targetID = targetObjectID ?? ownerObjectID {
                let color = stateCnt % 2 == 0
                    ? SIMD4<Float>(155.0 / 255.0, 155.0 / 255.0, 1.0, 1.0)
                    : SIMD4<Float>(50.0 / 255.0, 50.0 / 255.0, 50.0 / 255.0, 1.0)
                context.world.applyTargetModifier(.tint(color: color, durationTicks: 2), to: targetID)
            }
        default:
            return false
        }
        return true
    }
}
