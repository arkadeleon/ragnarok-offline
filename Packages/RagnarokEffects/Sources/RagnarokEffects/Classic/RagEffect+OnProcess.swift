//
//  RagEffect+OnProcess.swift
//  RagnarokEffects
//
//  Created by Leon Li on 2026/11/24.
//

import Foundation
import simd

extension RagEffect {

    // MARK: - Dispatch

    public nonisolated static let supportedEffectIDs: [EffectID] = [
        .ef_entry,
        .ef_bottom_dissonance,
        .ef_bottom_rokisweil,
        .ef_bottom_whistle,
        .ef_bottom_assassincross,
        .ef_heal,
        .ef_bottom_mag,
        .ef_bottom_sanc,
        .ef_heal3,
        .ef_hitline,
        .ef_guard,
        .ef_magnum2,
        .ef_bottom_basilica,
        .ef_linelink2,
        .ef_bottom_fogwall,
        .ef_hitline3,
        .ef_hitline6,
        .ef_hitline7,
        .ef_grandcross2,
        .ef_kaizel,
        .ef_infraredscan,
        .ef_beginspell_n1,
        .ef_water_fade,
        .ef_primecharge,
        .ef_dq9_charge4,
        .ef_selfscroll,
        .ef_waterball3,
    ]

    private nonisolated static let supportedEffectIDSet: Set<EffectID> = Set(supportedEffectIDs)

    public nonisolated static func supports(_ effectID: EffectID) -> Bool {
        supportedEffectIDSet.contains(effectID)
    }

    static func make(id: UUID, request: EffectSpawnRequest) -> RagEffect? {
        guard supports(request.effectID) else {
            return nil
        }

        return RagEffect(id: id, request: request) { effect, context in
            effect.processEffect(context: context)
        }
    }

    func processEffect(context: EffectTickContext) -> Bool {
        switch effectID {
        case .ef_entry:
            entry(context: context)
        case .ef_bottom_dissonance:
            texturedMagicRing(texturePath: "effect\\ring_blue.tga", kind: 0, context: context)
        case .ef_bottom_rokisweil:
            bottomOut(texturePath: "effect\\safeline.bmp", kind: 0, context: context)
        case .ef_bottom_whistle:
            bottomMusic(texturePath: "effect\\melody_b.bmp", kind: 0, context: context)
        case .ef_bottom_assassincross:
            texturedMagicRing(texturePath: "effect\\ring_red.tga", kind: 1, context: context)
        case .ef_heal:
            healBurst(texturePath: "effect\\alpha_down.tga", flag: 0, context: context)
        case .ef_bottom_mag:
            texturedPulseKind(texturePath: "effect\\ring_red.tga", kind: 0, context: context)
        case .ef_bottom_sanc:
            texturedPulseKind(texturePath: "effect\\alpha_down.tga", kind: 1, context: context)
        case .ef_heal3:
            healBurst(texturePath: "effect\\alpha_down.tga", flag: 1, context: context)
        case .ef_hitline:
            whiteSparks(kind: 0, context: context)
        case .ef_guard:
            kyrieGuard(texturePath: "effect\\guardK.tga", kind: 0, context: context)
        case .ef_magnum2:
            magnum2(texturePath: "effect\\ring_yellow.tga", context: context)
        case .ef_bottom_basilica:
            texturedFourRing(texturePath: "effect\\alpha_down.tga", kind: 0, context: context)
            texturedFourRing(texturePath: "effect\\alpha_down.tga", kind: 1, context: context)
        case .ef_linelink2:
            if stateCnt == 0 {
                context.world.playSound(
                    named: "effect\\소울 체인지.wav",
                    atWorldPosition: EffectSpace.toWorldPosition(position),
                    delay: 0
                )
            }
            trackTarget(context: context)
        case .ef_bottom_fogwall:
            texturedPulseKind(texturePath: "effect\\ring_white.tga", kind: 2, context: context)
        case .ef_hitline3:
            whiteSparkStreak(kind: 0, context: context)
        case .ef_hitline6:
            whiteSparkStreak(kind: 3, context: context)
        case .ef_hitline7:
            whiteSparkStreak(kind: 1, context: context)
        case .ef_grandcross2:
            grandCrossRings(angle: 0, kind: 1, context: context)
            grandCross2(flag: 1, context: context)
        case .ef_kaizel:
            if stateCnt == 15 {
                jobLvUp50Pair(angle: 0, context: context)
                jobLvUp50Pair(angle: 45, context: context)
            }
        case .ef_infraredscan:
            if stateCnt == 0 {
                context.world.playSound(
                    named: "effect\\INFRAREDSCAN.wav",
                    atWorldPosition: EffectSpace.toWorldPosition(position),
                    delay: 0
                )
            }
            electricFan(fade: 0, context: context)
            electricFan(fade: 1, context: context)
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
        case .ef_selfscroll:
            texturedDoubleSpiral(texturePath: "effect\\shockwave_c.bmp", context: context)
        case .ef_waterball3:
            waterBallBurst(context: context)
        default:
            return false
        }
        return true
    }

    // MARK: - EF_ENTRY (6)

    /// Spawns counter-rotating `PP_3DCYLINDER` (13) rings for `EF_ENTRY` (6).
    private func entry(context: EffectTickContext) {
        guard stateCnt == 0 else {
            return
        }

        let texturePath = "effect\\ring_blue.tga"
        _ = context.assets?.texture(atPath: texturePath)

        let outer = launchPrimitive(.pp_3dcylinder)
        outer.state.duration = 55
        let outerRotX = EffectSpace.rotationX(radians: EffectSpace.radian(degrees: Int(outer.state.latitude)))
        let outerRotY = EffectSpace.rotationY(radians: EffectSpace.radian(degrees: Int(outer.state.longitude)))
        outer.state.transform = outerRotY * outerRotX
        outer.state.accel = -0.00007
        outer.state.longSpeed = -10.0
        outer.state.outerSize = 6.0
        outer.state.outerSpeed = 0.08
        outer.state.innerSize = 5.0
        outer.state.heightSize = 6.5
        outer.state.heightSpeed = -0.1
        outer.state.alpha = 5.0
        outer.state.maxAlpha = 245.0
        outer.state.alphaSpeed = 10.0
        outer.state.fadeOutCnt = outer.state.duration - outer.state.duration / 5
        outer.state.texturePaths = [texturePath]

        let inner = launchPrimitive(.pp_3dcylinder)
        inner.state.duration = 55
        inner.state.arcAngle = 45.0
        inner.state.longSpeed = 10.0
        inner.state.outerSize = 4.5
        inner.state.innerSize = 4.5
        inner.state.heightSpeed = 2.5
        let accel = -(inner.state.heightSpeed / Float(inner.state.duration))
        inner.state.heightAccel = accel + accel
        inner.state.alpha = 160.0
        inner.state.fadeOutCnt = inner.state.duration - inner.state.duration / 3
        inner.state.texturePaths = [texturePath]
    }

    // MARK: - EF_BOTTOM_DISSONANCE (277) / EF_BOTTOM_ASSASSINCROSS (287)

    /// Spawns `PP_BOTTOM2` (48) textured ground planes for `EF_BOTTOM_DISSONANCE` (277) and `EF_BOTTOM_ASSASSINCROSS` (287).
    private func texturedMagicRing(texturePath: String, kind: Int8, context: EffectTickContext) {
        guard stateCnt == 0 else {
            return
        }

        _ = context.assets?.texture(atPath: texturePath)

        let primitive = launchPrimitive(.pp_bottom2)
        primitive.state.renderFlag = EffectPrimitiveState.RenderFlag.alpha | EffectPrimitiveState.RenderFlag.customBlend
        primitive.state.duration = duration
        primitive.state.texturePaths = [texturePath]
        primitive.state.size = 0

        for i in 0..<4 {
            primitive.state.slots[i].process = 0
            primitive.state.slots[i].fullDisplayAngle = Int16(Int.random(in: 0..<360))
            primitive.state.slots[i].height[0] = Float(kind)

            if kind == 0 {
                primitive.state.slots[i].life = 1
                primitive.state.slots[i].vecBPre.x = Float(Int.random(in: 0..<40) - 20)
                primitive.state.slots[i].vecBPre.z = Float(Int.random(in: 0..<40) - 20)
                primitive.state.slots[i].vecBNow.x = 0
                primitive.state.slots[i].vecBNow.z = 0
                primitive.state.slots[i].alphaB = 15
            } else if kind == 1 || kind == 2 {
                primitive.state.slots[i].life = 1
                if i < 2 {
                    let offset = Float(Int.random(in: 0..<7)) - 3.0
                    primitive.state.slots[i].vecBPre.x = offset
                    primitive.state.slots[i].vecBPre.z = -3.0
                    primitive.state.slots[i].vecBNow.x = -offset
                    primitive.state.slots[i].vecBNow.z = 3.0
                } else {
                    let offset = Float(Int.random(in: 0..<7)) - 3.0
                    primitive.state.slots[i].vecBPre.x = -3.0
                    primitive.state.slots[i].vecBPre.z = offset
                    primitive.state.slots[i].vecBNow.x = 3.0
                    primitive.state.slots[i].vecBNow.z = -offset
                }
                primitive.state.slots[i].alphaB = 50
            } else if kind == 3 || kind == 4 {
                primitive.state.slots[i].life = i < 2 ? 1 : 0
                if i < 1 {
                    primitive.state.slots[i].vecBPre.x = 6.0
                    primitive.state.slots[i].vecBPre.z = 0
                    primitive.state.slots[i].vecBNow.x = -6.0
                    primitive.state.slots[i].vecBNow.z = 0
                } else {
                    primitive.state.slots[i].vecBPre.x = 0
                    primitive.state.slots[i].vecBPre.z = -6.0
                    primitive.state.slots[i].vecBNow.x = 0
                    primitive.state.slots[i].vecBNow.z = 6.0
                }
                primitive.state.slots[i].alphaB = 100
            }
        }
    }

    // MARK: - EF_BOTTOM_ROKISWEIL (283)

    /// Spawns `PP_BOTTOMOUT` (49) orbiting ground particles for `EF_BOTTOM_ROKISWEIL` (283).
    private func bottomOut(texturePath: String, kind: Int8, context: EffectTickContext) {
        guard stateCnt == 0 else {
            return
        }

        _ = context.assets?.texture(atPath: texturePath)

        let primitive = launchPrimitive(.pp_bottomout)
        primitive.state.renderFlag = EffectPrimitiveState.RenderFlag.alpha | EffectPrimitiveState.RenderFlag.customBlend
        primitive.state.duration = duration
        primitive.state.texturePaths = [texturePath]

        for i in 0..<4 {
            primitive.state.slots[i].life = 0
        }

        let count = kind == 1 ? 1 : 2
        for i in 0..<count {
            primitive.state.slots[i].life = 1
            primitive.state.slots[i].process = Int.random(in: 0..<11)
            if kind == 0 {
                primitive.state.slots[i].distance = Float(Int.random(in: 0..<6)) + 5.0
                primitive.state.slots[i].vecBPre.y = position.y
            } else {
                primitive.state.slots[i].distance = Float(Int.random(in: 0..<20)) * 0.1 + 3.0
                primitive.state.slots[i].vecBPre.y = position.y - 5.0
            }
            primitive.state.slots[i].height[8] = 0
            primitive.state.slots[i].alphaB = 0
            primitive.state.slots[i].vecBNow = SIMD3<Float>(position.x, primitive.state.slots[i].vecBPre.y, position.z)
            primitive.state.slots[i].fullDisplayAngle = 45
            primitive.state.slots[i].flag1[0] = 0
            primitive.state.slots[i].flag1[1] = kind
            primitive.state.slots[i].flag1[2] = 2
            primitive.state.slots[i].height[7] = 0
        }
    }

    // MARK: - EF_BOTTOM_WHISTLE (286)

    /// Spawns `PP_BOTTOM` (47) ground particles for `EF_BOTTOM_WHISTLE` (286).
    private func bottomMusic(texturePath: String, kind: Int8, context: EffectTickContext) {
        guard stateCnt == 0 else {
            return
        }

        _ = context.assets?.texture(atPath: texturePath)

        let primitive = launchPrimitive(.pp_bottom)
        primitive.state.renderFlag = EffectPrimitiveState.RenderFlag.alpha | EffectPrimitiveState.RenderFlag.customBlend
        primitive.state.duration = duration
        primitive.state.texturePaths = [texturePath]
        primitive.state.size = 0

        for i in 0..<4 {
            primitive.state.slots[i].life = 0
        }

        primitive.state.slots[0].life = 1
        primitive.state.slots[0].process = 0
        primitive.state.slots[0].distance = switch kind {
        case 1: 5.0
        case 4: 15.0
        case 6: 8.0
        case 9: 1.5
        default: 3.0
        }
        primitive.state.slots[0].height[8] = 0
        primitive.state.slots[0].alphaB = 200
        primitive.state.slots[0].vecBNow.x = position.x
        primitive.state.slots[0].vecBNow.z = position.z
        primitive.state.slots[0].vecBPre.y = position.y - 6.0
        primitive.state.slots[0].rotStart = Int16(Int.random(in: 0..<360))
        primitive.state.slots[0].fullDisplayAngle = 45
        primitive.state.slots[0].flag1[0] = 0
        primitive.state.slots[0].flag1[2] = 2
        primitive.state.slots[0].height[7] = 0

        if kind == 4 {
            primitive.state.slots[0].height[9] = 10.0
        } else if kind == 2 {
            for i in 1..<4 {
                primitive.state.slots[i].life = 1
                primitive.state.slots[i].alphaB = 0
            }
        } else if kind == 3 {
            primitive.state.slots[0].flag1[2] = 3
        } else if kind == 5 || kind == 6 {
            primitive.state.slots[0].flag1[2] = 4
        } else if kind == 7 {
            primitive.state.slots[0].flag1[2] = 7
        } else if kind == 9 {
            primitive.state.slots[0].flag1[2] = 9
            primitive.state.slots[0].flag1[3] = 6
        }
    }

    // MARK: - EF_HEAL (312) / EF_HEAL3 (320)

    /// Spawns pulsing casting columns (`60`) and rising particles (`PP_PARTICLE_UP` (59)) for `EF_HEAL` (312) and `EF_HEAL3` (320).
    private func healBurst(texturePath: String, flag: Int8, context: EffectTickContext) {
        let limit = flag != 0 ? 25 : 50

        if stateCnt == 0 {
            let primitive = launchPrimitive(60)
            primitive.state.renderFlag = EffectPrimitiveState.RenderFlag.alpha | EffectPrimitiveState.RenderFlag.customBlend
            primitive.state.duration = duration
            primitive.state.texturePaths = [texturePath]
            _ = context.assets?.texture(atPath: texturePath)

            if flag == 0 {
                primitive.state.size = 9.0
            } else if flag == 1 {
                primitive.state.size = 5.0
            }

            primitive.state.slots[0].life = 1
            primitive.state.slots[0].process = 0
            primitive.state.slots[0].fullDisplayAngle = 360
            primitive.state.slots[0].rotStart = Int16(Int.random(in: 0..<360))
            primitive.state.slots[0].alphaB = 0
            primitive.state.slots[0].riseAngle = 90
            primitive.state.slots[0].vecBNow.y = 0

            if flag == 0 {
                primitive.state.slots[0].alphaT = 60
                primitive.state.slots[0].maxHeight = 40.0
                primitive.state.slots[0].distance = 4.6
            } else if flag == 1 {
                primitive.state.slots[0].alphaT = 30
                primitive.state.slots[0].maxHeight = Float(Int.random(in: 0..<20)) + 40.0
                primitive.state.slots[0].distance = 4.5 + Float(Int.random(in: 0..<100)) * 0.005
            }

            for i in 0..<21 {
                primitive.state.slots[0].height[i] = 0
                primitive.state.slots[0].flag1[i] = 0
            }

            primitive.state.slots[1].life = 1
            primitive.state.slots[1].process = 0
            primitive.state.slots[1].fullDisplayAngle = 360
            primitive.state.slots[1].rotStart = Int16(Int.random(in: 0..<360))
            primitive.state.slots[1].alphaB = 0
            primitive.state.slots[1].riseAngle = 90
            primitive.state.slots[1].vecBNow.y = 0

            if flag == 0 {
                primitive.state.slots[1].alphaT = 60
                primitive.state.slots[1].maxHeight = 40.0
                primitive.state.slots[1].distance = 4.8
            } else if flag == 1 {
                primitive.state.slots[1].alphaT = 30
                primitive.state.slots[1].maxHeight = primitive.state.slots[0].maxHeight
                primitive.state.slots[1].distance = primitive.state.slots[0].distance + 0.2
            }

            for i in 0..<21 {
                primitive.state.slots[1].height[i] = 0
                primitive.state.slots[1].flag1[i] = 0
            }

            primitive.state.slots[2].life = 0
            primitive.state.slots[3].life = 0

            context.world.playSound(
                named: "_heal_effect.wav",
                atWorldPosition: EffectSpace.toWorldPosition(position),
                delay: 0
            )
            return
        }

        guard stateCnt <= limit, stateCnt % 6 == 0 else {
            return
        }

        if flag == 0 {
            let primitive = launchPrimitive(.pp_particle_up)
            primitive.state.renderFlag = EffectPrimitiveState.RenderFlag.alpha | EffectPrimitiveState.RenderFlag.customBlend
            primitive.state.duration = duration
            primitive.state.texturePaths = ["effect\\pok1.tga"]
            _ = context.assets?.texture(atPath: "effect\\pok1.tga")
            primitive.state.size = 0
            primitive.position = position

            for i in 0..<4 {
                primitive.state.slots[i].life = 1
                primitive.state.slots[i].process = 0
                primitive.state.slots[i].distance = Float(Int.random(in: 0..<10)) * 0.1 + 2.0
                primitive.state.slots[i].height[8] = 0
                primitive.state.slots[i].alphaB = 0
                primitive.state.slots[i].vecBNow.x = Float(Int.random(in: 0..<13)) + position.x - 6.0
                primitive.state.slots[i].vecBNow.z = Float(Int.random(in: 0..<13)) + position.z - 6.0
                primitive.state.slots[i].vecBNow.y = position.y
                primitive.state.slots[i].rotStart = 0
                primitive.state.slots[i].height[1] = 0
                primitive.state.slots[i].height[2] = Float(Int.random(in: 0..<40)) * 0.01 + 0.3
                primitive.state.slots[i].fullDisplayAngle = 0
                primitive.state.slots[i].flag1[0] = 0
                primitive.state.slots[i].flag1[1] = 0
                primitive.state.slots[i].flag1[2] = 11
                primitive.state.slots[i].height[7] = 0
            }
            return
        }

        if flag == 1 {
            let primitive = launchPrimitive(.pp_particle_up)
            primitive.state.renderFlag = EffectPrimitiveState.RenderFlag.alpha | EffectPrimitiveState.RenderFlag.customBlend
            primitive.state.duration = duration
            primitive.state.texturePaths = ["effect\\pok1.tga", "effect\\pok3.tga"]
            _ = context.assets?.texture(atPath: "effect\\pok1.tga")
            _ = context.assets?.texture(atPath: "effect\\pok3.tga")
            primitive.state.size = 0
            primitive.position = position

            for i in 0..<4 {
                primitive.state.slots[i].life = 1
                primitive.state.slots[i].process = 0
                primitive.state.slots[i].distance = Float(Int.random(in: 0..<10)) * 0.1 + 2.0
                primitive.state.slots[i].height[8] = 0
                primitive.state.slots[i].alphaB = 0
                primitive.state.slots[i].vecBNow.x = Float(Int.random(in: 0..<13)) + position.x - 6.0
                primitive.state.slots[i].vecBNow.z = Float(Int.random(in: 0..<13)) + position.z - 6.0
                primitive.state.slots[i].vecBNow.y = position.y
                primitive.state.slots[i].rotStart = 0
                primitive.state.slots[i].height[1] = 0
                primitive.state.slots[i].height[2] = Float(Int.random(in: 0..<40)) * 0.01 + 0.4
                primitive.state.slots[i].fullDisplayAngle = 0
                primitive.state.slots[i].flag1[0] = 0
                primitive.state.slots[i].flag1[1] = 1
                primitive.state.slots[i].flag1[2] = 11
                primitive.state.slots[i].height[7] = 0
            }
        }
    }

    // MARK: - EF_BOTTOM_MAG (318) / EF_BOTTOM_SANC (319) / EF_BOTTOM_FOGWALL (405)

    /// Spawns `PP_RECT_UP` (64) rising pulse columns for `EF_BOTTOM_MAG` (318), `EF_BOTTOM_SANC` (319), and `EF_BOTTOM_FOGWALL` (405).
    private func texturedPulseKind(texturePath: String, kind: Int8, context: EffectTickContext) {
        guard stateCnt == 0 else {
            return
        }

        _ = context.assets?.texture(atPath: texturePath)

        let primitive = launchPrimitive(.pp_rect_up)
        primitive.state.renderFlag = EffectPrimitiveState.RenderFlag.alpha | EffectPrimitiveState.RenderFlag.customBlend
        primitive.state.duration = duration
        primitive.state.texturePaths = [texturePath]
        primitive.state.size = 1.0
        primitive.state.slots[0].life = 1
        primitive.state.slots[0].process = 0
        primitive.state.slots[0].fullDisplayAngle = Int16(Int.random(in: 0..<360))
        primitive.state.slots[0].rotStart = 0

        if kind == 0 {
            primitive.state.slots[0].maxHeight = context.usesMinimalEffects ? 10.0 : 50.0
            primitive.state.slots[0].alphaB = 30
            primitive.state.slots[0].alphaT = 864
            primitive.state.slots[0].height[0] = 5.0
            primitive.state.slots[0].height[1] = 5.0
        } else {
            if kind == 1 || kind == 4 {
                primitive.state.slots[0].maxHeight = 16.0
                primitive.state.slots[0].alphaB = 120
                primitive.state.slots[0].alphaT = 1880
            } else if kind == 2 {
                primitive.state.slots[0].maxHeight = 32.0
                primitive.state.slots[0].alphaB = 30
                primitive.state.slots[0].alphaT = 29999
            } else if kind == 3 {
                primitive.state.slots[0].maxHeight = 16.0
            }
            primitive.state.slots[0].height[0] = 2.5
            primitive.state.slots[0].height[1] = 2.5
        }

        primitive.state.slots[0].height[2] = 0
        primitive.state.slots[0].height[3] = Float(kind)
        if kind == 4 {
            primitive.state.slots[0].height[4] = Float(Int.random(in: 0..<50))
        }
        primitive.state.slots[0].height[5] = 0
        primitive.state.slots[0].height[6] = 0
        primitive.state.slots[1].life = 0
        primitive.state.slots[2].life = 0
        primitive.state.slots[3].life = 0
    }

    // MARK: - EF_HITLINE (330)

    /// Emits `PP_HITLINE` (70) bouncing white spark trails for `EF_HITLINE` (330).
    private func whiteSparks(kind: Int16, context: EffectTickContext) {
        guard stateCnt >= 0, stateCnt <= 3 else {
            return
        }

        let texturePath = "effect\\white02.bmp"
        _ = context.assets?.texture(atPath: texturePath)

        let primitive = launchPrimitive(.pp_hitline)
        primitive.state.renderFlag = EffectPrimitiveState.RenderFlag.alpha | EffectPrimitiveState.RenderFlag.customBlend
        primitive.state.duration = duration
        primitive.state.totalTexture = 1
        primitive.state.texturePaths = [texturePath]
        primitive.state.size = 0

        for index in 0..<4 {
            primitive.state.slots[index].life = 1
            primitive.state.slots[index].process = -Int.random(in: 0..<26)
            primitive.state.slots[index].maxHeight = 0.1
            primitive.state.slots[index].alphaB = Int16(Int.random(in: 0..<51) + 125)
            primitive.state.slots[index].riseAngle = Int16(Int.random(in: 0..<360))
            primitive.state.slots[index].distance = Float(Int.random(in: 0..<8)) + 6.0
            primitive.state.slots[index].flag1[0] = 0
            primitive.state.slots[index].height[0] = 0
            primitive.state.slots[index].vecBNow = position
            primitive.state.slots[index].alphaT = kind
        }
    }

    // MARK: - EF_GUARD (336)

    /// Spawns `PP_GUARD` (61) sphere cage and plays the guard sound for `EF_GUARD` (336).
    private func kyrieGuard(texturePath: String, kind: Int8, context: EffectTickContext) {
        guard stateCnt == 0 else {
            return
        }

        context.world.playSound(
            named: "effect\\kyrie_guard.wav",
            atWorldPosition: EffectSpace.toWorldPosition(position),
            delay: 0
        )

        let secondaryTexture = "effect\\guardK2.tga"
        _ = context.assets?.texture(atPath: texturePath)
        _ = context.assets?.texture(atPath: secondaryTexture)

        let primitive = launchPrimitive(.pp_guard)
        primitive.state.renderFlag = EffectPrimitiveState.RenderFlag.alpha | EffectPrimitiveState.RenderFlag.customBlend
        primitive.state.duration = duration
        primitive.state.totalTexture = 2
        primitive.state.texturePaths = [texturePath, secondaryTexture]
        primitive.state.size = 11.0
        primitive.state.slots[0].life = 1
        primitive.state.slots[0].process = 0
        primitive.state.slots[0].maxHeight = 7.8
        primitive.state.slots[0].alphaB = 0
        primitive.state.slots[0].distance = 1.0
        primitive.state.slots[0].height[0] = 0
        primitive.state.slots[1].life = 0
        primitive.state.slots[2].life = 0
        primitive.state.slots[3].life = 0

        if kind == 2 || kind == 3 || kind == 4 || kind == 5 {
            primitive.state.slots[0].flag1[0] = kind
        } else {
            primitive.state.slots[0].flag1[0] = 0
        }
    }

    // MARK: - EF_MAGNUM2 (339)

    /// Emits `PP_MAGNUM2` (73) shockwave waves and sound cues for `EF_MAGNUM2` (339).
    private func magnum2(texturePath: String, context: EffectTickContext) {
        if stateCnt == 0 {
            flag = 0
        }

        if stateCnt == 20 {
            context.world.playSound(
                named: "permeter_attack.wav",
                atWorldPosition: EffectSpace.toWorldPosition(position),
                delay: 0
            )
        } else if stateCnt == 30 {
            context.world.playSound(
                named: "effect\\EF_MagnumBreak.wav",
                atWorldPosition: EffectSpace.toWorldPosition(position),
                delay: 0
            )
        }

        guard stateCnt >= 25, stateCnt <= 55, stateCnt % 3 == 0 else {
            return
        }

        flag += 1
        guard flag < 11 else {
            return
        }

        _ = context.assets?.texture(atPath: texturePath)

        let time = stateCnt - 25
        let primitive = launchPrimitive(.pp_magnum2)
        primitive.state.renderFlag = EffectPrimitiveState.RenderFlag.alpha | EffectPrimitiveState.RenderFlag.customBlend
        primitive.state.duration = duration
        primitive.state.totalTexture = 1
        primitive.state.texturePaths = [texturePath]
        primitive.state.size = 5.0

        for i in 0..<4 {
            primitive.state.slots[i].life = 0
        }

        for i in 0..<2 {
            primitive.state.slots[i].life = 1
            primitive.state.slots[i].process = 0
            primitive.state.slots[i].fullDisplayAngle = 360
            primitive.state.slots[i].maxHeight = 20.0 - Float(time) * 0.7
            primitive.state.slots[i].rotStart = Int16(i * 9 + time * 6)
            primitive.state.slots[i].alphaB = 0
            primitive.state.slots[i].distance = Float(time) * 0.2 + 5.0
            primitive.state.slots[i].riseAngle = Int16(70 - i * 8 - time * 2)
            primitive.state.slots[i].alphaT = Int16(i)
        }
    }

    // MARK: - EF_BOTTOM_BASILICA (374)

    /// Spawns `PP_RECT_UP2` (90) four-ring perimeter boxes for `EF_BOTTOM_BASILICA` (374).
    private func texturedFourRing(texturePath: String, kind: Int8, context: EffectTickContext) {
        guard stateCnt == 0 else {
            return
        }

        _ = context.assets?.texture(atPath: texturePath)

        let primitive = launchPrimitive(.pp_rect_up2)
        primitive.state.renderFlag = EffectPrimitiveState.RenderFlag.alpha | EffectPrimitiveState.RenderFlag.customBlend
        primitive.state.duration = duration
        primitive.state.texturePaths = [texturePath]
        primitive.state.size = 0

        let scale = Float(kind)
        let dynamicFade = Int16(duration > 30000 ? 30000 : max(0, duration - 90))

        for index in 0..<2 {
            primitive.state.slots[index].life = 1
            primitive.state.slots[index].process = 0
            primitive.state.slots[index].maxHeight = (kind == 0 || kind == 10 || kind == 20)
                ? Float(index) + 30.0
                : Float(index) + 20.0

            if kind == 0 || kind == 10 {
                primitive.state.slots[index].alphaB = 65
                primitive.state.slots[index].alphaT = 2415
            } else if kind == 20 {
                primitive.state.slots[index].alphaB = 65
                primitive.state.slots[index].alphaT = 2170
            } else {
                primitive.state.slots[index].alphaB = 32
                primitive.state.slots[index].alphaT = kind == 21 ? 2140 : 2385
            }

            if kind >= 10 && kind < 20 {
                primitive.state.slots[index].alphaT = dynamicFade
            }

            if kind == 10 || kind == 20 {
                primitive.state.slots[index].height[0] = Float(index) * 0.4 + 7.0
            } else if kind == 11 || kind == 21 {
                primitive.state.slots[index].height[0] = Float(index) * 0.4 + 8.5
            } else if kind == 0 {
                primitive.state.slots[index].height[0] = Float(index) * 0.4 + 12.5
            } else {
                primitive.state.slots[index].height[0] = Float(index) * 0.4 + 14.0
            }

            primitive.state.slots[index].height[1] = primitive.state.slots[index].height[0]
            primitive.state.slots[index].height[4] = scale
        }

        for index in 2..<4 {
            primitive.state.slots[index].life = 1
            primitive.state.slots[index].process = 0
            primitive.state.slots[index].maxHeight = (kind == 0 || kind == 10 || kind == 20)
                ? Float(index) + 30.0
                : Float(index) + 20.0

            if kind == 10 || kind == 20 {
                primitive.state.slots[index].distance = Float(index - 2) * 30.2
            } else if kind == 11 || kind == 21 {
                primitive.state.slots[index].distance = Float(index - 2) * 30.2 + 15.1
            } else if kind == 0 {
                primitive.state.slots[index].distance = Float(index - 2) * 53.2
            } else {
                primitive.state.slots[index].distance = Float(index - 2) * 53.2 + 26.6
            }

            if kind == 10 || kind == 20 {
                primitive.state.slots[index].height[0] = 7.8
            } else if kind == 11 || kind == 21 {
                primitive.state.slots[index].height[0] = 9.3
            } else if kind == 0 {
                primitive.state.slots[index].height[0] = 13.3
            } else {
                primitive.state.slots[index].height[0] = 14.8
            }

            primitive.state.slots[index].height[1] = primitive.state.slots[index].height[0]
            primitive.state.slots[index].height[3] = kind >= 10 ? 18.6 : 26.6
            primitive.state.slots[index].alphaB = 15
            primitive.state.slots[index].alphaT = kind >= 20 ? 2170 : 2415

            if kind >= 10 && kind < 20 {
                primitive.state.slots[index].alphaT = dynamicFade
            }

            primitive.state.slots[index].height[4] = scale
        }
    }

    // MARK: - EF_LINELINK2 (384)

    /// Spawns a `PP_LINELINK` (38) target-tracking link for `EF_LINELINK2` (384).
    private func trackTarget(context: EffectTickContext) {
        guard stateCnt == 0 else {
            return
        }

        let texturePath = "effect\\alpha_center.tga"
        _ = context.assets?.texture(atPath: texturePath)

        let primitive = launchPrimitive(.pp_linelink)
        primitive.state.renderFlag = EffectPrimitiveState.RenderFlag.alpha | EffectPrimitiveState.RenderFlag.customBlend
        primitive.state.duration = duration
        primitive.state.texturePaths = [texturePath]
        primitive.state.slots[0].life = 1
        primitive.state.slots[0].process = 0
        primitive.state.slots[0].alphaB = 0
        primitive.state.slots[0].distance = 0
        primitive.state.slots[0].maxHeight = 0.2
        primitive.state.slots[0].height[4] = 2.0
        primitive.state.slots[0].vecTNow = position

        let resolvedTargetObjectID: EffectTargetID? = if sourceObjectID != nil || sourcePosition != nil {
            sourceObjectID
        } else {
            targetObjectID
        }
        primitive.state.slots[0].targetObjectID = resolvedTargetObjectID

        let targetWorldPos = resolvedTargetObjectID.flatMap {
            context.world.targetState(for: $0)?.effectPosition
        } ?? sourcePosition
        if let targetWorldPos {
            primitive.state.slots[0].vecTPre = targetWorldPos
        } else {
            primitive.state.slots[0].life = 0
        }

        for i in 1..<4 {
            primitive.state.slots[i].life = 0
        }
    }

    // MARK: - EF_HITLINE3 (428) / EF_HITLINE6 (431) / EF_HITLINE7 (434)

    /// Emits `PP_HITLINE3` (100) short spark streaks for `EF_HITLINE3` (428), `EF_HITLINE6` (431), and `EF_HITLINE7` (434).
    private func whiteSparkStreak(kind: Int16, context: EffectTickContext) {
        let limit = if kind == 1 { 2 } else if kind == 3 { 5 } else { 0 }
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

    // MARK: - EF_GRANDCROSS2 (450)

    /// Spawns corner casting rings (`PP_GI_3` (34)) for `EF_GRANDCROSS2` (450).
    private func grandCrossRings(angle: Int16, kind: Int8, context: EffectTickContext) {
        guard stateCnt == 0 else {
            return
        }

        context.world.playSound(
            named: "effect\\cru_grand cross.wav",
            atWorldPosition: EffectSpace.toWorldPosition(position),
            delay: 0
        )

        let texturePath = kind == 0 ? "effect\\ring_white.tga" : "effect\\ring_black.tga"
        _ = context.assets?.texture(atPath: texturePath)

        let primitive = launchPrimitive(.pp_gi_3)
        primitive.state.renderFlag = EffectPrimitiveState.RenderFlag.alpha | EffectPrimitiveState.RenderFlag.customBlend
        primitive.state.duration = duration
        primitive.state.texturePaths = [texturePath]
        primitive.state.size = kind == 0 ? 1.0 : 12.0

        let configs: [(rotStart: Int16, offsetX: Int8, offsetZ: Int8)] = [
            (180, 23, 23),
            (90, 23, -23),
            (0, -23, -23),
            (270, -23, 23),
        ]

        for (index, config) in configs.enumerated() {
            primitive.state.slots[index].life = 1
            primitive.state.slots[index].process = 0
            primitive.state.slots[index].fullDisplayAngle = 90
            primitive.state.slots[index].maxHeight = 120.0
            primitive.state.slots[index].alphaB = angle
            primitive.state.slots[index].distance = 19.9
            primitive.state.slots[index].riseAngle = 90
            primitive.state.slots[index].flag1[4] = kind
            primitive.state.slots[index].rotStart = config.rotStart
            primitive.state.slots[index].flag1[0] = config.offsetX
            primitive.state.slots[index].flag1[1] = config.offsetZ
        }
    }

    /// Spawns ground cross pillars (`PP_GRANDCROSS2` (37)) for `EF_GRANDCROSS2` (450).
    private func grandCross2(flag: Int8, context: EffectTickContext) {
        guard stateCnt == 0 else {
            return
        }

        let texturePath = flag == 0 ? "effect\\ring_yellow.tga" : "effect\\ring_black.tga"
        _ = context.assets?.texture(atPath: texturePath)

        let primitive = launchPrimitive(.pp_grandcross2)
        primitive.state.renderFlag = EffectPrimitiveState.RenderFlag.alpha | EffectPrimitiveState.RenderFlag.customBlend
        primitive.state.duration = duration
        primitive.state.texturePaths = [texturePath]
        primitive.state.size = 1.0

        for index in 0..<2 {
            primitive.state.slots[index].life = 1
            primitive.state.slots[index].process = 0
            primitive.state.slots[index].maxHeight = 60.0
            primitive.state.slots[index].rotStart = Int16(index * 90)
            primitive.state.slots[index].alphaB = 0
            primitive.state.slots[index].height[0] = 24.0
            primitive.state.slots[index].height[1] = 3.2
            primitive.state.slots[index].height[2] = 0
        }
        primitive.state.slots[2].life = 0
        primitive.state.slots[3].life = 0
    }

    // MARK: - EF_KAIZEL (590)

    /// Spawns `PP_SLASH1` (75) four-way fan quads for `EF_KAIZEL` (590).
    private func jobLvUp50Pair(angle: Int16, context: EffectTickContext) {
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

    // MARK: - EF_WATERBALL3 (942)

    /// Spawns `PP_3DCIRCLE` (12) rings and a `PP_3DSPHERE` (14) burst for `EF_WATERBALL3` (942).
    private func waterBallBurst(context: EffectTickContext) {
        guard stateCnt == 0 else {
            return
        }

        context.world.playSound(
            named: "effect\\wizard_waterball_chulung.wav",
            atWorldPosition: EffectSpace.toWorldPosition(position),
            delay: 0
        )

        let ringTexture = "effect\\ring_blue.tga"
        let iceTexture = "effect\\ice.tga"
        _ = context.assets?.texture(atPath: ringTexture)
        _ = context.assets?.texture(atPath: iceTexture)

        let firstRing = launchPrimitive(.pp_3dcircle)
        firstRing.state.duration = 30
        firstRing.state.renderFlag |= EffectPrimitiveState.RenderFlag.noDepth
        firstRing.state.latitude = 90.0
        firstRing.state.radiusSpeed = 1.75
        firstRing.state.radiusAccel = -(firstRing.state.radiusSpeed / Float(firstRing.state.duration)) * 0.5
        firstRing.state.innerSize = 12.0
        firstRing.state.alpha = 0
        firstRing.state.alphaSpeed = firstRing.state.maxAlpha / 15.0
        firstRing.state.fadeOutCnt = 10
        firstRing.initSegment()
        firstRing.state.texturePaths = [ringTexture]

        let sphere = launchPrimitive(.pp_3dsphere)
        sphere.state.duration = 30
        sphere.state.radiusSpeed = 1.15
        sphere.state.radiusAccel = -(sphere.state.radiusSpeed / Float(sphere.state.duration)) * 0.5
        sphere.state.longSpeed = 3.0
        sphere.state.alpha = 0
        sphere.state.alphaSpeed = sphere.state.maxAlpha / 15.0
        sphere.state.fadeOutCnt = 10
        sphere.state.texturePaths = [iceTexture]

        let secondRing = launchPrimitive(.pp_3dcircle)
        secondRing.state.duration = 20
        secondRing.state.renderFlag |= EffectPrimitiveState.RenderFlag.noDepth
        secondRing.state.latitude = 90.0
        secondRing.state.radiusSpeed = 1.75
        secondRing.state.radiusAccel = -(secondRing.state.radiusSpeed / Float(secondRing.state.duration)) * 0.5
        secondRing.state.innerSize = 12.0
        secondRing.state.alpha = 0
        secondRing.state.alphaSpeed = secondRing.state.maxAlpha / 15.0
        secondRing.state.fadeOutCnt = 10
        secondRing.initSegment()
        secondRing.state.texturePaths = [ringTexture]
    }

    // MARK: - EF_BEGINSPELL_N1 (830)

    /// Spawns primitive `144` expanding bubble-spiral ground arcs for `EF_BEGINSPELL_N1` (830).
    private func bubbleSpiralKind(angle: Int16, kind: Int8, context: EffectTickContext) {
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
    private func texturedDualSpin(
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

    // MARK: - EF_SELFSCROLL (900)

    /// Spawns dual-layer primitive `166` folding ribbons for `EF_SELFSCROLL` (900).
    private func texturedDoubleSpiral(texturePath: String, context: EffectTickContext) {
        guard stateCnt <= 1 else {
            return
        }

        _ = context.assets?.texture(atPath: texturePath)

        let layers: [(distance: Float, alphaB: Int16, phaseSpeed: Float, shadeFlag: Float)] = [
            (6.0, 205, 0.01, 0.0),
            (10.5, 255, 0.015, 1.0),
        ]

        for layer in layers {
            let primitive = launchPrimitive(166)
            primitive.state.renderFlag = EffectPrimitiveState.RenderFlag.alpha | EffectPrimitiveState.RenderFlag.customBlend
            primitive.state.duration = duration
            primitive.state.totalTexture = 1
            primitive.state.texturePaths = [texturePath]

            for index in 0..<4 {
                primitive.state.slots[index].life = 1
                primitive.state.slots[index].process = 0
                primitive.state.slots[index].distance = layer.distance
                primitive.state.slots[index].alphaB = layer.alphaB
                primitive.state.slots[index].riseAngle = Int16((stateCnt * 4 + index) * 45)
                primitive.state.slots[index].rotStart = 0
                primitive.state.slots[index].height[0] = -5.0
                primitive.state.slots[index].height[1] = 0
                primitive.state.slots[index].height[9] = 0
                primitive.state.slots[index].height[2] = layer.phaseSpeed
                primitive.state.slots[index].height[3] = layer.shadeFlag
            }
        }
    }

    // MARK: - EF_INFRAREDSCAN (794)

    /// Spawns primitive `135` sweeping electric jitter arcs for `EF_INFRAREDSCAN` (794).
    private func electricFan(fade: Int16, context: EffectTickContext) {
        guard stateCnt == 0 else {
            return
        }

        let texturePath = "effect\\elec1.tga"
        _ = context.assets?.texture(atPath: texturePath)

        let primitive = launchPrimitive(135)
        primitive.state.renderFlag = EffectPrimitiveState.RenderFlag.alpha | EffectPrimitiveState.RenderFlag.customBlend
        primitive.state.duration = duration
        primitive.state.totalTexture = 1
        primitive.state.texturePaths = [texturePath]
        primitive.state.size = 0

        let facingDegrees = (targetObjectID ?? ownerObjectID)
            .flatMap { context.world.targetState(for: $0)?.facingAngle } ?? 0
        var initialAngle = Int16(Int(facingDegrees) - 90)
        if initialAngle < 0 {
            initialAngle += 360
        }

        for index in 0..<4 {
            primitive.state.slots[index].life = 1
            primitive.state.slots[index].process = 0
            primitive.state.slots[index].maxHeight = 0.1
            primitive.state.slots[index].alphaB = index == 0 ? 250 : Int16(140 - index * 30)
            primitive.state.slots[index].riseAngle = initialAngle
            primitive.state.slots[index].distance = 20.0
            primitive.state.slots[index].height[0] = 0
            primitive.state.slots[index].vecTNow.x = Float(Int.random(in: 0..<11)) * 0.01
            primitive.state.slots[index].vecBNow = SIMD3<Float>(position.x, position.y - 10.0, position.z)
            primitive.state.slots[index].vecTNow.y = 20.0
            for step in 1...20 {
                primitive.state.slots[index].height[step] = 0
                primitive.state.slots[index].flag1[step] = 0
            }
            primitive.state.slots[index].flag1[0] = 0
            primitive.state.slots[index].alphaT = fade
            primitive.state.slots[index].fullDisplayAngle = 0
        }
    }

    // MARK: - EF_PRIMECHARGE (882)

    /// Spawns primitive `159` inward-collapsing spiral blades for `EF_PRIMECHARGE` (882).
    private func texturedScatterSphere(texturePath: String, flag: Int8, context: EffectTickContext) {
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
    private func texturedSpiralFade(texturePath: String, context: EffectTickContext) {
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
