//
//  RagEffect+Process0400To0499.swift
//  RagnarokEffects
//
//  Created by Leon Li on 2026/11/26.
//

import Foundation
import RagnarokCore
import simd

extension RagEffect {
    nonisolated static let proceduralEffectIDs0400To0499: [EffectID] = [
        .ef_bottom_fogwall,
        .ef_rainbow,
        .ef_hitline3,
        .ef_hitline6,
        .ef_electric,
        .ef_electric2,
        .ef_hitline7,
        .ef_grandcross2,
        .ef_flowercast,
    ]

    func process0400To0499(context: EffectTickContext) -> Bool {
        switch effectID {
        case .ef_bottom_fogwall:
            texturedPulseKind(texturePath: "effect\\ring_white.tga", kind: 2, context: context)
        case .ef_rainbow:
            rainbow(texturePath: "effect\\alpha_center.tga", context: context)
        case .ef_hitline3:
            whiteSparkStreak(kind: 0, context: context)
        case .ef_hitline6:
            whiteSparkStreak(kind: 3, context: context)
        case .ef_electric:
            if stateCnt == 25 {
                context.world.playSound(
                    named: K2L("effect\\T_전기.wav"),
                    atWorldPosition: EffectSpace.toWorldPosition(position),
                    delay: 0
                )
            }
            electricRingLate(kind: 0, angle: 0, context: context)
            electricRingLate(kind: 0, angle: 180, context: context)
        case .ef_electric2:
            electricArc(kind: 0, angle: 0, context: context)
            electricArc(kind: 0, angle: 0, context: context)
        case .ef_hitline7:
            whiteSparkStreak(kind: 1, context: context)
        case .ef_grandcross2:
            grandCrossRings(angle: 0, kind: 1, context: context)
            grandCross2(flag: 1, context: context)
        case .ef_flowercast:
            texturedSlashAir(texturePath: "effect\\ring_blue.tga", size: 4, phase: 0, context: context)
            texturedSlashAir(texturePath: "effect\\ring_blue.tga", size: 4, phase: 1, context: context)
        default:
            return false
        }
        return true
    }

    // MARK: - EF_RAINBOW (410)

    /// Spawns `PP_RAINBOW` (93) 7-band spectral arch for `EF_RAINBOW` (396).
    func rainbow(texturePath: String, context: EffectTickContext) {
        guard stateCnt == 0 else {
            return
        }

        _ = context.assets?.texture(atPath: texturePath)

        let primitive = launchPrimitive(.pp_rainbow)
        primitive.state.renderFlag = EffectPrimitiveState.RenderFlag.alpha | EffectPrimitiveState.RenderFlag.customBlend
        primitive.state.duration = duration
        primitive.state.totalTexture = 1
        primitive.state.texturePaths = [texturePath]
        let yaw = Int(context.world.cameraYawDegrees)
        let facingYaw = Int16(((360 - yaw) % 360 + 360) % 360)
        for i in 0..<4 {
            primitive.state.slots[i].life = 0
        }
        primitive.state.slots[0].life = 1
        primitive.state.slots[0].process = 0
        primitive.state.slots[0].alphaB = 0
        primitive.state.slots[0].alphaT = facingYaw
        primitive.state.slots[0].distance = 50.0
        primitive.state.slots[0].fullDisplayAngle = 180
        primitive.state.slots[0].rotStart = 0
        primitive.state.slots[0].riseAngle = facingYaw
    }

    // MARK: - EF_HITLINE3 (428)

    /// Emits `PP_HITLINE3` (100) short spark streaks for `EF_HITLINE3` (428), `EF_HITLINE6` (431), and `EF_HITLINE7` (434).
    func whiteSparkStreak(kind: Int16, context: EffectTickContext) {
        let limit = if kind == 1 {
            2
        } else if kind == 3 {
            5
        } else {
            0
        }
        guard stateCnt >= 0, stateCnt < limit else {
            return
        }

        let texturePath = "effect\\white02.bmp"
        _ = context.assets?.texture(atPath: texturePath)

        let primitive = launchPrimitive(.pp_hitline3)
        primitive.state.renderFlag = EffectPrimitiveState.RenderFlag.alpha | EffectPrimitiveState.RenderFlag.customBlend
        primitive.state.duration = duration
        primitive.state.totalTexture = 1
        primitive.state.texturePaths = [texturePath]
        primitive.state.size = 0

        for index in 0..<4 {
            primitive.state.slots[index].life = 1

            if kind == 1 {
                primitive.state.slots[index].process = -Int.random(in: 0..<11)
                primitive.state.slots[index].maxHeight = 0.1
                primitive.state.slots[index].alphaB = Int16(Int.random(in: 0..<51) + 125)
                primitive.state.slots[index].distance = Float(Int.random(in: 0..<5)) + 5.0
                primitive.state.slots[index].vecTNow.y = 3.0
            } else if kind == 3 {
                primitive.state.slots[index].process = -30 - Int.random(in: 0..<41)
                primitive.state.slots[index].maxHeight = 0.07
                primitive.state.slots[index].alphaB = Int16(Int.random(in: 0..<121) + 125)
                primitive.state.slots[index].distance = Float(Int.random(in: 0..<6)) + 6.0
                primitive.state.slots[index].vecTNow.y = 4.0
            } else {
                primitive.state.slots[index].process = -Int.random(in: 0..<26)
                primitive.state.slots[index].maxHeight = 0.1
                primitive.state.slots[index].alphaB = Int16(Int.random(in: 0..<(kind >= 3 ? 121 : 51)) + 125)
                primitive.state.slots[index].distance = Float(Int.random(in: 0..<6)) + 6.0
                primitive.state.slots[index].vecTNow.y = 5.0
            }

            primitive.state.slots[index].riseAngle = Int16(Int.random(in: 0..<360))
            primitive.state.slots[index].height[0] = 0
            primitive.state.slots[index].vecTNow.x = Float(Int.random(in: 0..<7)) * 0.1 + 0.6
            primitive.state.slots[index].vecBNow = position
            primitive.state.slots[index].alphaT = kind

            if kind == 1 {
                let tailCount = Int(primitive.state.slots[index].vecTNow.y)
                for _ in 0..<10 {
                    primitive.state.slots[index].height[0] = min(180.0, primitive.state.slots[index].height[0] + 6.0)
                    for layer in stride(from: tailCount, through: 1, by: -1) {
                        primitive.state.slots[index].height[layer] = primitive.state.slots[index].height[layer - 1]
                    }
                }
            }
        }
    }

    // MARK: - EF_ELECTRIC (432)

    /// Spawns `PP_ELECTRIC` (101) radial lightning arcs on ticks 20...23 for `EF_ELECTRIC` (432).
    func electricRingLate(kind: Int16, angle: Int16, context: EffectTickContext) {
        guard stateCnt >= 20, stateCnt <= 23 else {
            return
        }

        let texturePath = "effect\\elec1.tga"
        _ = context.assets?.texture(atPath: texturePath)

        let primitive = launchPrimitive(.pp_electric)
        primitive.state.renderFlag = EffectPrimitiveState.RenderFlag.alpha | EffectPrimitiveState.RenderFlag.customBlend
        primitive.state.duration = duration
        primitive.state.totalTexture = 1
        primitive.state.texturePaths = [texturePath]
        primitive.state.size = 0

        for index in 0..<4 {
            primitive.state.slots[index].life = 1
            primitive.state.slots[index].process = 0
            primitive.state.slots[index].maxHeight = 0.1
            primitive.state.slots[index].alphaB = 0
            primitive.state.slots[index].riseAngle = Int16(index * 45) + angle
            primitive.state.slots[index].distance = 0
            primitive.state.slots[index].height[0] = 0
            primitive.state.slots[index].vecTNow.x = Float(Int.random(in: 0..<11)) * 0.01
            primitive.state.slots[index].vecBNow = position
            primitive.state.slots[index].vecTNow.y = 20.0
            for step in 1...20 {
                primitive.state.slots[index].height[step] = 0
                primitive.state.slots[index].flag1[step] = 0
            }
            primitive.state.slots[index].flag1[0] = 0
            primitive.state.slots[index].alphaT = kind
            primitive.state.slots[index].fullDisplayAngle = 0
        }
    }

    // MARK: - EF_ELECTRIC2 (433)

    /// Spawns `PP_ELECTRIC2` (102) directional lightning tubes for `EF_ELECTRIC2` (433).
    func electricArc(kind: Int16, angle: Int16, context: EffectTickContext) {
        guard stateCnt == 0 else {
            return
        }

        let texturePath = "effect\\elec1.tga"
        _ = context.assets?.texture(atPath: texturePath)

        let primitive = launchPrimitive(.pp_electric2)
        primitive.state.renderFlag = EffectPrimitiveState.RenderFlag.alpha | EffectPrimitiveState.RenderFlag.customBlend
        primitive.state.duration = duration
        primitive.state.totalTexture = 1
        primitive.state.texturePaths = [texturePath]
        primitive.state.size = 0

        let heading = EffectPrimitive.angle(dx: deltaPos.x - position.x, dy: deltaPos.z - position.z)
        for index in 0..<4 {
            primitive.state.slots[index].life = 1
            primitive.state.slots[index].process = 0
            primitive.state.slots[index].maxHeight = 0.1
            primitive.state.slots[index].alphaB = 0
            primitive.state.slots[index].riseAngle = heading
            primitive.state.slots[index].distance = 0
            primitive.state.slots[index].height[0] = index < 2 ? Float(index * 180) : Float(index * 180 - 360)
            primitive.state.slots[index].vecTNow.x = Float(Int.random(in: 0..<6)) * 0.01 + 0.2
            primitive.state.slots[index].vecBNow = position
            primitive.state.slots[index].vecTNow.y = 20.0
            for step in 1...20 {
                primitive.state.slots[index].height[step] = 0
            }
            primitive.state.slots[index].alphaT = kind
        }
    }

    // MARK: - EF_FLOWERCAST (488)

    /// Spawns dual-phase petal casting rings (`PP_FLOWERCAST` (108)) for `EF_FLOWERCAST` (488).
    func texturedSlashAir(texturePath: String, size: Int8, phase: Int8, context: EffectTickContext) {
        guard stateCnt == 0 else {
            return
        }

        _ = context.assets?.texture(atPath: texturePath)

        let primitive = launchPrimitive(.pp_flowercast)
        primitive.state.renderFlag = EffectPrimitiveState.RenderFlag.alpha | EffectPrimitiveState.RenderFlag.customBlend
        primitive.state.duration = duration
        primitive.state.texturePaths = [texturePath]
        primitive.state.size = Float(size)

        let configs: [(distance: Float, riseAngle: Int16, maxHeight: Float, rotStart: Int16)] = if phase == 0 {
            [
                (4.5, 85, 27.0, 0),
                (5.0, 80, 28.0, 90),
                (5.5, 70, 29.0, 180),
                (5.0, 75, 30.0, 270),
            ]
        } else {
            [
                (5.5, 50, 30.0, 90),
                (6.0, 55, 29.0, 180),
                (6.5, 65, 28.0, 270),
                (6.0, 60, 27.0, 0),
            ]
        }

        for (i, config) in configs.enumerated() {
            primitive.state.slots[i].life = 1
            primitive.state.slots[i].process = 0
            primitive.state.slots[i].fullDisplayAngle = 315
            primitive.state.slots[i].alphaB = 0
            primitive.state.slots[i].vecBNow.y = 0
            primitive.state.slots[i].distance = config.distance
            primitive.state.slots[i].riseAngle = config.riseAngle
            primitive.state.slots[i].maxHeight = config.maxHeight
            primitive.state.slots[i].rotStart = config.rotStart
            primitive.state.slots[i].vecTNow.x = Float(config.riseAngle)
            primitive.state.slots[i].vecTNow.y = config.maxHeight
            for j in 0..<21 {
                primitive.state.slots[i].height[j] = 0
                primitive.state.slots[i].flag1[j] = 0
            }
        }
    }
}
