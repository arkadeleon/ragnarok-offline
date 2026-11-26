//
//  RagEffect+ProcessTexturedRings.swift
//  RagnarokEffects
//
//  Created by Leon Li on 2026/11/26.
//

import Foundation
import RagnarokCore
import simd

extension RagEffect {

    // MARK: - EF_BEGINSPELL (12)

    /// Spawns four orbiting casting arc slots (`30`) for `EF_BEGINSPELL` (12).
    func texturedQuadRingSized(baseAlpha: Int16, texturePath: String, kind: Int, context: EffectTickContext) {
        guard stateCnt == 0 else {
            return
        }

        if duration < 56 {
            duration = 56
        }

        _ = context.assets?.texture(atPath: texturePath)

        let primitive = launchPrimitive(30)
        primitive.state.renderFlag = EffectPrimitiveState.RenderFlag.alpha | EffectPrimitiveState.RenderFlag.customBlend
        primitive.state.duration = duration
        primitive.state.texturePaths = [texturePath]

        let sizeByKind: [Int: Float] = [
            1: 8.0, 2: 5.0, 3: 10.0, 4: 11.0, 5: 4.0, 6: 12.0, 15: 7.0,
            20: 24.0, 21: 25.0, 22: 26.0, 23: 27.0, 31: 31.0,
            42: 42.0, 43: 43.0, 44: 44.0, 45: 45.0, 46: 46.0, 47: 47.0, 48: 48.0, 49: 49.0, 50: 50.0,
        ]
        primitive.state.size = sizeByKind[kind] ?? 5.0

        let baseMaxHeight: Float = switch kind {
        case 2: 25.0
        case 22: 15.0
        default: 20.0
        }
        let rotStarts: [Int16] = [180, 270, 0, 90]
        let alphaOffsets: [Int16] = [135, 90, 45, 0]

        for index in 0..<4 {
            primitive.state.slots[index].life = 1
            primitive.state.slots[index].process = duration <= 60 ? index * -5 : 0
            primitive.state.slots[index].fullDisplayAngle = 360
            primitive.state.slots[index].maxHeight = baseMaxHeight - Float(index)
            primitive.state.slots[index].rotStart = rotStarts[index]
            primitive.state.slots[index].alphaB = duration <= 60 ? 0 : baseAlpha + alphaOffsets[index]
            primitive.state.slots[index].distance = 4.1
            primitive.state.slots[index].riseAngle = 80
            primitive.state.slots[index].alphaT = Int16(truncatingIfNeeded: kind)
            primitive.state.slots[index].vecBNow.y = 0
            primitive.state.slots[index].height = Array(repeating: 0, count: 21)
            primitive.state.slots[index].flag1 = Array(repeating: 0, count: 21)
        }
    }

    // MARK: - EF_DETECTING (119)

    /// Spawns rising expanding glow panel (`PP_3DTEXTURE` (15)) and aura sound for `EF_DETECTING` (119).
    func texturedSkillAura(type: Int, context: EffectTickContext) {
        guard stateCnt == 0 else {
            return
        }

        let soundByType: [Int: String] = [
            0: "effect\\hunter_detecting.wav",
            2: "effect\\priest_benedictio.wav",
            4: "effect\\cru_grand cross.wav",
            5: "effect\\ANALYZE.wav",
        ]
        if let soundName = soundByType[type] {
            context.world.playSound(
                named: soundName,
                atWorldPosition: EffectSpace.toWorldPosition(position),
                delay: 0
            )
        }

        let texturePath = "effect\\fashasha.tga"
        _ = context.assets?.texture(atPath: texturePath)

        let primitive = launchPrimitive(.pp_3dtexture)
        primitive.state.duration = 57
        primitive.state.widthSpeed = 1.5
        primitive.state.heightSpeed = 1.5
        primitive.state.widthAccel = primitive.state.widthSpeed / 14.0
        primitive.state.heightAccel = primitive.state.heightSpeed / 14.0
        primitive.state.speed3d.y = -0.5
        primitive.state.roll = 90.0

        if type == 3 || type == 6 {
            primitive.state.changePoint = 10
            primitive.state.fadeOutCnt = 30
        } else {
            primitive.state.changePoint = 17
            primitive.state.fadeOutCnt = 40
        }

        switch type {
        case 4:
            primitive.state.red = 0xFF
            primitive.state.green = 0x8C
            primitive.state.blue = 0x8C
        case 5:
            primitive.state.red = 0xD2
            primitive.state.green = 0xFA
            primitive.state.blue = 0xD2
        case 6:
            primitive.state.red = 10
            primitive.state.green = 10
            primitive.state.blue = 10
        case 7:
            primitive.state.red = 0xFA
            primitive.state.green = 0xD2
            primitive.state.blue = 0x8C
        case 8:
            primitive.state.red = 0x8C
            primitive.state.green = 0xFF
            primitive.state.blue = 0x8C
        default:
            break
        }

        primitive.state.changeWidthSpeed = 0.1
        primitive.state.changeHeightSpeed = 0.1
        primitive.state.changeWidthAccel = primitive.state.changeWidthSpeed / 30.0
        primitive.state.changeHeightAccel = primitive.state.changeHeightSpeed / 30.0
        primitive.state.deltaPos2.y = -5.0
        primitive.state.texturePaths = [texturePath]
    }

    // MARK: - EF_LEVEL99_2 (201)
    // CRagEffect::TexturedDoubleRing(const char* name, char level)

    // MARK: - EF_GANBANTEIN (223)
    // CRagEffect::TexturedCrossKind(const char* name, char level)

    // MARK: - EF_MAPPILLAR (231)
    // CRagEffect::TexturedCrossStaged(const char* name, char level)

    // MARK: - EF_BOTTOM_VO (239)
    // CRagEffect::TexturedFlare(const char* name, char size, float, float)

    // MARK: - EF_BOTTOM_LA (242)
    // CRagEffect::TexturedHalo(const char* name, char kind)

    // MARK: - EF_PROVIDENCE (248)
    // CRagEffect::TexturedCross(const char* name, char kind)

    // MARK: - EF_GUMGANG2 (261)
    // CRagEffect::TexturedCrossLevel(const char* name, char level)

    // MARK: - EF_BOTTOM_DISSONANCE (277)

    /// Spawns `PP_BOTTOM2` (48) textured ground planes for `EF_BOTTOM_DISSONANCE` (277) and `EF_BOTTOM_ASSASSINCROSS` (287).
    func texturedMagicRing(texturePath: String, kind: Int8, context: EffectTickContext) {
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

    // MARK: - EF_BOTTOM_ETERNALCHAOS (280)
    // CRagEffect::TexturedGlow(const char* name, char size)

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

    // MARK: - EF_COUPLECASTING (342)
    // CRagEffect::TexturedSpellRings(const char* name)

    // MARK: - EF_LIGHTSPHERE (348)
    // CRagEffect::TexturedAura(const char* name, char kind)

    // MARK: - EF_PRESSURE (365)
    // CRagEffect::TexturedLevelRing(const char* name, int process, char level)

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

    // MARK: - EF_STORMKICK (435)
    // CRagEffect::TexturedMark(const char* name, char kind)

    // MARK: - EF_HALFSPHERE (436)
    // CRagEffect::TexturedPulse(const char* name)

    // MARK: - EF_BEGINASURA1 (467)
    // CRagEffect::TexturedSkillIcon(const char* name, std::int16_t level, std::int16_t mode)

    // MARK: - EF_BLACKDEVIL (487)
    // CRagEffect::TexturedRisingRing(const char* name)

    // MARK: - EF_GI_EXPLOSION (514)
    // CRagEffect::TexturedCrossFade(const char* name)

    // MARK: - EF_ACIDDEMON (537)
    // CRagEffect::TexturedFireWall(const char* name, int unused)

    // MARK: - EF_SMA2 (552)
    // CRagEffect::TexturedBlueRing(const char* name)

    // MARK: - EF_STIN5 (624)
    // CRagEffect::TexturedSlashCross(const char* name)

    // MARK: - EF_CIRCLELIGHT (703)
    // CRagEffect::TexturedBeams(const char* name, char flag)

    // MARK: - EF_GLASSWALL3 (754)
    // CRagEffect::TexturedRisingRingStages(const char* name, char level)

    // MARK: - EF_GTHUNDER (796)
    // CRagEffect::TexturedRisingPillar(const char* name, char)

    // MARK: - EF_TETRACASTING (805)
    // CRagEffect::TexturedQuadRing(std::int16_t baseAlpha, const char* name, char kind)

    // MARK: - EF_STRETCH (811)
    // CRagEffect::TexturedDescendingRings(const char* name, char flag)

    // MARK: - EF_CHEMICAL_V (854)
    // CRagEffect::TexturedBeam(char flag, const char* name)

    // MARK: - EF_CIRCLEPOWER2 (861)
    // CRagEffect::TexturedTwinkleRing(const char* name, char level)

    // MARK: - EF_GLASSWALL4 (883)
    // CRagEffect::TexturedColumn(const char* name, char kind)

    // MARK: - EF_BOTTOM_DE2 (939)
    // CRagEffect::TexturedGroundRing(const char* name, char flag, float unused1, float unused2)
}
