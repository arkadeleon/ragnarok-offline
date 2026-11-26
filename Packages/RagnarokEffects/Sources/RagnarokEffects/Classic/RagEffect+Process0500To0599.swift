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
        .ef_groundsample,
        .ef_kaizel,
    ]

    func process0500To0599(context: EffectTickContext) -> Bool {
        switch effectID {
        case .ef_groundsample:
            groundSample(context: context)
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
