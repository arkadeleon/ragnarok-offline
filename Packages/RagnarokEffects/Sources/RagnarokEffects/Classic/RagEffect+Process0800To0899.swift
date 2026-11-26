//
//  RagEffect+Process0800To0899.swift
//  RagnarokEffects
//
//  Created by Leon Li on 2026/11/26.
//

import Foundation
import RagnarokCore
import simd

extension RagEffect {
    nonisolated static let proceduralEffectIDs0800To0899: [EffectID] = [
        .ef_blackbody,
        .ef_beginspell_n1,
        .ef_water_fade,
        .ef_primecharge,
        .ef_dq9_charge4,
    ]

    func process0800To0899(context: EffectTickContext) -> Bool {
        switch effectID {
        case .ef_blackbody:
            if let targetID = targetObjectID ?? ownerObjectID {
                if stateCnt >= 6 && stateCnt <= 60 {
                    let value: Float = (stateCnt & 1) != 0 ? 1.0 : 0.0
                    context.world.applyTargetModifier(
                        .tint(color: SIMD4<Float>(value, value, value, 1.0), durationTicks: 2),
                        to: targetID
                    )
                } else if stateCnt >= 61 {
                    context.world.applyTargetModifier(
                        .tint(color: SIMD4<Float>(1.0, 128.0 / 255.0, 1.0, 1.0), durationTicks: 2),
                        to: targetID
                    )
                }
            }
            texturedSkillAura(type: 6, context: context)
        case .ef_beginspell_n1:
            if stateCnt == 1 {
                context.world.playSound(
                    named: "effect\\EF_BeginSpell.wav",
                    atWorldPosition: EffectSpace.toWorldPosition(position),
                    delay: 0
                )
            }
            bubbleSpiralKind(angle: 45, kind: 1, context: context)
            bubbleSpiralKind(angle: 25, kind: 0, context: context)
        case .ef_water_fade:
            texturedDualSpin(
                firstTexturePath: "effect\\W_Comp_00.tga",
                secondTexturePath: "effect\\W_Comp_24.tga",
                context: context
            )
        case .ef_primecharge:
            if stateCnt == 10 {
                context.world.playSound(
                    named: "effect\\LG_EXEEDBREAK.wav",
                    atWorldPosition: EffectSpace.toWorldPosition(position),
                    delay: 0
                )
            }
            for _ in 0..<40 {
                texturedScatterSphere(texturePath: "effect\\alpha_center.tga", flag: 0, context: context)
            }
        case .ef_dq9_charge4:
            texturedSpiralFade(texturePath: "effect\\shockwave_c.bmp", context: context)
        default:
            return false
        }
        return true
    }

    // MARK: - EF_BEGINSPELL_N1 (830)

    /// Spawns primitive `144` expanding bubble-spiral ground arcs for `EF_BEGINSPELL_N1` (830).
    func bubbleSpiralKind(angle: Int16, kind: Int8, context: EffectTickContext) {
        guard stateCnt == 0 else {
            return
        }

        if duration < 100 {
            duration = 100
        }

        let primitive = launchPrimitive(144)
        primitive.state.renderFlag = EffectPrimitiveState.RenderFlag.alpha | EffectPrimitiveState.RenderFlag.customBlend
        primitive.state.duration = duration

        if kind <= 1 {
            let paths = (1...27).map { String(format: "effect\\W_bubble%02d.tga", $0) }
            primitive.state.totalTexture = paths.count
            primitive.state.texturePaths = paths
            for path in paths {
                _ = context.assets?.texture(atPath: path)
            }
            primitive.state.size = kind == 1 ? 4.0 : 0.0
        } else if kind <= 3 {
            let paths = (1...29).map { String(format: "effect\\W_A_top%02d.tga", $0) }
            primitive.state.totalTexture = paths.count
            primitive.state.texturePaths = paths
            for path in paths {
                _ = context.assets?.texture(atPath: path)
            }
            primitive.state.size = kind == 3 ? 4.0 : 0.0
        }

        let configs: [(maxHeight: Float, rotStart: Int16, alphaOffset: Int16)] = [
            (30.0, 180, 135),
            (29.0, 270, 90),
            (28.0, 0, 45),
            (27.0, 90, 0),
        ]

        for (index, config) in configs.enumerated() {
            primitive.state.slots[index].life = 1
            primitive.state.slots[index].process = duration <= 60 ? index * -5 : 0
            primitive.state.slots[index].fullDisplayAngle = 360
            primitive.state.slots[index].maxHeight = config.maxHeight
            primitive.state.slots[index].rotStart = config.rotStart
            primitive.state.slots[index].alphaB = duration <= 60 ? 0 : (angle + config.alphaOffset)
            primitive.state.slots[index].distance = 4.1
            primitive.state.slots[index].riseAngle = 80
            primitive.state.slots[index].alphaT = Int16(kind)
            primitive.state.slots[index].vecBNow.y = 0
            for step in 0..<21 {
                primitive.state.slots[index].height[step] = 0
                primitive.state.slots[index].flag1[step] = 0
            }
        }
    }

    // MARK: - EF_WATER_FADE (839)

    /// Spawns primitive `148` cross-fading dual-texture ground square for `EF_WATER_FADE` (839).
    func texturedDualSpin(
        firstTexturePath: String,
        secondTexturePath: String,
        context: EffectTickContext
    ) {
        guard stateCnt == 0 else {
            return
        }

        _ = context.assets?.texture(atPath: firstTexturePath)
        _ = context.assets?.texture(atPath: secondTexturePath)

        let primitive = launchPrimitive(148)
        primitive.state.renderFlag = EffectPrimitiveState.RenderFlag.alpha | EffectPrimitiveState.RenderFlag.customBlend
        primitive.state.duration = duration
        primitive.state.totalTexture = 2
        primitive.state.texturePaths = [firstTexturePath, secondTexturePath]
        primitive.state.slots[0].life = 1
        primitive.state.slots[1].life = 0
        primitive.state.slots[2].life = 0
        primitive.state.slots[3].life = 0
        primitive.state.slots[0].process = 0
        primitive.state.slots[0].distance = param[0] < 5.0 ? 20.0 : param[0]
        let rotation = param[1]
        primitive.state.slots[0].rotStart = (rotation < 0 || rotation >= 360) ? 45 : Int16(rotation)
        primitive.state.slots[0].riseAngle = Int16(Int.random(in: 0..<360))
        primitive.state.slots[0].height[0] = -2.0
        primitive.state.slots[0].height[1] = 0
    }

    // MARK: - EF_PRIMECHARGE (882)

    /// Spawns primitive `159` inward-collapsing spiral blades for `EF_PRIMECHARGE` (882).
    func texturedScatterSphere(texturePath: String, flag: Int8, context: EffectTickContext) {
        guard stateCnt == 0 else {
            return
        }

        _ = context.assets?.texture(atPath: texturePath)

        let primitive = launchPrimitive(159)
        primitive.state.renderFlag = EffectPrimitiveState.RenderFlag.alpha | EffectPrimitiveState.RenderFlag.customBlend
        primitive.state.duration = duration
        primitive.state.texturePaths = [texturePath]

        for index in 0..<4 {
            let riseAngle = Int16(Int.random(in: 0..<360))
            let rotStart = Int16(Int.random(in: 0..<360))
            let radius = EffectSpace.cosine(degrees: Int(riseAngle)) * 70.0
            let z = EffectSpace.sine(degrees: Int(riseAngle)) * 70.0
            let x = radius * EffectSpace.cosine(degrees: Int(rotStart))
            let y = radius * EffectSpace.sine(degrees: Int(rotStart)) - 5.0

            primitive.state.slots[index].life = 1
            primitive.state.slots[index].height[4] = 0
            primitive.state.slots[index].process = -Int.random(in: 0..<101)
            primitive.state.slots[index].distance = 4.0
            primitive.state.slots[index].alphaB = 0
            primitive.state.slots[index].riseAngle = riseAngle
            primitive.state.slots[index].rotStart = rotStart
            primitive.state.slots[index].height[0] = -5.0
            primitive.state.slots[index].height[1] = 0.5
            primitive.state.slots[index].flag1[0] = 0
            primitive.state.slots[index].flag1[1] = 0
            primitive.state.slots[index].flag1[2] = flag
            primitive.state.slots[index].vecBNow = SIMD3<Float>(x, y, z)
        }
    }

    // MARK: - EF_DQ9_CHARGE4 (898)

    /// Spawns primitive `165` dual-layer curved fan trails for `EF_DQ9_CHARGE4` (898).
    func texturedSpiralFade(texturePath: String, context: EffectTickContext) {
        guard stateCnt <= 2 else {
            return
        }

        _ = context.assets?.texture(atPath: texturePath)

        let primitive = launchPrimitive(165)
        primitive.state.renderFlag = EffectPrimitiveState.RenderFlag.alpha | EffectPrimitiveState.RenderFlag.customBlend
        primitive.state.duration = duration
        primitive.state.totalTexture = 1
        primitive.state.texturePaths = [texturePath]

        for slot in 0..<4 {
            primitive.state.slots[slot].life = 1
            primitive.state.slots[slot].process = 0
            primitive.state.slots[slot].distance = 0
            primitive.state.slots[slot].height[10] = 0
            primitive.state.slots[slot].maxHeight = 15.0
            primitive.state.slots[slot].alphaB = 0
            primitive.state.slots[slot].riseAngle = Int16((stateCnt * 4 + slot) * 30)
            primitive.state.slots[slot].rotStart = 0
            primitive.state.slots[slot].height[0] = -5.0
            primitive.state.slots[slot].height[1] = 0
        }
    }
}
