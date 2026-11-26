//
//  RagEffect+Process0300To0399.swift
//  RagnarokEffects
//
//  Created by Leon Li on 2026/11/26.
//

import Foundation
import RagnarokCore
import simd

extension RagEffect {
    nonisolated static let proceduralEffectIDs0300To0399: [EffectID] = [
        .ef_forestlight,
        .ef_firstaid,
        .ef_heal,
        .ef_bottom_mag,
        .ef_bottom_sanc,
        .ef_heal3,
        .ef_hitline,
        .ef_poison,
        .ef_guard,
        .ef_magnum2,
        .ef_saintwing,
        .ef_bottom_basilica,
        .ef_linelink2,
    ]

    func process0300To0399(context: EffectTickContext) -> Bool {
        switch effectID {
        case .ef_forestlight:
            forestLight(texturePath: "effect\\cloud11.tga", flag: 0, context: context)
        case .ef_firstaid:
            firstAid(context: context)
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
        case .ef_poison:
            poison(flag: 0, context: context)
        case .ef_guard:
            kyrieGuard(texturePath: "effect\\guardK.tga", kind: 0, context: context)
        case .ef_magnum2:
            magnum2(texturePath: "effect\\ring_yellow.tga", context: context)
        case .ef_saintwing:
            saintWing(texturePath: "effect\\wing003.bmp", context: context)
        case .ef_bottom_basilica:
            texturedFourRing(texturePath: "effect\\alpha_down.tga", kind: 0, context: context)
            texturedFourRing(texturePath: "effect\\alpha_down.tga", kind: 1, context: context)
        case .ef_linelink2:
            if stateCnt == 0 {
                context.world.playSound(
                    named: K2L("effect\\소울 체인지.wav"),
                    atWorldPosition: EffectSpace.toWorldPosition(position),
                    delay: 0
                )
            }
            trackTarget(context: context)
        default:
            return false
        }
        return true
    }

    // MARK: - EF_FORESTLIGHT (307)

    /// Spawns slanted pentagonal light shafts (`PP_FOREST` (66)) for `EF_FORESTLIGHT` (307).
    func forestLight(texturePath: String, flag: Int8, context: EffectTickContext) {
        guard stateCnt == 0 else {
            return
        }

        _ = context.assets?.texture(atPath: texturePath)

        let primitive = launchPrimitive(.pp_forest)
        primitive.state.renderFlag = EffectPrimitiveState.RenderFlag.alpha | EffectPrimitiveState.RenderFlag.customBlend
        primitive.state.duration = duration
        primitive.state.texturePaths = [texturePath]

        let topOffset: SIMD3<Float> = flag == 10
            ? SIMD3<Float>(-15.0, -60.0, -15.0)
            : SIMD3<Float>(-70.0, -300.0, -70.0)
        let topPos = position + topOffset
        deltaPos = topPos

        for i in 0..<4 {
            primitive.state.slots[i].life = 1
            primitive.state.slots[i].process = i == 3 ? 180 : 0
            primitive.state.slots[i].alphaB = if flag == 2 || flag == 12 || flag == 13 {
                30
            } else if flag == 10 {
                25
            } else if flag == 11 {
                0
            } else {
                40
            }
            primitive.state.slots[i].distance = 0

            let radius: Float = if i == 3 {
                if flag == 1 || flag == 11 {
                    4.0
                } else if flag == 2 || flag == 12 || flag == 13 {
                    1.0
                } else {
                    2.0
                }
            } else if flag == 1 || flag == 11 {
                Float(i * 2) + 4.0
            } else if flag == 2 || flag == 12 || flag == 13 {
                Float(i) * 0.5 + 1.0
            } else {
                Float(i) + 2.0
            }

            primitive.state.slots[i].maxHeight = radius
            primitive.state.slots[i].height[0] = radius
            primitive.state.slots[i].rotStart = Int16(i * 25)
            primitive.state.slots[i].vecTNow = position
            primitive.state.slots[i].vecTPre = topPos
            primitive.state.slots[i].flag1[0] = flag
        }
    }

    // MARK: - EF_FIRSTAID (309)

    /// Spawns `PP_FIRSTAID` (58) pulsing glow panel for `EF_FIRSTAID` (309).
    func firstAid(context: EffectTickContext) {
        guard stateCnt == 0 else {
            return
        }

        context.world.playSound(
            named: "_heal_effect.wav",
            atWorldPosition: EffectSpace.toWorldPosition(position),
            delay: 0
        )

        let texturePath = "effect\\pikapika2.bmp"
        _ = context.assets?.texture(atPath: texturePath)

        let primitive = launchPrimitive(.pp_firstaid)
        primitive.state.renderFlag = EffectPrimitiveState.RenderFlag.alpha | EffectPrimitiveState.RenderFlag.customBlend
        primitive.state.duration = duration
        primitive.state.totalTexture = 1
        primitive.state.texturePaths = [texturePath]
        primitive.state.size = 0
        primitive.state.slots[0].life = 1
        primitive.state.slots[0].process = 0
        primitive.state.slots[0].distance = 10.0
        primitive.state.slots[0].alphaB = 0
        primitive.state.slots[0].vecBNow = SIMD3<Float>(position.x, position.y - 12.0, position.z)
        primitive.state.slots[0].height[6] = 0.02
        primitive.state.slots[0].fullDisplayAngle = Int16(Int.random(in: 0..<360))
        primitive.state.slots[0].flag1[0] = 0
        primitive.state.slots[0].flag1[2] = 1
        primitive.state.slots[0].height[8] = Float(Int.random(in: 0..<360))
        for i in 1..<4 {
            primitive.state.slots[i].life = 0
            primitive.state.slots[i].alphaB = 0
        }
    }

    // MARK: - EF_HEAL (312)

    /// Spawns pulsing casting columns (`60`) and rising particles (`PP_PARTICLE_UP` (59)) for `EF_HEAL` (312) and `EF_HEAL3` (320).
    func healBurst(texturePath: String, flag: Int8, context: EffectTickContext) {
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

    // MARK: - EF_BOTTOM_MAG (318)

    /// Spawns `PP_RECT_UP` (64) rising pulse columns for `EF_BOTTOM_MAG` (318), `EF_BOTTOM_SANC` (319), and `EF_BOTTOM_FOGWALL` (405).
    func texturedPulseKind(texturePath: String, kind: Int8, context: EffectTickContext) {
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
    func whiteSparks(kind: Int16, context: EffectTickContext) {
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

    // MARK: - EF_POISON (335)

    /// Spawns primitive `72` tiled poison mist overlay for `EF_POISON` (335).
    func poison(flag: Int8, context: EffectTickContext) {
        if stateCnt == 99_999_998 {
            stateCnt = 0
            duration = 99_999_999
        } else if stateCnt != 0 {
            return
        }

        let texturePath = flag == 0 ? "effect\\poison_f.bmp" : "effect\\white02.bmp"
        _ = context.assets?.texture(atPath: texturePath)

        let primitive = launchPrimitive(72)
        primitive.state.renderFlag |= 0x200
        primitive.state.duration = duration
        primitive.state.totalTexture = 1
        primitive.state.texturePaths = [texturePath]
        position.y -= 9.0
        for i in 0..<4 {
            primitive.state.slots[i].life = 0
        }
        primitive.state.slots[0].life = 1
        primitive.state.slots[0].process = 0
        primitive.state.slots[0].distance = 30.0
        primitive.state.slots[0].maxHeight = 0
        primitive.state.slots[0].alphaB = 0
        primitive.state.slots[0].flag1[10] = flag
    }

    // MARK: - EF_GUARD (336)

    /// Spawns `PP_GUARD` (61) sphere cage and plays the guard sound for `EF_GUARD` (336).
    func kyrieGuard(texturePath: String, kind: Int8, context: EffectTickContext) {
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
    func magnum2(texturePath: String, context: EffectTickContext) {
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

    // MARK: - EF_SAINTWING (345)

    /// Spawns `PP_SAINTWING` (76) paired flapping angel wings for `EF_SAINTWING` (362).
    func saintWing(texturePath: String, context: EffectTickContext) {
        guard stateCnt == 0 else {
            return
        }

        _ = context.assets?.texture(atPath: texturePath)

        let primitive = launchPrimitive(.pp_saintwing)
        primitive.state.renderFlag = EffectPrimitiveState.RenderFlag.alpha | EffectPrimitiveState.RenderFlag.customBlend
        primitive.state.duration = duration
        primitive.state.totalTexture = 1
        primitive.state.texturePaths = [texturePath]
        primitive.state.size = 4.0
        primitive.state.slots[2].life = 0
        primitive.state.slots[3].life = 0
        for i in 0..<2 {
            primitive.state.slots[i].life = 1
            primitive.state.slots[i].process = 0
            primitive.state.slots[i].maxHeight = 10.0
            primitive.state.slots[i].distance = 2.0
            primitive.state.slots[i].height[0] = -8.0
            primitive.state.slots[i].rotStart = 0
            primitive.state.slots[i].fullDisplayAngle = 0
            primitive.state.slots[i].alphaB = 200
            primitive.state.slots[i].riseAngle = 0
        }
    }

    // MARK: - EF_BOTTOM_BASILICA (374)

    /// Spawns `PP_RECT_UP2` (90) four-ring perimeter boxes for `EF_BOTTOM_BASILICA` (374).
    func texturedFourRing(texturePath: String, kind: Int8, context: EffectTickContext) {
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
    func trackTarget(context: EffectTickContext) {
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
}
