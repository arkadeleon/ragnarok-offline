//
//  RagEffect+Process0600To0699.swift
//  RagnarokEffects
//
//  Created by Leon Li on 2026/11/26.
//

import Foundation
import RagnarokCore
import simd

extension RagEffect {
    nonisolated static let proceduralEffectIDs0600To0699: [EffectID] = [
        .ef_quakebody4,
        .ef_undeadbody,
        .ef_undeadbody_del,
        .ef_dust,
    ]

    func process0600To0699(context: EffectTickContext) -> Bool {
        switch effectID {
        case .ef_quakebody4:
            if stateCnt == 20 {
                context.world.playSound(
                    named: "effect\\ef_hit6.wav",
                    atWorldPosition: EffectSpace.toWorldPosition(position),
                    delay: 0
                )
            }
            if stateCnt > 20, let targetID = targetObjectID ?? ownerObjectID {
                context.world.applyTargetModifier(.shake(amplitude: 2.0, durationTicks: 2), to: targetID)
                let color = stateCnt % 2 == 0
                    ? SIMD4<Float>(250.0 / 255.0, 50.0 / 255.0, 50.0 / 255.0, 1.0)
                    : SIMD4<Float>(1.0, 1.0, 1.0, 1.0)
                context.world.applyTargetModifier(.tint(color: color, durationTicks: 2), to: targetID)
            }
        case .ef_undeadbody:
            if let targetID = targetObjectID ?? ownerObjectID {
                let alpha = Float(min(stateCnt, 200)) / 255.0
                context.world.applyTargetModifier(
                    .outline(
                        color: SIMD4<Float>(5.0 / 255.0, 155.0 / 255.0, 5.0 / 255.0, alpha),
                        spread: 2.0,
                        layers: 2,
                        durationTicks: 2
                    ),
                    to: targetID
                )
            }
        case .ef_undeadbody_del:
            if stateCnt < 40, let targetID = targetObjectID ?? ownerObjectID {
                let alpha = Float(max(0, 200 - stateCnt * 5)) / 255.0
                context.world.applyTargetModifier(
                    .outline(
                        color: SIMD4<Float>(5.0 / 255.0, 155.0 / 255.0, 5.0 / 255.0, alpha),
                        spread: 2.0,
                        layers: 2,
                        durationTicks: 2
                    ),
                    to: targetID
                )
            }
        case .ef_dust:
            torchDust(kind: 0, context: context)
        default:
            return false
        }
        return true
    }

    // MARK: - EF_DUST (689)

    /// Spawns `PP_EFFECTTEXTURE_ANI` (128) animated billboard panel for `EF_DUST` (689).
    func torchDust(kind: Int8, context: EffectTickContext) {
        guard stateCnt == 0 else {
            return
        }

        let texturePaths: [String] = switch kind {
        case 0:
            (1...9).map { String(format: "effect\\dust%02d.bmp", $0) }
        case 1:
            (1...13).map { String(format: "effect\\torch_red%02d.bmp", $0) }
        case 2:
            (1...13).map { String(format: "effect\\torch_green%02d.bmp", $0) }
        case 3:
            (1...13).map { String(format: "effect\\torch_violet%02d.bmp", $0) }
        case 4:
            [
                "effect\\lord_stick_a.bmp",
                "effect\\lord_stick_b.bmp",
                "effect\\lord_stick_c.bmp",
                "effect\\lord_stick_e.bmp",
                "effect\\lord_stick_f.bmp",
                "effect\\lord_stick_g.bmp",
                "effect\\lord_stick_h.bmp",
                "effect\\lord_stick_plazma_a.bmp",
                "effect\\lord_stick_plazma_b.bmp",
                "effect\\lord_stick_plazma_c.bmp",
                "effect\\lord_blast_stick_a.bmp",
            ]
        default:
            []
        }

        for path in texturePaths {
            _ = context.assets?.texture(atPath: path)
        }

        let primitive = launchPrimitive(.pp_effecttexture_ani)
        primitive.state.renderFlag = EffectPrimitiveState.RenderFlag.alpha | EffectPrimitiveState.RenderFlag.customBlend
        primitive.state.duration = duration
        primitive.state.totalTexture = texturePaths.count
        primitive.state.texturePaths = texturePaths
        primitive.state.size = 0

        for i in 0..<4 {
            primitive.state.slots[i].life = 0
        }
        primitive.state.slots[0].life = 1
        primitive.state.slots[0].process = 0
        primitive.state.slots[0].distance = param[0] > 0 ? param[0] : 20.0
        primitive.state.slots[0].vecBPre.y = position.y - 10.0
        primitive.state.slots[0].flag1[2] = 4
        if kind == 4 {
            primitive.state.slots[0].fullDisplayAngle = 120
            primitive.state.slots[0].height[10] = 1.0
            primitive.state.slots[0].height[8] = 0
            primitive.state.slots[0].alphaB = 130
        } else {
            primitive.state.slots[0].fullDisplayAngle = 135
            primitive.state.slots[0].height[10] = 0
            primitive.state.slots[0].height[8] = 0
            primitive.state.slots[0].alphaB = kind != 0 ? 130 : 100
        }
        primitive.state.slots[0].vecBNow.x = position.x
        primitive.state.slots[0].vecBNow.z = position.z
        primitive.state.slots[0].rotStart = Int16(Int.random(in: 0..<360))
        primitive.state.slots[0].flag1[0] = 0
        primitive.state.slots[0].flag1[4] = kind
    }
}
