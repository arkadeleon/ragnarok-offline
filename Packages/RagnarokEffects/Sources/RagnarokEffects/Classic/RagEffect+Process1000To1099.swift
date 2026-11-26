//
//  RagEffect+Process1000To1099.swift
//  RagnarokEffects
//
//  Created by Leon Li on 2026/11/26.
//

import Foundation
import RagnarokCore
import simd

extension RagEffect {
    nonisolated static let proceduralEffectIDs1000To1099: [EffectID] = [
        .ef_bluelightbody,
        .ef_yellobody,
        .ef_whitebody,
        .ef_jumpbody1,
    ]

    func process1000To1099(context: EffectTickContext) -> Bool {
        switch effectID {
        case .ef_bluelightbody:
            if let targetID = targetObjectID ?? ownerObjectID,
               let alpha = Self.tintedOverlayAlpha(phase: 20) {
                context.world.applyTargetModifier(
                    .flash(color: SIMD4<Float>(5.0 / 255.0, 5.0 / 255.0, 1.0, alpha), durationTicks: 2),
                    to: targetID
                )
            }
        case .ef_yellobody:
            if let targetID = targetObjectID ?? ownerObjectID {
                context.world.applyTargetModifier(
                    .tint(color: SIMD4<Float>(251.0 / 255.0, 200.0 / 255.0, 4.0 / 255.0, 1.0), durationTicks: 2),
                    to: targetID
                )
            }
        case .ef_whitebody:
            if let targetID = targetObjectID ?? ownerObjectID {
                context.world.applyTargetModifier(
                    .flash(color: SIMD4<Float>(1.0, 1.0, 1.0, 1.0), durationTicks: 2),
                    to: targetID
                )
            }
        case .ef_jumpbody1:
            if stateCnt == 0 {
                context.world.playSound(
                    named: K2L("effect\\T_회피2.wav"),
                    atWorldPosition: EffectSpace.toWorldPosition(position),
                    delay: 0
                )
            }
            if stateCnt > 10, let targetID = targetObjectID ?? ownerObjectID {
                let level = stateCnt - 10
                let rise = Float(level * 20)
                let alpha = Float(max(0, 255 - level * 20)) / 255.0
                context.world.applyTargetModifier(.spriteOffset(SIMD2<Float>(0, rise), durationTicks: 2), to: targetID)
                context.world.applyTargetModifier(.alpha(alpha, durationTicks: 2), to: targetID)
            }
        default:
            return false
        }
        return true
    }
}
