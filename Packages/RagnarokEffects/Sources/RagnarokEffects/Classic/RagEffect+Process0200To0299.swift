//
//  RagEffect+Process0200To0299.swift
//  RagnarokEffects
//
//  Created by Leon Li on 2026/11/26.
//

import Foundation
import RagnarokCore
import simd

extension RagEffect {
    nonisolated static let proceduralEffectIDs0200To0299: [EffectID] = [
        .ef_level99,
        .ef_level99_2,
        .ef_level99_3,
        .ef_gumgang,
        .ef_darkbreath,
        .ef_summonslave,
        .ef_blooddrain,
        .ef_energydrain,
        .ef_potion_con,
        .ef_potion_,
        .ef_potion_berserk,
        .ef_potionpillar,
        .ef_defender,
        .ef_ganbantein,
        .ef_wind,
        .ef_volcano,
        .ef_grandcross,
        .ef_intimidate,
        .ef_chookgi,
        .ef_cloud,
        .ef_cloud2,
        .ef_mappillar,
        .ef_linelink,
        .ef_cloud3,
        .ef_deluge,
        .ef_violentgale,
        .ef_landprotector,
        .ef_bottom_vo,
        .ef_bottom_de,
        .ef_bottom_vi,
        .ef_bottom_la,
        .ef_magicrod,
        .ef_mappillar2,
        .ef_providence,
        .ef_shieldboomerang,
        .ef_spearquicken,
        .ef_reflectshield,
        .ef_absorbspirits,
        .ef_steelbody,
        .ef_mappillar3,
        .ef_mappillar4,
        .ef_gumgang2,
        .ef_teihit1,
        .ef_gumgang3,
        .ef_teihit2,
        .ef_tanji,
        .ef_teihit1x,
        .ef_chimto,
        .ef_rg_coin,
        .ef_backstap,
        .ef_teihit3,
        .ef_bottom_dissonance,
        .ef_bottom_lullaby,
        .ef_bottom_richmankim,
        .ef_bottom_eternalchaos,
        .ef_bottom_drumbattlefield,
        .ef_bottom_ringnibelungen,
        .ef_bottom_rokisweil,
        .ef_bottom_intoabyss,
        .ef_bottom_siegfried,
        .ef_bottom_whistle,
        .ef_bottom_assassincross,
        .ef_bottom_poembragi,
        .ef_bottom_appleidun,
        .ef_bottom_uglydance,
        .ef_bottom_humming,
        .ef_bottom_dontforgetme,
        .ef_bottom_fortunekiss,
        .ef_bottom_serviceforyou,
        .ef_talk_frostjoke,
        .ef_talk_scream,
        .ef_pokjuk,
        .ef_throwitem,
        .ef_throwitem2,
    ]

    func process0200To0299(context: EffectTickContext) -> Bool {
        switch effectID {
        case .ef_level99:
            tripleRingStack(texturePath: "effect\\ring_blue.tga", large: 0, context: context)
        case .ef_level99_2:
            texturedDoubleRing(texturePath: "effect\\pikapika2.bmp", level: 0, context: context)
        case .ef_level99_3:
            freezingCircle(kind: 0, context: context)
        case .ef_gumgang:
            superSlashFan(count: 1, value: 0, context: context)
        case .ef_darkbreath:
            processDarkBreath(context: context)
        case .ef_summonslave:
            alphaCenterRise(context: context)
        case .ef_blooddrain:
            redParticleSpray(count: 3, context: context)
        case .ef_energydrain:
            bloodDrain(context: context)
        case .ef_potion_con:
            return processPotionCon(context: context)
        case .ef_potion_:
            return processPotionAwakening(context: context)
        case .ef_potion_berserk:
            return potionBerserk(context: context)
        case .ef_potionpillar:
            potionPillar(heightSpeed: 1.0, pillarDuration: 50, context: context)
        case .ef_defender:
            quadRingStack(texturePath: "effect\\ring_black.tga", context: context)
        case .ef_ganbantein:
            texturedCrossKind(texturePath: "effect\\ring_white.tga", level: 2, context: context)
        case .ef_wind:
            healCloudRings(context: context)
        case .ef_volcano:
            texturedCrossKind(texturePath: "effect\\ring_red.tga", level: 0, context: context)
        case .ef_grandcross:
            grandCrossRings(angle: 0, kind: 0, context: context)
            grandCross2(flag: 0, context: context)
        case .ef_intimidate:
            if stateCnt == 0 {
                context.world.playSound(
                    named: "effect\\EF_Bash.wav",
                    atWorldPosition: EffectSpace.toWorldPosition(position),
                    delay: 0
                )
            }
            if stateCnt == 35 {
                context.world.playSound(
                    named: "effect\\rog_intimidate.wav",
                    atWorldPosition: EffectSpace.toWorldPosition(position),
                    delay: 0
                )
            }
            for _ in 0..<20 {
                whiteSpray(kind: 0, context: context)
            }
        case .ef_chookgi:
            elementalOrbit(kind: 0, context: context)
        case .ef_cloud:
            for _ in 0..<40 {
                skyCloud(kind: 0, context: context)
            }
        case .ef_cloud2:
            for _ in 0..<60 {
                skyCloud(kind: 1, context: context)
            }
        case .ef_mappillar:
            texturedCrossStaged(texturePath: "effect\\ring_blue.tga", level: 0, context: context)
        case .ef_linelink:
            trackCloud(kind: 0, context: context)
        case .ef_cloud3:
            for _ in 0..<40 {
                skyCloud(kind: 2, context: context)
            }
        case .ef_deluge:
            texturedCrossKind(texturePath: "effect\\ring_blue.tga", level: 0, context: context)
        case .ef_violentgale:
            texturedCrossKind(texturePath: "effect\\magic_green.tga", level: 0, context: context)
        case .ef_landprotector:
            texturedCrossKind(texturePath: "effect\\ring_white.tga", level: 0, context: context)
        case .ef_bottom_vo:
            texturedFlare(texturePath: "effect\\ring_red.tga", size: 0, offsetX: 0, offsetZ: 0, context: context)
        case .ef_bottom_de:
            texturedFlare(texturePath: "effect\\ring_blue.tga", size: 0, offsetX: 0, offsetZ: 0, context: context)
        case .ef_bottom_vi:
            texturedFlare(texturePath: "effect\\magic_green.tga", size: 0, offsetX: 0, offsetZ: 0, context: context)
        case .ef_bottom_la:
            texturedHalo(texturePath: "effect\\aaa copy.bmp", kind: 1, context: context)
        case .ef_magicrod:
            if stateCnt == 0 {
                configureSTR(path: K2L("매직로드.str"))
            }
            _ = processEZ2STRRaised(context: context)
            sageMagicRod(context: context)
        case .ef_mappillar2:
            texturedCrossStaged(texturePath: "effect\\ring_blue.tga", level: 1, context: context)
        case .ef_providence:
            if stateCnt == 0 {
                configureSTR(path: "providence.str")
            }
            texturedCross(texturePath: "effect\\ring_yellow.tga", kind: 0, context: context)
            return processEZ2STRRaised(context: context)
        case .ef_shieldboomerang:
            texturedShieldThrow(texturePath: "effect\\shield_boomerang.bmp", context: context)
        case .ef_spearquicken:
            return twoHandQuicken(context: context)
        case .ef_reflectshield:
            quadRingStack(texturePath: "effect\\ring_yellow.tga", context: context)
        case .ef_absorbspirits:
            if stateCnt == 0 {
                context.world.playSound(
                    named: K2L("effect\\흡기.wav"),
                    atWorldPosition: EffectSpace.toWorldPosition(position),
                    delay: 0
                )
            }
            healRingSparkle(texturePath: "effect\\ring_blue.tga", type: 2, context: context)
        case .ef_steelbody:
            superSlashFan(count: 4, value: 0, context: context)
        case .ef_mappillar3:
            texturedCrossStaged(texturePath: "effect\\magic_green.tga", level: 2, context: context)
        case .ef_mappillar4:
            texturedCrossStaged(texturePath: "effect\\ring_red.tga", level: 3, context: context)
        case .ef_gumgang2:
            texturedCrossLevel(texturePath: "effect\\ring_yellow.tga", level: 0, context: context)
        case .ef_teihit1:
            for _ in 0..<20 {
                texturedScatter(texturePath: "effect\\alpha_center.tga", flag: 0, context: context)
            }
        case .ef_gumgang3:
            texturedCrossKind(texturePath: "effect\\ring_yellow.tga", level: 1, context: context)
        case .ef_teihit2:
            for _ in 0..<5 {
                teiHit2(context: context)
            }
        case .ef_tanji:
            tanji(context: context)
        case .ef_teihit1x:
            for _ in 0..<24 {
                texturedScatter(texturePath: "effect\\lens1.tga", flag: 1, context: context)
            }
        case .ef_chimto:
            chimto(flag: 0, context: context)
        case .ef_rg_coin:
            if stateCnt == 0 {
                context.world.playSound(
                    named: "effect\\rog_steal coin.wav",
                    atWorldPosition: EffectSpace.toWorldPosition(position),
                    delay: 0
                )
            }
            for _ in 0..<30 {
                texturedSpray(texturePath: "effect\\coin_a.bmp", context: context)
            }
        case .ef_backstap:
            if stateCnt == 20 {
                context.world.playSound(
                    named: "effect\\rog_back stap.wav",
                    atWorldPosition: EffectSpace.toWorldPosition(position),
                    delay: 0
                )
            }
            for _ in 0..<20 {
                teiHit2(context: context)
            }
        case .ef_teihit3:
            for _ in 0..<20 {
                texturedScatterLow(texturePath: "effect\\lens2.tga", flag: 2, context: context)
            }
        case .ef_bottom_dissonance:
            texturedMagicRing(texturePath: "effect\\ring_blue.tga", kind: 0, context: context)
        case .ef_bottom_lullaby:
            bottomMusic(texturePath: "effect\\zz.bmp", kind: 1, context: context)
        case .ef_bottom_richmankim:
            bottomMusic(texturePath: "effect\\pocket.bmp", kind: 3, context: context)
        case .ef_bottom_eternalchaos:
            texturedGlow(texturePath: "effect\\twirl.bmp", size: 8, context: context)
        case .ef_bottom_drumbattlefield:
            bottomMusic(texturePath: "", kind: 2, context: context)
        case .ef_bottom_ringnibelungen:
            bottomMusic(texturePath: "effect\\twirl.bmp", kind: 7, context: context)
        case .ef_bottom_rokisweil:
            bottomOut(texturePath: "effect\\safeline.bmp", kind: 0, context: context)
        case .ef_bottom_intoabyss:
            bottomMusic(texturePath: "", kind: 5, context: context)
        case .ef_bottom_siegfried:
            texturedGlow(texturePath: "effect\\twirl.bmp", size: 4, context: context)
        case .ef_bottom_whistle:
            bottomMusic(texturePath: "effect\\melody_b.bmp", kind: 0, context: context)
        case .ef_bottom_assassincross:
            texturedMagicRing(texturePath: "effect\\ring_red.tga", kind: 1, context: context)
        case .ef_bottom_poembragi:
            bottomMusic(texturePath: "", kind: 8, context: context)
        case .ef_bottom_appleidun:
            bottomMusic(texturePath: "effect\\idun_apple.bmp", kind: 6, context: context)
        case .ef_bottom_uglydance:
            texturedMagicRing(texturePath: "effect\\ring_red.tga", kind: 0, context: context)
        case .ef_bottom_humming:
            bottomMusic(texturePath: "effect\\melody_a.bmp", kind: 0, context: context)
        case .ef_bottom_dontforgetme:
            texturedMagicRing(texturePath: "effect\\magic_green.tga", kind: 2, context: context)
        case .ef_bottom_fortunekiss:
            bottomMusic(texturePath: "effect\\kiss.bmp", kind: 4, context: context)
        case .ef_bottom_serviceforyou:
            texturedMagicRing(texturePath: "effect\\safeline.bmp", kind: 4, context: context)
        case .ef_talk_frostjoke, .ef_talk_scream:
            break
        case .ef_pokjuk:
            pokBurst(context: context)
        case .ef_throwitem:
            throwItem(texturePath: K2L("유저인터페이스\\item\\빈병.bmp"), kind: 0, context: context)
        case .ef_throwitem2:
            throwItem(texturePath: K2L("유저인터페이스\\item\\빈포션병.bmp"), kind: 1, context: context)
        default:
            return false
        }
        return true
    }

    // MARK: - EF_LEVEL99 (200)

    /// Spawns 3-layer Level 99 aura ribbons (`PP_3DCASTING` (23)) for `EF_LEVEL99` (200).
    func tripleRingStack(texturePath: String, large: Int8, context: EffectTickContext) {
        if stateCnt == 99_999_998 {
            stateCnt = 0
            duration = 99_999_999
        } else if stateCnt != 0 {
            return
        }

        _ = context.assets?.texture(atPath: texturePath)

        let primitive = launchPrimitive(.pp_3dcasting)
        primitive.state.renderFlag = EffectPrimitiveState.RenderFlag.alpha | EffectPrimitiveState.RenderFlag.customBlend
        primitive.state.duration = duration
        primitive.state.texturePaths = [texturePath]
        primitive.state.size = large == 1 ? 7.0 : 4.0

        let configs: [(maxHeight: Float, rotStart: Int16, distance: Float, riseAngle: Int16)] = [
            (15.0, 0, 3.9, 55),
            (13.0, 90, 4.1, 50),
            (11.0, 180, 4.3, 45),
        ]

        for (index, config) in configs.enumerated() {
            primitive.state.slots[index].life = 1
            primitive.state.slots[index].process = 0
            primitive.state.slots[index].fullDisplayAngle = 315
            primitive.state.slots[index].maxHeight = config.maxHeight
            primitive.state.slots[index].rotStart = config.rotStart
            primitive.state.slots[index].alphaB = 120
            primitive.state.slots[index].distance = config.distance
            primitive.state.slots[index].riseAngle = config.riseAngle
            primitive.state.slots[index].vecBNow.y = 0
            primitive.state.slots[index].height = Array(repeating: 0, count: 21)
            primitive.state.slots[index].flag1 = Array(repeating: 0, count: 21)
        }
        primitive.state.slots[3].life = 0
    }

    // MARK: - EF_LEVEL99_2 (201)

    /// Spawns dual rotating Level 99 rings (`28`) for `EF_LEVEL99_2` (201).
    func texturedDoubleRing(texturePath: String, level: Int8, context: EffectTickContext) {
        if stateCnt == 99_999_998 {
            stateCnt = 0
            duration = 99_999_999
        } else if stateCnt != 0 {
            return
        }

        _ = context.assets?.texture(atPath: texturePath)

        let primitive = launchPrimitive(28)
        primitive.state.renderFlag = EffectPrimitiveState.RenderFlag.alpha
            | EffectPrimitiveState.RenderFlag.customBlend
            | EffectPrimitiveState.RenderFlag.topmost
        primitive.state.duration = duration
        primitive.state.texturePaths = [texturePath]
        primitive.state.size = switch level {
        case 1: 15.0
        case 2: 17.0
        case 3: 18.0
        default: 4.0
        }

        let distance: Float = level == 3 ? 24.0 : 15.0
        primitive.state.slots[0].life = 1
        primitive.state.slots[1].life = 1
        primitive.state.slots[2].life = 0
        primitive.state.slots[3].life = 0
        primitive.state.slots[0].distance = distance
        primitive.state.slots[1].distance = distance
        primitive.state.slots[0].riseAngle = 0
        primitive.state.slots[1].riseAngle = 180
        primitive.state.slots[0].alphaB = 200
        primitive.state.slots[1].alphaB = 200
        primitive.state.slots[0].height[0] = -1.0
        primitive.state.slots[1].height[0] = -1.0
    }

    // MARK: - EF_LEVEL99_3 (202)

    /// Spawns multi-slot orbital Level 99 mist ribbons (`29`) for `EF_LEVEL99_3` (202).
    func freezingCircle(kind: Int8, context: EffectTickContext) {
        if stateCnt == 99_999_998 {
            stateCnt = 0
            duration = 99_999_999
        } else if stateCnt != 0 {
            return
        }

        let texturePath: String
        let size: Float
        if kind == 3 {
            texturePath = "effect\\ghost.bmp"
            size = 0
        } else if kind >= 1 {
            texturePath = "effect\\whitelight.tga"
            size = kind == 2 ? 7.0 : 0
        } else {
            texturePath = "effect\\freezing_circle.bmp"
            size = 0
        }
        _ = context.assets?.texture(atPath: texturePath)

        let primitive = launchPrimitive(29)
        primitive.state.renderFlag = EffectPrimitiveState.RenderFlag.alpha | EffectPrimitiveState.RenderFlag.customBlend
        primitive.state.duration = duration
        primitive.state.texturePaths = [texturePath]
        primitive.state.size = size

        for i in 0..<4 {
            if kind == 3 && i >= 1 {
                primitive.state.slots[i].life = 0
            } else if (kind == 7 || kind == 8) && i >= 2 {
                primitive.state.slots[i].life = 0
            } else {
                primitive.state.slots[i].life = 1
            }

            primitive.state.slots[i].maxHeight = 0.15
            if kind == 1 || kind == 4 || kind == 5 || kind == 6 || kind >= 8 {
                primitive.state.slots[i].distance = 2.4
            } else if kind == 3 {
                primitive.state.slots[i].distance = 3.2
                primitive.state.slots[i].maxHeight = 0.6
            } else {
                primitive.state.slots[i].distance = 0.8
            }

            func randomAnchorXZ() -> (x: Float, z: Float) {
                if kind == 3 {
                    return (Float(Int.random(in: 0..<15) - 8), Float(Int.random(in: 0..<15) - 8))
                } else if kind == 6 {
                    return (Float(Int.random(in: 0..<35) - 17), 0)
                }
                return (0, 0)
            }

            let bPre = randomAnchorXZ()
            primitive.state.slots[i].vecBPre = SIMD3<Float>(bPre.x, Float(Int.random(in: 0..<100)), bPre.z)
            let bNow = randomAnchorXZ()
            primitive.state.slots[i].vecBNow = SIMD3<Float>(bNow.x, Float(Int.random(in: 0..<100)), bNow.z)
            let tPre = randomAnchorXZ()
            primitive.state.slots[i].vecTPre = SIMD3<Float>(tPre.x, Float(Int.random(in: 0..<100)), tPre.z)
            let tNow = randomAnchorXZ()
            primitive.state.slots[i].vecTNow = SIMD3<Float>(tNow.x, Float(Int.random(in: 0..<100)), tNow.z)

            for h in 0..<16 {
                primitive.state.slots[i].height[h] = Float(Int.random(in: 0..<360))
            }

            if kind == 4 {
                primitive.state.slots[i].vecBPre.y = -40.0
                primitive.state.slots[i].vecBNow.y = -50.0
                primitive.state.slots[i].vecTPre.y = -60.0
                primitive.state.slots[i].vecTNow.y = -70.0
            } else if kind == 5 || kind == 7 {
                primitive.state.slots[i].vecBPre.y = 0
                primitive.state.slots[i].vecBNow.y = 0
                primitive.state.slots[i].vecTPre.y = 0
                primitive.state.slots[i].vecTNow.y = 0
            } else if kind == 6 {
                primitive.state.slots[i].vecBPre.y = Float(-40 - Int.random(in: 0..<40))
                primitive.state.slots[i].vecBNow.y = Float(-40 - Int.random(in: 0..<40))
                primitive.state.slots[i].vecTPre.y = Float(-40 - Int.random(in: 0..<40))
                primitive.state.slots[i].vecTNow.y = Float(-40 - Int.random(in: 0..<40))
            }

            if kind == 1 {
                primitive.state.slots[i].flag1[0] = kind
            } else if kind == 3 {
                primitive.state.slots[i].flag1[0] = 11
            } else if kind == 4 {
                primitive.state.slots[i].flag1[0] = 14
            } else if kind == 5 || kind == 7 || kind == 8 {
                primitive.state.slots[i].flag1[0] = 15
                primitive.state.slots[i].flag1[1] = 0
                primitive.state.slots[i].flag1[2] = 0
                primitive.state.slots[i].flag1[3] = 0
                primitive.state.slots[i].flag1[4] = 0
                primitive.state.slots[i].flag1[5] = kind
            } else if kind == 6 {
                primitive.state.slots[i].flag1[0] = 16
            } else {
                primitive.state.slots[i].flag1[0] = 0
            }
        }
    }

    // MARK: - EF_GUMGANG (203)

    /// Spawns sweeping aura fan streaks (`35`) for `EF_GUMGANG` (203).
    func superSlashFan(count: Int8, value: Int8, context: EffectTickContext) {
        guard stateCnt == 0 else {
            return
        }

        let texturePaths = (1...5).map { "effect\\super\($0).bmp" }
        for path in texturePaths {
            _ = context.assets?.texture(atPath: path)
        }

        let fan = launchPrimitive(35)
        fan.state.renderFlag = EffectPrimitiveState.RenderFlag.alpha | EffectPrimitiveState.RenderFlag.customBlend
        fan.state.duration = duration
        fan.state.totalTexture = 5
        fan.state.texturePaths = texturePaths
        for i in 0..<4 {
            fan.state.slots[i].life = 0
        }

        for i in 0..<max(0, Int(count)) where i < 4 {
            fan.state.slots[i].life = 1
            fan.state.slots[i].distance = 3.5
            fan.state.slots[i].vecBPre.y = -Float(Int.random(in: 0..<10))
            fan.state.slots[i].height[0] = 10.0
            fan.state.slots[i].height[1] = 70.0
            fan.state.slots[i].height[2] = Float(Int.random(in: 0..<5))
            fan.state.slots[i].height[3] = Float(Int.random(in: 0..<360))
            fan.state.slots[i].vecBNow.y = -Float(Int.random(in: 0..<10))
            fan.state.slots[i].height[4] = 10.0
            fan.state.slots[i].height[5] = 130.0
            fan.state.slots[i].height[6] = Float(Int.random(in: 0..<5))
            fan.state.slots[i].height[7] = Float(Int.random(in: 0..<360))
            fan.state.slots[i].vecTPre.y = -Float(Int.random(in: 0..<10))
            fan.state.slots[i].height[8] = 10.0
            fan.state.slots[i].height[9] = 190.0
            fan.state.slots[i].height[10] = Float(Int.random(in: 0..<5))
            fan.state.slots[i].height[11] = Float(Int.random(in: 0..<360))
            fan.state.slots[i].vecTNow.y = -Float(Int.random(in: 0..<10))
            fan.state.slots[i].height[12] = 10.0
            fan.state.slots[i].height[13] = 250.0
            fan.state.slots[i].height[14] = Float(Int.random(in: 0..<5))
            fan.state.slots[i].height[15] = Float(Int.random(in: 0..<360))
            fan.state.slots[i].flag1[4] = value
        }
    }

    // MARK: - EF_SUMMONSLAVE (215)

    /// Spawns 20 rising 2D light rays (`PP_2DFLASH` (3)) for `EF_SUMMONSLAVE` (215).
    func alphaCenterRise(context: EffectTickContext) {
        guard stateCnt == 0 else {
            return
        }

        let texturePath = "EFFECT\\alpha_center.tga"
        _ = context.assets?.texture(atPath: texturePath)

        for _ in 0..<20 {
            let flash = launchPrimitive(.pp_2dflash)
            flash.state.duration = 40
            flash.state.deltaPos2.y = -40.0
            flash.state.longitude = Float(Int.random(in: 0..<360))
            flash.state.longSpeed = Float(Int.random(in: 0..<60) + 10) / 10.0
            flash.state.longAccel = -(flash.state.longSpeed / Float(flash.state.duration)) / 1.5
            flash.state.arcAngle = Float(Int.random(in: 0..<25) + 5) / 10.0
            flash.state.heightSize = Float(Int.random(in: 0..<40) + 20)
            flash.state.heightSpeed = Float(Int.random(in: 0..<30) + 20) / 10.0
            flash.state.alpha = 0
            flash.state.maxAlpha = 200.0
            flash.state.alphaSpeed = flash.state.maxAlpha / 10.0
            flash.state.fadeOutCnt = flash.state.duration - flash.state.duration / 3
            flash.state.texturePaths = [texturePath]
        }
    }

    // MARK: - EF_BLOODDRAIN (216)

    /// Spawns red parabolic spline particles (`PP_3DPARTICLESPLINE` (8)) toward the caster/target for `EF_BLOODDRAIN` (216).
    func redParticleSpray(count sprayCount: Int, context: EffectTickContext) {
        guard stateCnt == 0 else {
            return
        }

        let spritePath = K2L("이팩트\\particle1.spr")
        let actionPath = K2L("이팩트\\particle1.act")
        _ = context.assets?.spriteAsset(spritePath: spritePath, actionPath: actionPath)

        let (origin, destination) = directionalLaunchEndpoints()
        let faceAngle = Self.effectHeading(fromX: origin.x, fromZ: origin.z, toX: destination.x, toZ: destination.z)
        let travelDistance = Self.effectDistanceXZ(from: origin, to: destination)

        for index in 0..<sprayCount {
            let spline = launchPrimitive(.pp_3dparticlespline)
            spline.state.duration = 60
            spline.state.deltaPos2 = SIMD3<Float>(0, -10.0, 0)
            spline.state.radius = travelDistance
            spline.state.longitude = -faceAngle
            let speed = spline.state.radius / Float(spline.state.duration)
            spline.state.speed = speed + speed
            spline.state.gravSpeed = 2.0
            let rise = -(spline.state.gravSpeed / Float(spline.state.duration))
            spline.state.gravAccel = rise + rise
            spline.state.latiSpeed = -2.0
            let spread = -(spline.state.latiSpeed / Float(spline.state.duration))
            spline.state.latiAccel = spread + spread
            spline.state.roll = Float(index * 90 - 90)
            spline.state.transform = EffectSpace.rotationY(radians: EffectSpace.radian(degrees: Int(spline.state.longitude)))
            let forward = EffectSpace.transformVector(SIMD3<Float>(0, 0, 1.0), by: spline.state.transform)
            spline.state.deltaPos3 = forward
            spline.state.rotAxis = forward
            spline.state.red = 250
            spline.state.green = 100
            spline.state.blue = 100
            spline.state.size = 1.7
            spline.state.spritePath = spritePath
            spline.state.actionPath = actionPath
            spline.state.numSegment = 7
            spline.initSegment()
        }
    }

    // MARK: - EF_ENERGYDRAIN (217)

    /// Spawns 3 blue parabolic drain splines (`PP_3DPARTICLESPLINE` (8)) for `EF_ENERGYDRAIN` (217).
    func bloodDrain(context: EffectTickContext) {
        guard stateCnt == 0 else {
            return
        }

        let spritePath = K2L("이팩트\\particle1.spr")
        let actionPath = K2L("이팩트\\particle1.act")
        _ = context.assets?.spriteAsset(spritePath: spritePath, actionPath: actionPath)

        let (origin, destination) = directionalLaunchEndpoints()
        let faceAngle = Self.effectHeading(fromX: origin.x, fromZ: origin.z, toX: destination.x, toZ: destination.z)
        let travelDistance = Self.effectDistanceXZ(from: origin, to: destination)

        for angle in stride(from: -90, to: 180, by: 90) {
            let spline = launchPrimitive(.pp_3dparticlespline)
            spline.state.duration = 60
            spline.state.deltaPos2 = SIMD3<Float>(0, -10.0, 0)
            spline.state.radius = travelDistance
            spline.state.longitude = -faceAngle
            let speed = spline.state.radius / Float(spline.state.duration)
            spline.state.speed = speed + speed
            spline.state.gravSpeed = 2.0
            let rise = -(spline.state.gravSpeed / Float(spline.state.duration))
            spline.state.gravAccel = rise + rise
            spline.state.latiSpeed = -2.0
            let spread = -(spline.state.latiSpeed / Float(spline.state.duration))
            spline.state.latiAccel = spread + spread
            spline.state.roll = Float(angle)
            spline.state.transform = EffectSpace.rotationY(radians: EffectSpace.radian(degrees: Int(spline.state.longitude)))
            let forward = EffectSpace.transformVector(SIMD3<Float>(0, 0, 1.0), by: spline.state.transform)
            spline.state.deltaPos3 = forward
            spline.state.rotAxis = forward
            spline.state.red = 100
            spline.state.green = 100
            spline.state.blue = 250
            spline.state.size = 1.7
            spline.state.spritePath = spritePath
            spline.state.actionPath = actionPath
            spline.state.numSegment = 7
            spline.initSegment()
        }
    }

    // MARK: - EF_POTION_CON (218)

    /// Spawns rising fade aura cylinder (`PP_3DCYLINDER` (13)) for potion buffs and `EF_POTIONPILLAR` (221).
    func potionPillar(heightSpeed: Float, pillarDuration: Int, context: EffectTickContext) {
        let texturePath = "effect\\alpha_down.tga"
        _ = context.assets?.texture(atPath: texturePath)

        let cylinder = launchPrimitive(.pp_3dcylinder)
        cylinder.state.duration = pillarDuration
        cylinder.state.outerSize = 4.5
        cylinder.state.innerSize = 4.5
        cylinder.state.heightSize = 10.0
        cylinder.state.heightSpeed = heightSpeed
        cylinder.state.heightAccel = 0.01
        cylinder.state.alpha = 0
        cylinder.state.maxAlpha = 90.0
        cylinder.state.alphaSpeed = cylinder.state.maxAlpha / 20.0
        cylinder.state.fadeOutCnt = cylinder.state.duration - 10
        cylinder.state.texturePaths = [texturePath]
    }

    // MARK: - EF_POTION_BERSERK (220)

    /// Applies red berserk target tint, spawns rising streaks + camera quake, and advances `버서크.str` for `EF_POTION_BERSERK` (220).
    func potionBerserk(context: EffectTickContext) -> Bool {
        if stateCnt == 0 {
            configureSTR(path: K2L("버서크.str"))
            potionPillar(heightSpeed: 1.0, pillarDuration: 50, context: context)
        }

        if let targetID = targetObjectID ?? ownerObjectID, stateCnt <= 150 {
            context.world.applyTargetModifier(
                .tint(color: SIMD4<Float>(250.0 / 255.0, 120.0 / 255.0, 120.0 / 255.0, 1.0), durationTicks: 2),
                to: targetID
            )
        }

        if stateCnt == 18 {
            context.world.shakeCamera(amplitude: 1.0, duration: 0.35, frequency: 20.0)
            context.world.playSound(
                named: "effect\\ac_concentration.wav",
                atWorldPosition: EffectSpace.toWorldPosition(position),
                delay: 0
            )
        }

        if stateCnt >= 13 && stateCnt <= 109 && stateCnt % 4 == 0 {
            let streakTex = "effect\\ac_center2.tga"
            _ = context.assets?.texture(atPath: streakTex)

            let spot = launchPrimitive(.pp_3dcrosstexture)
            spot.state.duration = 40
            let yaw = EffectSpace.rotationY(radians: EffectSpace.radian(degrees: Int.random(in: 0..<360)))
            spot.state.deltaPos2 = EffectSpace.transformVector(SIMD3<Float>(0, 0, Float(Int.random(in: 0..<7) + 2)), by: yaw)
            spot.state.transform = EffectSpace.rotationX(radians: EffectSpace.radian(degrees: 90))
            spot.state.speed = Float(Int.random(in: 0..<50) + 20) / 60.0
            spot.state.widthSize = Float(Int.random(in: 0..<60) + 30) / 10.0
            spot.state.heightSize = 0.2
            spot.state.red = 240
            spot.state.green = 0
            spot.state.blue = 0
            spot.state.alpha = 0
            spot.state.maxAlpha = 180.0
            spot.state.alphaSpeed = spot.state.maxAlpha / 20.0
            spot.state.fadeOutCnt = spot.state.duration - 20
            spot.state.texturePaths = [streakTex]
            spot.state.slots[0].life = 0
        }

        _ = processEZ2STRRaised(context: context)
        return stateCnt <= 150
    }

    // MARK: - EF_DEFENDER (222)

    /// Spawns 4-layer Defender casting shroud (`PP_3DCASTING_2` (24)) for `EF_DEFENDER` (222).
    func quadRingStack(texturePath: String, context: EffectTickContext) {
        guard stateCnt == 0 else {
            return
        }

        _ = context.assets?.texture(atPath: texturePath)

        let primitive = launchPrimitive(.pp_3dcasting_2)
        primitive.state.renderFlag = EffectPrimitiveState.RenderFlag.alpha | EffectPrimitiveState.RenderFlag.customBlend
        primitive.state.duration = duration
        primitive.state.texturePaths = [texturePath]
        primitive.state.size = 0

        let rotStarts: [Int16] = [180, 270, 0, 90]
        for index in 0..<4 {
            primitive.state.slots[index].life = 1
            primitive.state.slots[index].process = 0
            primitive.state.slots[index].fullDisplayAngle = 360
            primitive.state.slots[index].maxHeight = 40.0 - Float(index)
            primitive.state.slots[index].rotStart = rotStarts[index]
            primitive.state.slots[index].alphaB = 0
            primitive.state.slots[index].distance = 8.0 - Float(index) * 0.1
            primitive.state.slots[index].riseAngle = 90
            primitive.state.slots[index].vecBNow.y = 0
            primitive.state.slots[index].height = Array(repeating: 0, count: 21)
            primitive.state.slots[index].flag1 = Array(repeating: 0, count: 21)
        }
    }

    // MARK: - EF_GANBANTEIN (223)

    /// Spawns 4-quadrant rotating cross rings (`31`) for `EF_GANBANTEIN` (223), `EF_VOLCANO` (225), `EF_DELUGE` (236), `EF_VIOLENTGALE` (237), and `EF_LANDPROTECTOR` (238).
    func texturedCrossKind(texturePath: String, level: Int8, context: EffectTickContext) {
        guard stateCnt == 0 else {
            return
        }

        _ = context.assets?.texture(atPath: texturePath)

        let primitive = launchPrimitive(31)
        primitive.state.renderFlag = EffectPrimitiveState.RenderFlag.alpha | EffectPrimitiveState.RenderFlag.customBlend
        primitive.state.duration = duration
        primitive.state.texturePaths = [texturePath]
        primitive.state.size = level == 3 ? 17.0 : 0

        for index in 0..<4 {
            primitive.state.slots[index].life = 1
            primitive.state.slots[index].process = 0
            primitive.state.slots[index].fullDisplayAngle = 360
            primitive.state.slots[index].maxHeight = level == 2 ? 15.0 : 25.0
            primitive.state.slots[index].riseAngle = level == 2 ? 70 : 80
            primitive.state.slots[index].rotStart = Int16(index * 90)
            primitive.state.slots[index].alphaB = 0
            primitive.state.slots[index].distance = Float(index) + 1.0
            primitive.state.slots[index].alphaT = Int16(level)
            primitive.state.slots[index].vecBNow.y = 0
            primitive.state.slots[index].height = Array(repeating: 0, count: 21)
            primitive.state.slots[index].flag1 = Array(repeating: 0, count: 21)
        }
    }

    // MARK: - EF_WIND (224)

    /// Spawns 4 orbiting cloud wind ribbons (`PP_WIND` (62)) for `EF_WIND` (224).
    func healCloudRings(context: EffectTickContext) {
        guard stateCnt == 0 else {
            return
        }

        let texturePath = "effect\\cloud11.tga"
        _ = context.assets?.texture(atPath: texturePath)

        let primitive = launchPrimitive(.pp_wind)
        primitive.state.renderFlag = EffectPrimitiveState.RenderFlag.alpha | EffectPrimitiveState.RenderFlag.customBlend
        primitive.state.duration = duration
        primitive.state.texturePaths = [texturePath]
        primitive.state.size = 4.0

        let configs: [(arc: Int16, rotStart: Int16, distance: Float, height: Float)] = [
            (90, 0, 3.0, 3.0),
            (70, 10, 3.2, 2.5),
            (50, 20, 3.4, 2.0),
            (30, 30, 3.6, 1.5),
        ]

        for (index, config) in configs.enumerated() {
            primitive.state.slots[index].life = 1
            primitive.state.slots[index].process = 0
            primitive.state.slots[index].fullDisplayAngle = config.arc
            primitive.state.slots[index].maxHeight = 8.0
            primitive.state.slots[index].rotStart = config.rotStart
            primitive.state.slots[index].alphaB = 0
            primitive.state.slots[index].distance = config.distance
            primitive.state.slots[index].riseAngle = 90
            primitive.state.slots[index].alphaT = 0
            for j in 0..<21 {
                primitive.state.slots[index].height[j] = config.height
                primitive.state.slots[index].flag1[j] = 0
            }
        }

        context.world.playSound(
            named: "_heal_effect.wav",
            atWorldPosition: EffectSpace.toWorldPosition(position),
            delay: 0
        )
    }

    // MARK: - EF_GRANDCROSS (226)

    /// Spawns corner casting rings (`PP_GI_3` (34)) for `EF_GRANDCROSS2` (450).
    func grandCrossRings(angle: Int16, kind: Int8, context: EffectTickContext) {
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

    // MARK: - EF_GRANDCROSS (226)

    /// Spawns ground cross pillars (`PP_GRANDCROSS2` (37)) for `EF_GRANDCROSS2` (450).
    func grandCross2(flag: Int8, context: EffectTickContext) {
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

    // MARK: - EF_INTIMIDATE (227)

    /// Spawns 4-slot white spray ribbons (`PP_INTIMIDATE` (43)) for `EF_INTIMIDATE` (227).
    func whiteSpray(kind: Int8, context: EffectTickContext) {
        guard stateCnt == 0 else {
            return
        }

        let texturePath = kind == 4 ? "effect\\white03.bmp" : "effect\\white01.bmp"
        _ = context.assets?.texture(atPath: texturePath)

        let spray = launchPrimitive(.pp_intimidate)
        spray.state.renderFlag = EffectPrimitiveState.RenderFlag.alpha | EffectPrimitiveState.RenderFlag.customBlend
        spray.state.duration = duration
        spray.state.texturePaths = [texturePath]

        for index in 0..<4 {
            spray.state.slots[index].life = 1
            spray.state.slots[index].vecBNow = deltaPos

            if kind == 2 {
                spray.state.slots[index].process = Int.random(in: 0..<26) * -2
                spray.state.slots[index].flag1[0] = 2
                spray.state.slots[index].height[1] = 2.5
            } else if kind == 3 {
                spray.state.slots[index].process = -70 - Int.random(in: 0..<30)
                spray.state.slots[index].flag1[0] = Int8(Int.random(in: 0..<3) + 3)
                spray.state.slots[index].height[1] = 4.0
            } else if kind == 4 {
                spray.state.slots[index].process = -30 - Int.random(in: 0..<20)
                spray.state.slots[index].flag1[0] = Int8(Int.random(in: 0..<3) + 3)
                spray.state.slots[index].height[1] = 3.0
            } else {
                spray.state.slots[index].process = -70 - Int.random(in: 0..<30)
                spray.state.slots[index].flag1[0] = 0
                spray.state.slots[index].height[1] = 3.5
            }

            spray.state.slots[index].distance = 12.0
            spray.state.slots[index].height[0] = 1.5
            spray.state.slots[index].riseAngle = Int16(Int.random(in: 0..<360))
            spray.state.slots[index].fullDisplayAngle = Int16(Int.random(in: 0..<360))
            spray.state.slots[index].rotStart = Int16(Int.random(in: 0..<360))
            spray.state.slots[index].height[2] = Float(Int.random(in: 0..<360))
            spray.state.slots[index].alphaB = 0
        }
    }

    // MARK: - EF_CHOOKGI (228)

    /// Spawns orbiting Monk spirit spheres or elemental/coin orbs (`32`) for `EF_CHOOKGI` (228).
    func elementalOrbit(kind: Int8, context: EffectTickContext) {
        guard stateCnt == 0 else {
            return
        }

        let requestedCount = Int(deltaPos.x)
        guard requestedCount > 0 else {
            return
        }
        let sphereCount = min(requestedCount, 5)

        let texturePath: String = switch kind {
        case 10: "effect\\fire-1.bmp"
        case 11: "effect\\lightning-1.bmp"
        case 12: "effect\\water-1.bmp"
        case 13: "effect\\stone-1.bmp"
        case 4: "effect\\RL_richs_coin_B\\rcoin1.bmp"
        default: "effect\\thunder_center.bmp"
        }
        _ = context.assets?.texture(atPath: texturePath)

        for index in 0..<sphereCount {
            let sphere = launchPrimitive(32)
            sphere.state.renderFlag = EffectPrimitiveState.RenderFlag.alpha | EffectPrimitiveState.RenderFlag.customBlend
            sphere.state.duration = duration
            sphere.state.slots[0].life = 1
            for h in 0..<6 {
                sphere.state.slots[0].height[h] = Float(Int.random(in: 0..<360))
            }

            if kind == 1 {
                sphere.state.slots[0].height[6] = Float(index * 72)
                sphere.state.slots[0].height[7] = -14.0
                sphere.state.slots[0].distance = 1.3
                sphere.state.slots[0].height[10] = 1.0
                sphere.state.slots[0].flag1[0] = 0
            } else if kind == 3 || kind == 4 {
                if deltaPos.x <= 5.0 {
                    sphere.state.slots[0].height[6] = Float(index * 360) / deltaPos.x
                } else {
                    sphere.state.slots[0].height[6] = Float(index * 72)
                }
                sphere.state.slots[0].height[7] = -15.0
                sphere.state.slots[0].distance = 1.0
                if deltaPos.x > 5.0 && deltaPos.x - Float(index) >= 6.0 {
                    sphere.state.slots[0].distance = 2.0
                }
                sphere.state.slots[0].height[10] = 0
                sphere.state.slots[0].flag1[0] = 1
            } else {
                sphere.state.slots[0].height[6] = Float(index * 72)
                sphere.state.slots[0].height[7] = -15.0
                sphere.state.slots[0].distance = 2.0
                sphere.state.slots[0].height[10] = 0
                sphere.state.slots[0].flag1[0] = 0

                let total = deltaPos.x
                if total > 10.0 {
                    sphere.state.slots[0].flag1[0] = (total - Float(index) >= 11.0) ? 21 : 20
                } else if total > 5.0 && (total - Float(index) >= 6.0) {
                    sphere.state.slots[0].flag1[0] = 20
                }

                if kind >= 10 {
                    var startAngle = sphere.state.slots[0].height[6] + Float(Int.random(in: 0..<360))
                    if startAngle >= 360.0 {
                        startAngle -= 360.0
                    }
                    sphere.state.slots[0].height[6] = startAngle
                    sphere.state.slots[0].flag1[0] = kind
                    sphere.state.slots[0].distance = 6.0
                    sphere.state.totalTexture = 1
                }
            }

            sphere.state.slots[0].height[8] = Float(Int.random(in: 0..<360))
            sphere.state.slots[0].alphaB = 0
            sphere.state.slots[0].process = 0
            sphere.state.texturePaths = [texturePath]
        }
    }

    // MARK: - EF_CLOUD (229)

    /// Spawns 4-slot ambient cloud or star billboards (`33`) for `EF_CLOUD` (229), `EF_CLOUD2` (230), and `EF_CLOUD3` (233).
    func skyCloud(kind: Int8, context: EffectTickContext) {
        if stateCnt == 99_999_998 {
            stateCnt = 0
            duration = 99_999_999
        } else if stateCnt != 0 {
            return
        }

        let cloud = launchPrimitive(33)
        cloud.state.renderFlag = EffectPrimitiveState.RenderFlag.alpha | EffectPrimitiveState.RenderFlag.customBlend
        cloud.state.duration = duration

        if kind == 3 {
            let pick = ["effect\\fog1.tga", "effect\\fog2.tga", "effect\\fog3.tga"].randomElement()!
            _ = context.assets?.texture(atPath: pick)
            cloud.state.totalTexture = 3
            cloud.state.texturePaths = [pick]
        } else if kind == 9 || kind == 15 {
            let stars = (1...6).map { "effect\\star0\($0).bmp" }
            for path in stars {
                _ = context.assets?.texture(atPath: path)
            }
            cloud.state.totalTexture = 6
            cloud.state.texturePaths = stars
        } else {
            let pick = ["effect\\cloud4.tga", "effect\\cloud1.tga", "effect\\cloud2.tga"].randomElement()!
            _ = context.assets?.texture(atPath: pick)
            cloud.state.totalTexture = 3
            cloud.state.texturePaths = [pick]
        }

        let layer = Float(kind)
        for index in 0..<4 {
            cloud.state.slots[index].life = 1
            cloud.state.slots[index].process = 0
            cloud.state.slots[index].height[7] = layer
            cloud.state.slots[index].fullDisplayAngle = 45

            if kind == 0 {
                cloud.state.slots[index].height[6] = -152.0
                if position.y > -152.0 {
                    cloud.state.slots[index].process = 300
                }
            }

            cloud.state.slots[index].alphaB = 0
            cloud.state.slots[index].flag1[0] = 0
            cloud.state.slots[index].rotStart = Int16(Int.random(in: 0..<200) + 300)

            if kind == 0 {
                cloud.state.slots[index].vecBNow.y = Float(Int.random(in: 0..<10)) - 125.0
                cloud.state.slots[index].vecBNow.x = Float(Int.random(in: 0..<300) - 150)
                cloud.state.slots[index].vecBNow.z = Float(Int.random(in: 0..<300) - 150)
            } else if kind == 2 {
                cloud.state.slots[index].vecBNow.y = Float(Int.random(in: 0..<10))
                cloud.state.slots[index].vecBNow.x = Float(Int.random(in: 0..<300) - 150)
                cloud.state.slots[index].vecBNow.z = Float(Int.random(in: 0..<300) - 150)
            } else if kind == 3 {
                let x = Float(Int.random(in: 0..<300) - 150)
                let z = Float(Int.random(in: 0..<300) - 150)
                let h = context.world.terrainHeight(atEffectX: x + position.x, effectZ: z + position.z)
                cloud.state.slots[index].vecBNow = SIMD3<Float>(x, h - 20.0 - Float(Int.random(in: 0..<5)), z)
            } else if kind == 5 {
                cloud.state.slots[index].vecBNow.y = Float(Int.random(in: 0..<10)) + 20.0
                cloud.state.slots[index].vecBNow.x = Float(Int.random(in: 0..<300) - 150)
                cloud.state.slots[index].vecBNow.z = Float(Int.random(in: 0..<300) - 150)
            } else if kind == 9 || kind == 15 {
                cloud.state.slots[index].vecBNow.y = Float(Int.random(in: 0..<10)) + 80.0
                cloud.state.slots[index].vecBNow.x = Float(Int.random(in: 0..<200) + 25) * (Bool.random() ? 1 : -1)
                cloud.state.slots[index].vecBNow.z = Float(Int.random(in: 0..<200) + 25) * (Bool.random() ? 1 : -1)
            } else {
                cloud.state.slots[index].vecBNow.y = Float(Int.random(in: 0..<10)) + 40.0
                cloud.state.slots[index].vecBNow.x = Float(Int.random(in: 0..<200) + 25) * (Bool.random() ? 1 : -1)
                cloud.state.slots[index].vecBNow.z = Float(Int.random(in: 0..<200) + 25) * (Bool.random() ? 1 : -1)
            }

            cloud.state.slots[index].vecBNow.x += position.x
            cloud.state.slots[index].vecBNow.z += position.z
            for h in 0..<4 {
                cloud.state.slots[index].height[h] = Float(Int.random(in: 0..<360))
            }
            cloud.state.slots[index].distance = kind == 3
                ? Float(Int.random(in: 0..<10)) + 35.0
                : Float(Int.random(in: 0..<20)) + 30.0
            cloud.state.slots[index].height[8] = Float(Int.random(in: 0..<360))

            let flag2ByKind: [Int8: Int8] = [
                3: 12, 5: 14, 7: 16, 8: 17, 9: 23,
                15: 25, 11: 14, 12: 16, 13: 17, 14: 24,
            ]
            cloud.state.slots[index].flag1[2] = flag2ByKind[kind] ?? 0
        }
    }

    // MARK: - EF_MAPPILLAR (231)

    /// Spawns staged expanding pillar rings (`41`) for `EF_MAPPILLAR` (231) and `EF_MAPPILLAR2` (247).
    func texturedCrossStaged(texturePath: String, level: Int8, context: EffectTickContext) {
        guard stateCnt == 0 else {
            return
        }

        _ = context.assets?.texture(atPath: texturePath)

        let primitive = launchPrimitive(41)
        primitive.state.renderFlag = EffectPrimitiveState.RenderFlag.alpha | EffectPrimitiveState.RenderFlag.customBlend
        primitive.state.duration = duration
        primitive.state.texturePaths = [texturePath]
        primitive.state.size = switch level {
        case ...1: 4.0
        case 2: 7.0
        case 3: 6.0
        default: 1.0
        }

        for index in 0..<4 {
            primitive.state.slots[index].life = 1
            primitive.state.slots[index].process = index * 30
            primitive.state.slots[index].fullDisplayAngle = 360
            primitive.state.slots[index].maxHeight = 120.0
            primitive.state.slots[index].rotStart = Int16(index * 90)
            primitive.state.slots[index].vecBNow.y = 0
            if level == 0 || level > 1 {
                primitive.state.slots[index].alphaB = 50
                primitive.state.slots[index].distance = Float(index) * 0.5 + 2.0
            } else {
                primitive.state.slots[index].alphaB = 70
                primitive.state.slots[index].distance = Float(index) * 0.5 + 11.0
            }
            primitive.state.slots[index].alphaT = 0
            primitive.state.slots[index].riseAngle = 89
            primitive.state.slots[index].height = Array(repeating: 0, count: 21)
            primitive.state.slots[index].flag1 = Array(repeating: 0, count: 21)
        }
    }

    // MARK: - EF_LINELINK (232)

    /// Spawns a target-tracking cloud tether (`PP_LINELINK` (38)) for `EF_LINELINK` (232).
    func trackCloud(kind: Int8, context: EffectTickContext) {
        guard stateCnt == 0 else {
            return
        }

        let texturePath = "effect\\cloud11.tga"
        _ = context.assets?.texture(atPath: texturePath)

        let link = launchPrimitive(.pp_linelink)
        link.state.renderFlag = EffectPrimitiveState.RenderFlag.alpha | EffectPrimitiveState.RenderFlag.customBlend
        link.state.duration = duration
        link.state.texturePaths = [texturePath]
        link.state.slots[0].life = 1
        link.state.slots[0].process = 0
        link.state.slots[0].alphaB = 45
        link.state.slots[0].distance = 0
        link.state.slots[0].maxHeight = 0.4
        link.state.slots[0].height[4] = kind == 2 ? 4.0 : 0
        link.state.slots[0].vecTNow = position

        let resolvedTargetID = sourceObjectID ?? ownerObjectID
        if let resolvedTargetID, let targetState = context.world.targetState(for: resolvedTargetID) {
            link.state.slots[0].targetObjectID = resolvedTargetID
            link.state.slots[0].vecTPre = targetState.effectPosition
        } else if let sourcePosition {
            link.state.slots[0].vecTPre = sourcePosition
        } else if deltaPos != .zero {
            link.state.slots[0].vecTPre = deltaPos
        } else {
            link.state.slots[0].life = 0
        }

        for i in 1..<4 {
            link.state.slots[i].life = 0
        }
    }

    // MARK: - EF_BOTTOM_VO (239)

    /// Spawns textured ground flare (`36`) for `EF_BOTTOM_VO` (239), `EF_BOTTOM_DE` (240), and `EF_BOTTOM_VI` (241).
    func texturedFlare(texturePath: String, size: Int8, offsetX: Float, offsetZ: Float, context: EffectTickContext) {
        guard stateCnt == 0 else {
            return
        }

        _ = context.assets?.texture(atPath: texturePath)

        let primitive = launchPrimitive(36)
        primitive.state.renderFlag = EffectPrimitiveState.RenderFlag.alpha | EffectPrimitiveState.RenderFlag.customBlend
        primitive.state.duration = duration
        primitive.state.texturePaths = [texturePath]
        primitive.state.size = Float(size)
        for i in 1..<4 {
            primitive.state.slots[i].life = 0
        }
        primitive.state.slots[0].life = 1
        primitive.state.slots[0].process = 0
        primitive.state.slots[0].fullDisplayAngle = 360
        primitive.state.slots[0].maxHeight = 15.0
        primitive.state.slots[0].rotStart = Int16(Int.random(in: 0..<360))
        primitive.state.slots[0].alphaB = Int16(Int.random(in: 0..<100))
        primitive.state.slots[0].distance = 2.6
        primitive.state.slots[0].riseAngle = 80
        primitive.state.slots[0].height = Array(repeating: 0, count: 21)
        primitive.state.slots[0].flag1 = Array(repeating: 0, count: 21)
    }

    // MARK: - EF_BOTTOM_LA (242)

    /// Spawns rotating ground halo (`39`) for `EF_BOTTOM_LA` (242).
    func texturedHalo(texturePath: String, kind: Int8, context: EffectTickContext) {
        guard stateCnt == 0 else {
            return
        }

        _ = context.assets?.texture(atPath: texturePath)

        let primitive = launchPrimitive(39)
        primitive.state.renderFlag = EffectPrimitiveState.RenderFlag.alpha | EffectPrimitiveState.RenderFlag.customBlend
        primitive.state.duration = duration
        primitive.state.texturePaths = [texturePath]
        primitive.state.slots[0].life = 1
        for i in 1..<4 {
            primitive.state.slots[i].life = 0
        }

        primitive.state.slots[0].distance = switch kind {
        case 2, 4: 12.0
        case 3: 10.0
        case 10: 30.0
        case 11: 28.0
        case 12: 20.0
        default: 7.0
        }

        if kind == 3 {
            primitive.state.slots[0].rotStart = 225
            primitive.state.slots[0].alphaB = 250
            primitive.state.size = 111.0
        } else if kind == 4 {
            primitive.state.slots[0].rotStart = 0
            primitive.state.slots[0].alphaB = 200
            primitive.state.size = 4.0
        } else if kind == 10 || kind == 11 || kind == 12 {
            primitive.state.slots[0].rotStart = 0
            primitive.state.slots[0].alphaB = 200
            primitive.state.size = 10.0
        } else {
            primitive.state.slots[0].rotStart = 0
            primitive.state.slots[0].alphaB = 100
            primitive.state.size = 5.0
        }

        primitive.state.slots[0].riseAngle = (kind == 10 || kind == 11 || kind == 12) ? 360 : Int16(Int.random(in: 0..<360))
        primitive.state.slots[0].height[0] = -2.0
        primitive.state.slots[0].height[4] = Float(kind)
    }

    // MARK: - EF_MAGICROD (244)

    /// Plays Magic Rod absorption audio on frame 0 for `EF_MAGICROD` (244).
    func sageMagicRod(context: EffectTickContext) {
        guard stateCnt == 0 else {
            return
        }

        context.world.playSound(
            named: "effect\\sage_magic rod.wav",
            atWorldPosition: EffectSpace.toWorldPosition(position),
            delay: 0
        )
    }

    // MARK: - EF_PROVIDENCE (248)

    /// Spawns rising cross pillar (`41`) for `EF_PROVIDENCE` (248).
    func texturedCross(texturePath: String, kind: Int8, context: EffectTickContext) {
        guard stateCnt == 0 else {
            return
        }

        _ = context.assets?.texture(atPath: texturePath)

        let primitive = launchPrimitive(41)
        primitive.state.renderFlag = EffectPrimitiveState.RenderFlag.alpha | EffectPrimitiveState.RenderFlag.customBlend
        primitive.state.duration = duration
        primitive.state.texturePaths = [texturePath]
        primitive.state.size = 5.0

        guard kind == 0 else {
            return
        }

        for index in 0..<4 {
            primitive.state.slots[index].life = 1
            primitive.state.slots[index].process = 200
            primitive.state.slots[index].fullDisplayAngle = 360
            primitive.state.slots[index].maxHeight = 120.0
            primitive.state.slots[index].rotStart = Int16(index * 90)
            primitive.state.slots[index].alphaB = 40
            primitive.state.slots[index].distance = Float(index) * 0.5 + 6.0
            primitive.state.slots[index].riseAngle = Int16(83 - index)
            primitive.state.slots[index].alphaT = 1
            primitive.state.slots[index].vecBNow.y = 0
            primitive.state.slots[index].height = Array(repeating: 0, count: 21)
            primitive.state.slots[index].flag1 = Array(repeating: 0, count: 21)
        }
    }

    // MARK: - EF_SHIELDBOOMERANG (249)

    /// Spawns a boomerang shield projectile with 3 trail slots (`PP_SHIELDBOOMERANG` (42)) for `EF_SHIELDBOOMERANG` (249).
    func texturedShieldThrow(texturePath: String, context: EffectTickContext) {
        guard stateCnt == 0 else {
            return
        }

        context.world.playSound(
            named: "effect\\cru_shield boomerang.wav",
            atWorldPosition: EffectSpace.toWorldPosition(position),
            delay: 0
        )

        _ = context.assets?.texture(atPath: texturePath)

        let (origin, destination) = directionalLaunchEndpoints()
        let deltaX = destination.x - origin.x
        let deltaZ = destination.z - origin.z
        let travelDistance = max(0.001, sqrtf(deltaZ * deltaZ + deltaX * deltaX))

        let shield = launchPrimitive(.pp_shieldboomerang)
        shield.state.renderFlag = EffectPrimitiveState.RenderFlag.alpha | EffectPrimitiveState.RenderFlag.customBlend
        shield.state.duration = duration
        shield.state.texturePaths = [texturePath]
        shield.state.size = 0
        shield.state.deltaPos = destination
        shield.state.slots[0].life = 1
        shield.state.slots[0].process = 0
        shield.state.slots[0].maxHeight = travelDistance
        shield.state.slots[0].distance = 7.0
        shield.state.slots[0].height[8] = 0
        shield.state.slots[0].alphaB = 255
        shield.state.slots[0].vecBNow = SIMD3<Float>(origin.x, origin.y - 8.0, origin.z)
        shield.state.slots[0].rotStart = 0
        shield.state.slots[0].height[1] = 2.0
        shield.state.slots[0].height[2] = (shield.state.slots[0].height[1] / travelDistance) * (destination.y - origin.y)
        shield.state.slots[0].fullDisplayAngle = 0
        shield.state.slots[0].flag1[0] = 0
        shield.state.slots[0].flag1[1] = 0
        shield.state.slots[0].flag1[2] = 0

        for i in 1..<4 {
            shield.state.slots[i].life = 1
            shield.state.slots[i].alphaB = 0
        }
    }

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

    // MARK: - EF_BOTTOM_LULLABY (278)

    /// Spawns `PP_BOTTOM` (47) ground particles for `EF_BOTTOM_WHISTLE` (286).
    func bottomMusic(texturePath: String, kind: Int8, context: EffectTickContext) {
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

    // MARK: - EF_BOTTOM_ROKISWEIL (283)

    /// Spawns `PP_BOTTOMOUT` (49) orbiting ground particles for `EF_BOTTOM_ROKISWEIL` (283).
    func bottomOut(texturePath: String, kind: Int8, context: EffectTickContext) {
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

    // MARK: - Inline OnProcess Cases (200...299)

    private func processDarkBreath(context: EffectTickContext) {
        guard stateCnt == 0 else {
            return
        }

        let spritePath = K2L("이팩트\\DarkBreath.spr")
        let actionPath = K2L("이팩트\\DarkBreath.act")
        _ = context.assets?.spriteAsset(spritePath: spritePath, actionPath: actionPath)

        let breath = launchPrimitive(.pp_3dparticle)
        breath.state.duration = 65
        breath.state.renderFlag |= EffectPrimitiveState.RenderFlag.noDepth
        breath.state.deltaPos2.y -= 20.0
        breath.state.size = 0.8
        breath.state.animSpeed = 1
        breath.state.green = 0
        breath.state.blue = 0
        breath.state.fadeOutCnt = 60
        breath.state.spritePath = spritePath
        breath.state.actionPath = actionPath
        breath.initSegment()
    }

    private func processPotionCon(context: EffectTickContext) -> Bool {
        if stateCnt == 0 {
            configureSTR(path: K2L("집중.str"))
            context.world.playSound(
                named: "effect\\ac_concentration.wav",
                atWorldPosition: EffectSpace.toWorldPosition(position),
                delay: 0
            )
            potionPillar(heightSpeed: 2.0, pillarDuration: 50, context: context)
        }

        return processEZ2STRRaised(context: context)
    }

    private func processPotionAwakening(context: EffectTickContext) -> Bool {
        if stateCnt == 0 {
            configureSTR(path: K2L("각성.str"))
        }

        if stateCnt == 30 {
            context.world.playSound(
                named: "effect\\ac_concentration.wav",
                atWorldPosition: EffectSpace.toWorldPosition(position),
                delay: 0
            )
            potionPillar(heightSpeed: 1.9, pillarDuration: 30, context: context)
        }

        return processEZ2STRRaised(context: context)
    }

    // MARK: - EF_ABSORBSPIRITS (253)

    /// Spawns pulsing heal/absorb aura columns (`60`) and rising sparkles (`PP_PARTICLE_UP` (59)) for `EF_ABSORBSPIRITS` (253), `EF_HEAL2` (313), and `EF_HEAL4` (325).
    func healRingSparkle(texturePath: String, type: Int8, context: EffectTickContext) {
        if stateCnt == 0 {
            _ = context.assets?.texture(atPath: texturePath)

            let primitive = launchPrimitive(60)
            primitive.state.renderFlag = EffectPrimitiveState.RenderFlag.alpha | EffectPrimitiveState.RenderFlag.customBlend
            primitive.state.duration = duration
            primitive.state.texturePaths = [texturePath]
            primitive.state.size = type == 2 ? 4.0 : 9.0

            let alphaT: Int16 = type == 0 ? 60 : 40
            let outerHeight: Float = type == 0 ? 12.0 : 18.0
            let configs: [(maxHeight: Float, rotStart: Int16, distance: Float, riseAngle: Int16)] = [
                (60.0, 0, 4.6, 90),
                (60.0, 180, 5.0, 90),
                (outerHeight, Int16(Int.random(in: 0..<360)), 5.0, 50),
                (outerHeight, Int16(Int.random(in: 0..<360)), 5.2, 48),
            ]

            for (index, config) in configs.enumerated() {
                primitive.state.slots[index].life = 1
                primitive.state.slots[index].process = 0
                primitive.state.slots[index].fullDisplayAngle = 360
                primitive.state.slots[index].maxHeight = config.maxHeight
                primitive.state.slots[index].rotStart = config.rotStart
                primitive.state.slots[index].alphaB = 0
                primitive.state.slots[index].distance = config.distance
                primitive.state.slots[index].riseAngle = config.riseAngle
                primitive.state.slots[index].vecBNow.y = 0
                primitive.state.slots[index].alphaT = alphaT
                primitive.state.slots[index].height = Array(repeating: 0, count: 21)
                primitive.state.slots[index].flag1 = Array(repeating: 0, count: 21)
            }

            if type < 2 {
                context.world.playSound(
                    named: "_heal_effect.wav",
                    atWorldPosition: EffectSpace.toWorldPosition(position),
                    delay: 0
                )
            }
        } else if stateCnt <= 50 && stateCnt % 6 == 0 && type < 2 {
            let pok1 = "effect\\pok1.tga"
            let pok3 = "effect\\pok3.tga"
            _ = context.assets?.texture(atPath: pok1)
            _ = context.assets?.texture(atPath: pok3)

            let sparkle = launchPrimitive(.pp_particle_up)
            sparkle.state.renderFlag = EffectPrimitiveState.RenderFlag.alpha | EffectPrimitiveState.RenderFlag.customBlend
            sparkle.state.duration = duration
            sparkle.state.totalTexture = 2
            sparkle.state.texturePaths = [pok1, pok3]
            sparkle.state.size = 0
            sparkle.position = position

            for index in 0..<4 {
                sparkle.state.slots[index].life = 1
                sparkle.state.slots[index].process = 0
                sparkle.state.slots[index].distance = Float(Int.random(in: 0..<10)) * 0.1 + 2.0
                sparkle.state.slots[index].height[8] = 0
                sparkle.state.slots[index].alphaB = 0
                sparkle.state.slots[index].vecBNow = SIMD3<Float>(
                    Float(Int.random(in: 0..<13)) + position.x - 6.0,
                    position.y,
                    Float(Int.random(in: 0..<13)) + position.z - 6.0
                )
                sparkle.state.slots[index].rotStart = 0
                sparkle.state.slots[index].height[1] = 0
                sparkle.state.slots[index].height[2] = Float(Int.random(in: 0..<40)) * 0.01 + (type == 0 ? 0.4 : 0.6)
                sparkle.state.slots[index].fullDisplayAngle = 0
                sparkle.state.slots[index].flag1[0] = 0
                sparkle.state.slots[index].flag1[1] = 1
                sparkle.state.slots[index].flag1[2] = 11
                sparkle.state.slots[index].height[7] = 0
            }
        }

        guard type == 1 else {
            return
        }

        if stateCnt == 1 {
            let alphaDown = "effect\\alpha_down.tga"
            _ = context.assets?.texture(atPath: alphaDown)

            let primitive = launchPrimitive(60)
            primitive.state.renderFlag = EffectPrimitiveState.RenderFlag.alpha | EffectPrimitiveState.RenderFlag.customBlend
            primitive.state.duration = duration
            primitive.state.texturePaths = [alphaDown]
            primitive.state.size = 9.0

            let configs: [(maxHeight: Float, rotStart: Int16, distance: Float, riseAngle: Int16, alphaT: Int16)] = [
                (90.0, 0, 4.2, 90, 40),
                (90.0, 90, 4.3, 90, 40),
                (10.0, Int16(Int.random(in: 0..<360)), 5.3, 46, 30),
                (10.0, Int16(Int.random(in: 0..<360)), 5.4, 44, 30),
            ]
            for (index, config) in configs.enumerated() {
                primitive.state.slots[index].life = 1
                primitive.state.slots[index].process = 0
                primitive.state.slots[index].fullDisplayAngle = 360
                primitive.state.slots[index].maxHeight = config.maxHeight
                primitive.state.slots[index].rotStart = config.rotStart
                primitive.state.slots[index].alphaB = 0
                primitive.state.slots[index].distance = config.distance
                primitive.state.slots[index].riseAngle = config.riseAngle
                primitive.state.slots[index].alphaT = config.alphaT
                primitive.state.slots[index].vecBNow.y = 0
                primitive.state.slots[index].height = Array(repeating: 0, count: 21)
                primitive.state.slots[index].flag1 = Array(repeating: 0, count: 21)
            }
        }

        if stateCnt <= 50 && stateCnt % 9 == 2 {
            let pok1 = "effect\\pok1.tga"
            let pok3 = "effect\\pok3.tga"
            _ = context.assets?.texture(atPath: pok1)
            _ = context.assets?.texture(atPath: pok3)

            let sparkle = launchPrimitive(.pp_particle_up)
            sparkle.state.renderFlag = EffectPrimitiveState.RenderFlag.alpha | EffectPrimitiveState.RenderFlag.customBlend
            sparkle.state.duration = duration
            sparkle.state.totalTexture = 2
            sparkle.state.texturePaths = [pok1, pok3]
            sparkle.state.size = 0
            sparkle.position = position

            for index in 0..<4 {
                sparkle.state.slots[index].life = 1
                sparkle.state.slots[index].process = 0
                sparkle.state.slots[index].distance = Float(Int.random(in: 0..<10)) * 0.1 + 2.4
                sparkle.state.slots[index].height[8] = 0
                sparkle.state.slots[index].alphaB = 0
                sparkle.state.slots[index].vecBNow = SIMD3<Float>(
                    Float(Int.random(in: 0..<13)) + position.x - 6.0,
                    position.y,
                    Float(Int.random(in: 0..<13)) + position.z - 6.0
                )
                sparkle.state.slots[index].rotStart = 0
                sparkle.state.slots[index].height[1] = 0
                sparkle.state.slots[index].height[2] = Float(Int.random(in: 0..<40)) * 0.01 + 0.4
                sparkle.state.slots[index].fullDisplayAngle = 0
                sparkle.state.slots[index].flag1[0] = 0
                sparkle.state.slots[index].flag1[1] = 1
                sparkle.state.slots[index].flag1[2] = 11
                sparkle.state.slots[index].height[7] = 0
            }
        }
    }

    // MARK: - EF_GUMGANG2 (261)

    /// Spawns 4-quadrant rotating cross rings (`31`) with `accel = 99` for `EF_GUMGANG2` (261).
    func texturedCrossLevel(texturePath: String, level: Int8, context: EffectTickContext) {
        guard stateCnt == 0 else {
            return
        }

        _ = context.assets?.texture(atPath: texturePath)

        let primitive = launchPrimitive(31)
        primitive.state.renderFlag = EffectPrimitiveState.RenderFlag.alpha | EffectPrimitiveState.RenderFlag.customBlend
        primitive.state.duration = duration
        primitive.state.texturePaths = [texturePath]
        primitive.state.size = 0
        primitive.state.accel = 99.0

        for index in 0..<4 {
            primitive.state.slots[index].life = 1
            primitive.state.slots[index].process = 0
            primitive.state.slots[index].fullDisplayAngle = 360
            primitive.state.slots[index].maxHeight = 25.0
            primitive.state.slots[index].rotStart = Int16(index * 90)
            primitive.state.slots[index].alphaB = 0
            primitive.state.slots[index].distance = Float(index) + 1.0
            primitive.state.slots[index].riseAngle = 80
            primitive.state.slots[index].alphaT = Int16(level)
            primitive.state.slots[index].vecBNow.y = 0
            primitive.state.slots[index].height = Array(repeating: 0, count: 21)
            primitive.state.slots[index].flag1 = Array(repeating: 0, count: 21)
        }
    }

    // MARK: - EF_TEIHIT1 (262)

    /// Spawns 4-slot radial scatter plates (`44`) for `EF_TEIHIT1` (262) and `EF_TEIHIT1X` (266).
    func texturedScatter(texturePath: String, flag: Int8, context: EffectTickContext) {
        guard stateCnt == 0 else {
            return
        }

        _ = context.assets?.texture(atPath: texturePath)

        let primitive = launchPrimitive(44)
        primitive.state.renderFlag = EffectPrimitiveState.RenderFlag.alpha | EffectPrimitiveState.RenderFlag.customBlend
        primitive.state.duration = duration
        primitive.state.texturePaths = [texturePath]
        position.y -= 9.0

        for index in 0..<4 {
            primitive.state.slots[index].life = 1
            primitive.state.slots[index].process = -10 - Int.random(in: 0..<25)
            primitive.state.slots[index].distance = -10.0
            primitive.state.slots[index].height[0] = 3.0
            primitive.state.slots[index].riseAngle = Int16(Int.random(in: 0..<360))
            primitive.state.slots[index].fullDisplayAngle = Int16(Int.random(in: 0..<360))
            primitive.state.slots[index].height[1] = 0.7
            primitive.state.slots[index].alphaB = 0
            primitive.state.slots[index].flag1[0] = flag
            primitive.state.slots[index].flag1[1] = 24
        }
    }

    // MARK: - EF_TEIHIT2 (264)

    /// Spawns 4-slot impact spark streaks (`PP_TEIHIT2` (45)) for `EF_TEIHIT2` (264) and `EF_BACKSTAP` (275).
    func teiHit2(context: EffectTickContext) {
        guard stateCnt == 0 else {
            return
        }

        let texturePath = "effect\\thunder_center.bmp"
        _ = context.assets?.texture(atPath: texturePath)

        let primitive = launchPrimitive(.pp_teihit2)
        primitive.state.renderFlag = EffectPrimitiveState.RenderFlag.alpha | EffectPrimitiveState.RenderFlag.customBlend
        primitive.state.duration = duration
        primitive.state.texturePaths = [texturePath]
        primitive.state.size = 0
        primitive.state.deltaPos = deltaPos
        primitive.position = position

        for index in 0..<4 {
            primitive.state.slots[index].life = 1
            primitive.state.slots[index].process = Int.random(in: 0..<10) - 40
            primitive.state.slots[index].distance = Float(Int.random(in: 0..<16)) * 0.05 + 0.1
            primitive.state.slots[index].height[8] = 0
            primitive.state.slots[index].alphaB = 0
            primitive.state.slots[index].vecBNow = SIMD3<Float>(deltaPos.x, deltaPos.y - 8.0, deltaPos.z)
            primitive.state.slots[index].rotStart = 0
            primitive.state.slots[index].height[1] = Float(Int.random(in: 0..<50)) * 0.01 + 0.75
            primitive.state.slots[index].height[2] = Float(Int.random(in: 0..<200)) * 0.01 - 1.0
            primitive.state.slots[index].fullDisplayAngle = 0
            primitive.state.slots[index].flag1[0] = 0
            primitive.state.slots[index].flag1[1] = 0
            primitive.state.slots[index].flag1[2] = 2
            primitive.state.slots[index].height[7] = 0
        }
    }

    // MARK: - EF_TANJI (265)

    /// Spawns a Throw Spirit Sphere projectile (`PP_SHIELDBOOMERANG` (42)) for `EF_TANJI` (265).
    func tanji(context: EffectTickContext) {
        guard stateCnt == 0 else {
            return
        }

        context.world.playSound(
            named: K2L("effect\\mon_탄지신통.wav"),
            atWorldPosition: EffectSpace.toWorldPosition(position),
            delay: 0
        )

        let texturePath = "effect\\blue_ivy.bmp"
        _ = context.assets?.texture(atPath: texturePath)

        let (origin, destination) = directionalLaunchEndpoints()
        let dx = destination.x - origin.x
        let dz = destination.z - origin.z
        let travelDistance = max(0.001, sqrtf(dx * dx + dz * dz))

        let primitive = launchPrimitive(.pp_shieldboomerang)
        primitive.state.renderFlag = EffectPrimitiveState.RenderFlag.alpha | EffectPrimitiveState.RenderFlag.customBlend
        primitive.state.duration = duration
        primitive.state.texturePaths = [texturePath]
        primitive.state.size = 0
        primitive.state.deltaPos = destination
        primitive.state.slots[0].life = 1
        primitive.state.slots[0].process = -15
        primitive.state.slots[0].maxHeight = travelDistance
        primitive.state.slots[0].distance = Float(count) * 0.4 + 2.0
        primitive.state.slots[0].height[8] = 0
        primitive.state.slots[0].alphaB = 5
        primitive.state.slots[0].vecBNow = SIMD3<Float>(origin.x, origin.y - 8.0, origin.z)
        primitive.state.slots[0].rotStart = 0
        primitive.state.slots[0].height[1] = 2.0
        primitive.state.slots[0].height[2] = (primitive.state.slots[0].height[1] / travelDistance) * (destination.y - origin.y)
        primitive.state.slots[0].fullDisplayAngle = 0
        primitive.state.slots[0].flag1[0] = 0
        primitive.state.slots[0].flag1[1] = 0
        primitive.state.slots[0].flag1[2] = 1
        primitive.state.slots[0].height[7] = 0

        for i in 1..<4 {
            primitive.state.slots[i].life = 1
            primitive.state.slots[i].alphaB = 0
        }
    }

    // MARK: - EF_CHIMTO (267)

    /// Spawns directional sprite impact (`46`) for `EF_CHIMTO` (267) and variants.
    func chimto(flag: Int8, context: EffectTickContext) {
        guard stateCnt == 0 else {
            return
        }

        if flag == 0 {
            context.world.playSound(
                named: K2L("effect\\mon_침투경.wav"),
                atWorldPosition: EffectSpace.toWorldPosition(position),
                delay: 0
            )
        }

        let primitive = launchPrimitive(46)
        primitive.state.duration = duration
        primitive.state.slots[0].life = 1
        primitive.state.slots[0].maxHeight = 0
        primitive.state.slots[0].vecBPre = deltaPos

        let spritePath: String
        let actionPath: String
        switch flag {
        case 0:
            primitive.state.alpha = 200.0
            spritePath = K2L("이팩트\\침투경_.spr")
            actionPath = K2L("이팩트\\침투경_.act")
            primitive.state.animSpeed = 2
            primitive.state.size = 2.5
        case 1:
            spritePath = K2L("이팩트\\wink.spr")
            actionPath = K2L("이팩트\\wink.act")
            primitive.state.animSpeed = 6
            primitive.state.size = 1.0
            primitive.state.repeatAnim = false
            primitive.state.pattern |= 0x200
        case 2:
            spritePath = K2L("이팩트\\fvoice.spr")
            actionPath = K2L("이팩트\\fvoice.act")
            primitive.state.animSpeed = 6
            primitive.state.size = 1.0
            primitive.state.repeatAnim = false
            primitive.state.pattern |= 0x200
        case 12:
            spritePath = K2L("이팩트\\헌드레드스피어.spr")
            actionPath = K2L("이팩트\\헌드레드스피어.act")
            primitive.state.animSpeed = 6
            primitive.state.size = 1.0
            primitive.state.repeatAnim = false
            primitive.state.pattern |= 0x200
        case 13:
            spritePath = K2L("이팩트\\윈드커터.spr")
            actionPath = K2L("이팩트\\윈드커터.act")
            primitive.state.animSpeed = 6
            primitive.state.size = 1.0
            primitive.state.repeatAnim = false
            primitive.state.pattern |= 0x200
        default:
            spritePath = ""
            actionPath = ""
        }

        if !spritePath.isEmpty {
            _ = context.assets?.spriteAsset(spritePath: spritePath, actionPath: actionPath)
            primitive.state.spritePath = spritePath
            primitive.state.actionPath = actionPath
        }

        let rawAngle = EffectPrimitive.angle(dx: position.x - deltaPos.x, dy: position.z - deltaPos.z)
        var angle = (Int(context.world.cameraYawDegrees) + Int(rawAngle)) % 360
        if angle < 0 {
            angle += 360
        }
        primitive.state.renderFlag |= 0x200
        if angle >= 180 && angle < 270 {
            primitive.currentMotion = 0
        } else if angle >= 90 && angle < 180 {
            primitive.currentMotion = 1
        } else if angle >= 0 && angle < 90 {
            primitive.currentMotion = 2
        } else {
            primitive.currentMotion = 3
        }
        primitive.initSegment()
        for i in 1..<4 {
            primitive.state.slots[i].life = 0
        }
    }

    // MARK: - EF_RG_COIN (274)

    /// Spawns 4-slot orbiting coin spray (`PP_INTIMIDATE` (43)) for `EF_RG_COIN` (274).
    func texturedSpray(texturePath: String, context: EffectTickContext) {
        guard stateCnt == 0 else {
            return
        }

        _ = context.assets?.texture(atPath: texturePath)

        let primitive = launchPrimitive(.pp_intimidate)
        primitive.state.renderFlag = EffectPrimitiveState.RenderFlag.alpha | EffectPrimitiveState.RenderFlag.customBlend
        primitive.state.duration = duration
        primitive.state.texturePaths = [texturePath]
        position.y -= 12.0

        for index in 0..<4 {
            primitive.state.slots[index].life = 1
            primitive.state.slots[index].vecBNow = deltaPos
            primitive.state.slots[index].process = -18 - Int.random(in: 0..<30)
            primitive.state.slots[index].distance = 12.0
            primitive.state.slots[index].height[0] = 1.5
            primitive.state.slots[index].riseAngle = Int16(Int.random(in: 0..<360))
            primitive.state.slots[index].fullDisplayAngle = Int16(Int.random(in: 0..<360))
            primitive.state.slots[index].rotStart = Int16(Int.random(in: 0..<360))
            primitive.state.slots[index].height[2] = Float(Int.random(in: 0..<360))
            primitive.state.slots[index].height[1] = 3.5
            primitive.state.slots[index].alphaB = 0
            primitive.state.slots[index].flag1[0] = 1
        }
    }

    // MARK: - EF_TEIHIT3 (276)

    /// Spawns low-profile 4-slot scatter plates (`44`) for `EF_TEIHIT3` (276).
    func texturedScatterLow(texturePath: String, flag: Int8, context: EffectTickContext) {
        guard stateCnt == 0 else {
            return
        }

        _ = context.assets?.texture(atPath: texturePath)

        let primitive = launchPrimitive(44)
        primitive.state.renderFlag = EffectPrimitiveState.RenderFlag.alpha | EffectPrimitiveState.RenderFlag.customBlend
        primitive.state.duration = duration
        primitive.state.texturePaths = [texturePath]
        position.y -= 9.0

        for index in 0..<4 {
            primitive.state.slots[index].life = 1
            primitive.state.slots[index].process = -20 - Int.random(in: 0..<10)
            primitive.state.slots[index].distance = -10.0
            primitive.state.slots[index].height[0] = 2.0
            primitive.state.slots[index].riseAngle = Int16(Int.random(in: 0..<360))
            primitive.state.slots[index].fullDisplayAngle = Int16(Int.random(in: 0..<360))
            primitive.state.slots[index].height[1] = 1.0
            primitive.state.slots[index].alphaB = 0
            primitive.state.slots[index].flag1[0] = flag
            primitive.state.slots[index].flag1[1] = 16
        }
    }

    // MARK: - EF_BOTTOM_ETERNALCHAOS (280)

    /// Spawns rising glow arc (`50`) for `EF_BOTTOM_ETERNALCHAOS` (280) and `EF_BOTTOM_SIEGFRIED` (285).
    func texturedGlow(texturePath: String, size: Int8, context: EffectTickContext) {
        guard stateCnt == 0 else {
            return
        }

        _ = context.assets?.texture(atPath: texturePath)

        let primitive = launchPrimitive(50)
        primitive.state.renderFlag = EffectPrimitiveState.RenderFlag.alpha | EffectPrimitiveState.RenderFlag.customBlend
        primitive.state.duration = duration
        primitive.state.texturePaths = [texturePath]
        primitive.state.size = Float(size)
        for i in 1..<4 {
            primitive.state.slots[i].life = 0
        }
        primitive.state.slots[0].life = 1
        primitive.state.slots[0].process = 0
        primitive.state.slots[0].fullDisplayAngle = 315
        primitive.state.slots[0].maxHeight = Float(Int.random(in: 0..<10)) + 25.0
        primitive.state.slots[0].rotStart = Int16(Int.random(in: 0..<360))
        primitive.state.slots[0].alphaB = Int16(50 - Int.random(in: 0..<10))
        primitive.state.slots[0].riseAngle = 90
        primitive.state.slots[0].alphaT = Int16(Int.random(in: 0..<360))
        primitive.state.slots[0].vecBNow.y = 0
        primitive.state.slots[0].height = Array(repeating: 0, count: 21)
        primitive.state.slots[0].flag1 = Array(repeating: 0, count: 21)
    }

    // MARK: - EF_POKJUK (297)

    /// Spawns 4-slot firework burst trails (`PP_POKJUK` (52)) for `EF_POKJUK` (297).
    func pokBurst(context: EffectTickContext) {
        guard stateCnt == 0 else {
            return
        }

        let textures = ["effect\\pok1.tga", "effect\\pok3.tga", "effect\\pok2.tga"]
        for path in textures {
            _ = context.assets?.texture(atPath: path)
        }

        let primitive = launchPrimitive(.pp_pokjuk)
        primitive.state.renderFlag = EffectPrimitiveState.RenderFlag.alpha | EffectPrimitiveState.RenderFlag.customBlend
        primitive.state.duration = duration
        primitive.state.totalTexture = 3
        primitive.state.texturePaths = textures
        position.x -= 15.0

        for index in 0..<4 {
            primitive.state.slots[index].life = 1
            primitive.state.slots[index].process = -300 - Int.random(in: 0..<50)
            primitive.state.slots[index].rotStart = Int16(Int.random(in: 0..<360))
            primitive.state.slots[index].vecBNow = position
            primitive.state.slots[index].vecTPre = position
            primitive.state.slots[index].vecTNow = position
            primitive.state.slots[index].vecBPre = position
            primitive.state.slots[index].alphaB = 0
            primitive.state.slots[index].maxHeight = 2.0
            primitive.state.slots[index].flag1[0] = Int8(Int.random(in: 0..<5))
            primitive.state.slots[index].flag1[1] = 0
            primitive.state.slots[index].flag1[3] = 0
            primitive.state.slots[index].flag1[2] = Int8(Int.random(in: 0..<4) * 20)
            primitive.state.slots[index].distance = Float(Int.random(in: 0..<100)) * 0.004 + 0.4
            primitive.state.slots[index].fullDisplayAngle = Int16(Int.random(in: 0..<360))
            primitive.state.slots[index].riseAngle = Int16(Int.random(in: 0..<360))
        }
    }

    // MARK: - EF_THROWITEM (298)

    /// Spawns arcing thrown item (`PP_THROWITEM` (53)) for `EF_THROWITEM` (298), `EF_THROWITEM2` (299), and `EF_THROWITEM3` (308).
    func throwItem(texturePath: String, kind: Int8, context: EffectTickContext) {
        let targetFrame: Int = switch kind {
        case 10: 5
        case 11: 10
        default: 0
        }
        guard stateCnt == targetFrame else {
            return
        }

        _ = context.assets?.texture(atPath: texturePath)

        let (origin, destination) = directionalLaunchEndpoints()
        let dx = destination.x - origin.x
        let dz = destination.z - origin.z
        let travelDistance = max(0.001, sqrtf(dx * dx + dz * dz))

        let primitive = launchPrimitive(.pp_throwitem)
        primitive.state.renderFlag = EffectPrimitiveState.RenderFlag.alpha | EffectPrimitiveState.RenderFlag.customBlend
        primitive.state.duration = duration
        primitive.state.texturePaths = [texturePath]
        primitive.state.size = 0
        primitive.state.deltaPos = destination
        primitive.state.slots[0].life = 1
        primitive.state.slots[0].process = 0
        primitive.state.slots[0].maxHeight = travelDistance
        primitive.state.slots[0].distance = switch kind {
        case 2: 2.0
        case 3: 4.0
        default: 3.0
        }
        primitive.state.slots[0].height[8] = 0
        primitive.state.slots[0].alphaB = 255
        primitive.state.slots[0].vecBNow = SIMD3<Float>(origin.x, 0, origin.z)
        primitive.state.slots[0].vecBPre.y = origin.y - 8.0
        primitive.state.slots[0].rotStart = 0
        let stepSpeed: Float = switch kind {
        case 2: 2.0
        case 3: 3.0
        default: max(0.001, travelDistance / 25.0)
        }
        primitive.state.slots[0].height[1] = stepSpeed
        primitive.state.slots[0].height[2] = (stepSpeed / travelDistance) * (destination.y - origin.y)
        primitive.state.slots[0].fullDisplayAngle = kind == 3 ? 330 : 0
        primitive.state.slots[0].flag1[0] = 0
        primitive.state.slots[0].height[7] = 0

        if kind == 0 {
            primitive.state.slots[0].flag1[2] = 8
        } else if kind == 1 {
            primitive.state.slots[0].flag1[2] = 9
            primitive.state.slots[0].flag1[3] = Int8(clamping: count)
        } else if kind >= 10 {
            primitive.state.slots[0].flag1[2] = 9
            primitive.state.slots[0].flag1[3] = 4
        } else if kind == 2 {
            primitive.state.slots[0].flag1[2] = 0
        } else if kind == 3 {
            primitive.state.slots[0].flag1[2] = 15
        }

        for stepIndex in 0..<100 {
            if travelDistance < Float(stepIndex) * stepSpeed {
                primitive.state.slots[0].flag1[1] = Int8(stepIndex)
                break
            }
        }

        for i in 1..<4 {
            primitive.state.slots[i].life = 1
            primitive.state.slots[i].alphaB = 0
        }
    }
}
