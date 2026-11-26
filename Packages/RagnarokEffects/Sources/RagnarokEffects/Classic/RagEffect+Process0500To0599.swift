//
//  RagEffect+Process0500To0599.swift
//  RagnarokEffects
//
//  Created by Leon Li on 2026/11/26.
//

import Foundation
import RagnarokCore
import simd

extension RagEffect {
    nonisolated static let proceduralEffectIDs0500To0599: [EffectID] = [
        .ef_chemicalbody,
        .ef_piercebody,
        .ef_groundsample,
        .ef_doublecastbody,
        .ef_greenbody,
        .ef_babybody_back,
        .ef_bluebody,
        .ef_redlightbody,
        .ef_quakebody3,
        .ef_kaizel,
    ]

    func process0500To0599(context: EffectTickContext) -> Bool {
        switch effectID {
        case .ef_chemicalbody:
            if stateCnt < 31, let targetID = targetObjectID ?? ownerObjectID {
                let color = stateCnt % 2 == 0
                    ? SIMD4<Float>(0.0, 0.0, 1.0, 1.0)
                    : SIMD4<Float>(1.0, 1.0, 1.0, 1.0)
                context.world.applyTargetModifier(.tint(color: color, durationTicks: 2), to: targetID)
            }
        case .ef_piercebody:
            if stateCnt == 0 {
                context.world.playSound(
                    named: "effect\\EF_BeginSpell.wav",
                    atWorldPosition: EffectSpace.toWorldPosition(position),
                    delay: 0
                )
            }
            if stateCnt <= 140, let targetID = targetObjectID ?? ownerObjectID {
                let color = stateCnt % 2 == 0
                    ? SIMD4<Float>(250.0 / 255.0, 250.0 / 255.0, 100.0 / 255.0, 1.0)
                    : SIMD4<Float>(1.0, 1.0, 1.0, 1.0)
                context.world.applyTargetModifier(.tint(color: color, durationTicks: 2), to: targetID)
            }
        case .ef_groundsample:
            groundSample(context: context)
        case .ef_doublecastbody:
            if stateCnt >= 10 && stateCnt <= 50, let targetID = targetObjectID ?? ownerObjectID {
                let color = stateCnt % 2 == 0
                    ? SIMD4<Float>(1.0, 0.0, 0.0, 1.0)
                    : SIMD4<Float>(1.0, 1.0, 1.0, 1.0)
                context.world.applyTargetModifier(.tint(color: color, durationTicks: 2), to: targetID)
            }
        case .ef_greenbody:
            if stateCnt < 31, let targetID = targetObjectID ?? ownerObjectID {
                let color = stateCnt % 2 == 0
                    ? SIMD4<Float>(0.0, 1.0, 0.0, 1.0)
                    : SIMD4<Float>(1.0, 1.0, 1.0, 1.0)
                context.world.applyTargetModifier(.tint(color: color, durationTicks: 2), to: targetID)
            }
        case .ef_babybody_back:
            if stateCnt <= 15, let targetID = targetObjectID ?? ownerObjectID {
                let scale = Self.shrinkPulseScale(phase: 45 - stateCnt * 3)
                context.world.applyTargetModifier(.scale(SIMD3<Float>(scale, scale, scale), durationTicks: 2), to: targetID)
            }
        case .ef_bluebody:
            if stateCnt <= 150, let targetID = targetObjectID ?? ownerObjectID,
               let alpha = Self.tintedOverlayAlpha(phase: stateCnt / 3) {
                context.world.applyTargetModifier(
                    .flash(color: SIMD4<Float>(5.0 / 255.0, 5.0 / 255.0, 1.0, alpha), durationTicks: 2),
                    to: targetID
                )
            }
        case .ef_redlightbody:
            if let targetID = targetObjectID ?? ownerObjectID {
                let phase = stateCnt <= 200 ? Int(Float(stateCnt) * 0.125) : 25
                if let alpha = Self.tintedOverlayAlpha(phase: phase) {
                    context.world.applyTargetModifier(
                        .flash(color: SIMD4<Float>(1.0, 5.0 / 255.0, 5.0 / 255.0, alpha), durationTicks: 2),
                        to: targetID
                    )
                }
            }
        case .ef_quakebody3:
            if stateCnt >= 31 && stateCnt <= 50, let targetID = targetObjectID ?? ownerObjectID {
                context.world.applyTargetModifier(.shake(amplitude: 2.0, durationTicks: 2), to: targetID)
            }
        case .ef_kaizel:
            if stateCnt == 15 {
                jobLvUp50Pair(angle: 0, context: context)
                jobLvUp50Pair(angle: 45, context: context)
            }
        default:
            return false
        }
        return true
    }

    // MARK: - EF_GROUNDSAMPLE (513)

    /// Spawns primitive `112` terrain-conformed magic target grid for `EF_GROUNDSAMPLE` (513).
    func groundSample(context: EffectTickContext) {
        guard stateCnt == 0 else {
            return
        }

        let texturePath = "effect\\magic_target.tga"
        _ = context.assets?.texture(atPath: texturePath)

        let primitive = launchPrimitive(112)
        primitive.state.renderFlag = EffectPrimitiveState.RenderFlag.alpha | EffectPrimitiveState.RenderFlag.customBlend
        primitive.state.duration = duration
        primitive.state.totalTexture = 1
        primitive.state.texturePaths = [texturePath]
        for i in 0..<4 {
            primitive.state.slots[i].life = 0
        }
        primitive.state.slots[0].life = 1
        primitive.state.slots[0].rotStart = 0
    }

    // MARK: - EF_KAIZEL (590)

    /// Spawns `PP_SLASH1` (75) four-way fan quads for `EF_KAIZEL` (590).
    func jobLvUp50Pair(angle: Int16, context: EffectTickContext) {
        let texturePath = "effect\\magic_blue.tga"
        _ = context.assets?.texture(atPath: texturePath)

        let primitive = launchPrimitive(.pp_slash1)
        primitive.state.renderFlag = EffectPrimitiveState.RenderFlag.alpha | EffectPrimitiveState.RenderFlag.customBlend
        primitive.state.duration = duration
        primitive.state.texturePaths = [texturePath]
        primitive.state.size = 4.0

        for i in 0..<4 {
            primitive.state.slots[i].life = 1
            primitive.state.slots[i].process = 0
            primitive.state.slots[i].maxHeight = 1.5
            primitive.state.slots[i].rotStart = Int16(i * 90) + angle
            primitive.state.slots[i].alphaB = 0
            primitive.state.slots[i].distance = 2.0
            primitive.state.slots[i].height[0] = 1.0
            primitive.state.slots[i].flag1[0] = 0
        }
    }
}
