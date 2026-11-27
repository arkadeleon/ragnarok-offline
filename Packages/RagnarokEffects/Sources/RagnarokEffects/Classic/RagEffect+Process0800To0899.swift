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
        .ef_redline,
        .ef_frostdiver3,
        .ef_bottom_basilica2,
        .ef_recognized,
        .ef_tetra,
        .ef_tetracasting,
        .ef_fireball3,
        .ef_intimidate3,
        .ef_recognized2,
        .ef_cloaking3,
        .ef_intimidate4,
        .ef_stretch,
        .ef_blackbody,
        .ef_enervation,
        .ef_enervation2,
        .ef_enervation3,
        .ef_enervation4,
        .ef_enervation5,
        .ef_enervation6,
        .ef_linelink4,
        .ef_rg_coin5,
        .ef_waterfall_ani,
        .ef_bottom_manhole,
        .ef_manhole,
        .ef_makefeint,
        .ef_forestlight6,
        .ef_darkcasting2,
        .ef_bottom_ani,
        .ef_bottom_maelstrom,
        .ef_bottom_bloodylust,
        .ef_beginspell_n1,
        .ef_beginspell_n2,
        .ef_heal_n,
        .ef_chookgi_n,
        .ef_joblvup50_2,
        .ef_chemical2dash2,
        .ef_chemical2dash3,
        .ef_water_below,
        .ef_water_fade,
        .ef_beginspell_n3,
        .ef_beginspell_n4,
        .ef_beginspell_n5,
        .ef_beginspell_n6,
        .ef_beginspell_n7,
        .ef_beginspell_n8,
        .ef_water_smoke,
        .ef_dance1,
        .ef_dance2,
        .ef_linkparticle,
        .ef_soullight2,
        .ef_spr_particle,
        .ef_spr_particle2,
        .ef_spr_plant,
        .ef_chemical_v,
        .ef_bot_reverb,
        .ef_rain_particle,
        .ef_chemical_v2,
        .ef_secra,
        .ef_bot_reverb2,
        .ef_circlepower2,
        .ef_secra2,
        .ef_chemical_v3,
        .ef_enervation7,
        .ef_circlepower3,
        .ef_spr_plant2,
        .ef_circlepower4,
        .ef_spr_plant3,
        .ef_rg_coin6,
        .ef_spr_plant4,
        .ef_circlepower5,
        .ef_spr_plant5,
        .ef_circlepower6,
        .ef_spr_plant6,
        .ef_circlepower7,
        .ef_spr_plant7,
        .ef_circlepower8,
        .ef_spr_plant8,
        .ef_heartasura,
        .ef_beginspell_150,
        .ef_level99_150,
        .ef_primecharge,
        .ef_glasswall4,
        .ef_gradius_laser,
        .ef_bash3d6,
        .ef_gumgang5,
        .ef_hitline8,
        .ef_electric4,
        .ef_teihit1t,
        .ef_spinmove,
        .ef_fireball4,
        .ef_tripleattack4,
        .ef_chemical3s,
        .ef_groundshake,
        .ef_dq9_charge,
        .ef_dq9_charge2,
        .ef_dq9_charge3,
        .ef_dq9_charge4,
        .ef_blueline,
    ]

    func process0800To0899(context: EffectTickContext) -> Bool {
        switch effectID {
        case .ef_redline:
            for _ in 0..<3 {
                texturedSpreadFlat(texturePath: "effect\\ring_red.tga", kind: 3, context: context)
            }
        case .ef_frostdiver3:
            frostDiver(type: 3, context: context)
        case .ef_bottom_basilica2:
            if stateCnt == 6 {
                context.world.playSound(
                    named: "effect\\wl_whiteimprison.wav",
                    atWorldPosition: EffectSpace.toWorldPosition(position),
                    delay: 0
                )
            }
            texturedFourRing(texturePath: "effect\\alpha_down.tga", kind: 20, context: context)
            texturedFourRing(texturePath: "effect\\alpha_down.tga", kind: 21, context: context)
        case .ef_recognized:
            for index in 0..<10 {
                texturedSkillIcon(texturePath: "", level: Int16(index * 30 + 1), mode: 0, context: context)
            }
        case .ef_tetra:
            if stateCnt == 0 || stateCnt == 40 || stateCnt == 80 {
                context.world.shakeCamera(amplitude: 1.0, duration: 0.35, frequency: 20.0)
            }
            tetraVortexPillar(kind: 4, context: context)
            for _ in 0..<7 {
                texturedSpread(texturePath: "effect\\ring_red.tga", kind: 10, context: context)
            }
        case .ef_tetracasting:
            if stateCnt == 0 {
                context.world.playSound(
                    named: "effect\\EF_BeginSpell.wav",
                    atWorldPosition: EffectSpace.toWorldPosition(position),
                    delay: 0
                )
            }
            if let targetID = targetObjectID ?? ownerObjectID {
                let color = SIMD4<Float>(
                    Float(Int.random(in: 0..<256)) / 255.0,
                    Float(Int.random(in: 0..<256)) / 255.0,
                    Float(Int.random(in: 0..<256)) / 255.0,
                    1.0
                )
                context.world.applyTargetModifier(.tint(color: color, durationTicks: 2), to: targetID)
            }
            texturedQuadRing(baseAlpha: 25, texturePath: "effect\\ring_white.tga", kind: 0, context: context)
            texturedQuadRing(baseAlpha: 45, texturePath: "effect\\ring_white.tga", kind: 0, context: context)
        case .ef_fireball3:
            rocketPunch(context: context)
        case .ef_intimidate3:
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
                whiteSpray(kind: 3, context: context)
            }
        case .ef_recognized2:
            for index in 0..<5 {
                texturedSkillIcon(texturePath: "", level: Int16(index * 30 + 1), mode: 2, context: context)
            }
        case .ef_cloaking3:
            assassinCloakingClear(context: context)
        case .ef_intimidate4:
            if stateCnt == 25 {
                context.world.playSound(
                    named: "effect\\triangle.wav",
                    atWorldPosition: EffectSpace.toWorldPosition(position),
                    delay: 0
                )
            }
            for _ in 0..<10 {
                whiteSpray(kind: 4, context: context)
            }
        case .ef_stretch:
            texturedDescendingRings(texturePath: "effect\\freezing_stick.bmp", flag: 0, context: context)
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
        case .ef_enervation:
            if stateCnt == 0 {
                configureSTR(path: "enervation.str")
            }
            tintedRisingSparkles(kind: 0, context: context)
            _ = processEZ2STR(offset: SIMD3<Float>(0, -80.0, 0), context: context)
        case .ef_enervation2:
            if stateCnt == 0 {
                configureSTR(path: "groomy.str")
            }
            tintedRisingSparkles(kind: 1, context: context)
            _ = processEZ2STR(offset: SIMD3<Float>(0, -80.0, 0), context: context)
        case .ef_enervation3:
            if stateCnt == 0 {
                configureSTR(path: "ignorance.str")
            }
            tintedRisingSparkles(kind: 2, context: context)
            _ = processEZ2STR(offset: SIMD3<Float>(0, -80.0, 0), context: context)
        case .ef_enervation4:
            if stateCnt == 0 {
                configureSTR(path: "laziness.str")
            }
            tintedRisingSparkles(kind: 3, context: context)
            _ = processEZ2STR(offset: SIMD3<Float>(0, -80.0, 0), context: context)
        case .ef_enervation5:
            if stateCnt == 0 {
                configureSTR(path: "unlucky.str")
            }
            tintedRisingSparkles(kind: 4, context: context)
            _ = processEZ2STR(offset: SIMD3<Float>(0, -80.0, 0), context: context)
        case .ef_enervation6:
            if stateCnt == 0 {
                configureSTR(path: "weakness.str")
            }
            tintedRisingSparkles(kind: 5, context: context)
            _ = processEZ2STR(offset: SIMD3<Float>(0, -80.0, 0), context: context)
        case .ef_linelink4:
            trackCloud(kind: 2, context: context)
        case .ef_rg_coin5:
            if stateCnt == 1 || stateCnt == 11 || stateCnt == 21 || stateCnt == 31 {
                context.world.playSound(
                    named: K2L("effect\\복호격.wav"),
                    atWorldPosition: EffectSpace.toWorldPosition(position),
                    delay: 0
                )
            }
            texturedSprayKind(texturePath: K2L("유저인터페이스\\item\\갈색반지.bmp"), spin: 5.0, kind: 1, context: context)
            texturedSprayKind(texturePath: K2L("유저인터페이스\\item\\금반지.bmp"), spin: 5.0, kind: 1, context: context)
            texturedSprayKind(texturePath: K2L("유저인터페이스\\item\\금방울.bmp"), spin: 5.0, kind: 1, context: context)
            texturedSprayKind(texturePath: K2L("유저인터페이스\\item\\꽃반지.bmp"), spin: 5.0, kind: 1, context: context)
            texturedSprayKind(texturePath: K2L("유저인터페이스\\item\\낡은펜던트.bmp"), spin: 5.0, kind: 1, context: context)
            texturedSprayKind(texturePath: K2L("유저인터페이스\\item\\눈구슬반지.bmp"), spin: 5.0, kind: 1, context: context)
            texturedSprayKind(texturePath: K2L("유저인터페이스\\item\\상자.bmp"), spin: 4.0, kind: 1, context: context)
            texturedSprayKind(texturePath: K2L("유저인터페이스\\item\\수제초콜렛.bmp"), spin: 5.0, kind: 1, context: context)
        case .ef_waterfall_ani:
            waterBubble(context: context)
        case .ef_bottom_manhole:
            texturedHalo(texturePath: "effect\\twirl.bmp", kind: 4, context: context)
            whiteRingRipple(size: 0, context: context)
        case .ef_manhole:
            if let targetID = targetObjectID ?? ownerObjectID {
                context.world.applyTargetModifier(.alpha(0.0, durationTicks: 2), to: targetID)
            }
        case .ef_makefeint:
            let tintRGB = deltaPos2 == .zero ? SIMD3<Float>(250, 250, 250) : deltaPos2
            spawnHallucinationOnce(tintRGB: tintRGB, context: context)
        case .ef_forestlight6:
            if stateCnt == 1 {
                context.world.playSound(
                    named: "effect\\dimension.wav",
                    atWorldPosition: EffectSpace.toWorldPosition(position),
                    delay: 0
                )
            }
            forestLight(texturePath: "effect\\cloud11.tga", flag: 13, context: context)
            texturedHalo(texturePath: K2L("effect\\구체15.bmp"), kind: 4, context: context)
            whiteRingRipple(size: 0, context: context)
        case .ef_darkcasting2:
            blackSpellRings(silent: 2, context: context)
        case .ef_bottom_ani:
            torchDustRing(kind: 0, angle: 0, context: context)
            whiteRingRipple(size: 1, context: context)
        case .ef_bottom_maelstrom:
            let flare: String
            let ring0: String
            let ring1: String
            if context.usesMinimalEffects {
                flare = "effect\\mineffect\\new_maelstrom\\new_maelstrom\\mae_flare_00.bmp"
                ring0 = "effect\\mineffect\\new_maelstrom\\new_maelstrom\\mae_ring_00.tga"
                ring1 = "effect\\mineffect\\new_maelstrom\\new_maelstrom\\mae_ring_01.tga"
            } else {
                flare = "effect\\new_maelstrom\\new_maelstrom\\mae_flare_00.bmp"
                ring0 = "effect\\new_maelstrom\\new_maelstrom\\mae_ring_00.tga"
                ring1 = "effect\\new_maelstrom\\new_maelstrom\\mae_ring_01.tga"
            }
            texturedHalo(texturePath: flare, kind: 10, context: context)
            texturedHalo(texturePath: ring0, kind: 11, context: context)
            texturedHalo(texturePath: ring1, kind: 12, context: context)
        case .ef_bottom_bloodylust:
            torchDustRing(kind: 1, angle: 0, context: context)
            torchDustRing(kind: 1, angle: 120, context: context)
            torchDustRing(kind: 1, angle: 240, context: context)
            whiteRingRipple(size: 2, context: context)
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
        case .ef_beginspell_n2:
            beginSpellSwirl(alpha: 0, context: context)
            texturedTwinSpin(texturePath: "effect\\cir0002.bmp", kind: 3, context: context)
        case .ef_heal_n:
            if stateCnt >= 4 && stateCnt <= 52, let targetID = targetObjectID ?? ownerObjectID {
                let color = stateCnt % 2 == 0
                    ? SIMD4<Float>(5.0 / 255.0, 5.0 / 255.0, 1.0, 1.0)
                    : SIMD4<Float>(1.0, 1.0, 1.0, 1.0)
                context.world.applyTargetModifier(.tint(color: color, durationTicks: 2), to: targetID)
            }
            bubbleFanSweep(rising: 0, context: context)
        case .ef_chookgi_n:
            thunderFreeze(context: context)
        case .ef_joblvup50_2:
            _ = jobLvUp50(angle: 0, context: context)
            _ = jobLvUp50(angle: 45, context: context)
        case .ef_chemical2dash2:
            for _ in 0..<4 {
                lineStreakLayered(kind: 10, context: context)
                lineStreakLayered(kind: 11, context: context)
            }
            if stateCnt == 44 {
                context.world.shakeCamera(amplitude: 1.0, duration: 0.35, frequency: 20.0)
            }
            if stateCnt >= 20 && stateCnt <= 100, let targetID = targetObjectID ?? ownerObjectID {
                context.world.applyTargetModifier(
                    .tint(color: SIMD4<Float>(1.0, 1.0, 150.0 / 255.0, 1.0), durationTicks: 2),
                    to: targetID
                )
            }
        case .ef_chemical2dash3:
            for _ in 0..<4 {
                lineStreakTextured(kind: 10, texturePath: "effect\\throw.bmp", context: context)
                lineStreakTextured(kind: 11, texturePath: "effect\\throw.bmp", context: context)
            }
        case .ef_water_below:
            torchDustRing(kind: 2, angle: 0, context: context)
        case .ef_water_fade:
            texturedDualSpin(
                firstTexturePath: "effect\\W_Comp_00.tga",
                secondTexturePath: "effect\\W_Comp_24.tga",
                context: context
            )
        case .ef_beginspell_n3:
            beginSpellSwirl(alpha: 3, context: context)
        case .ef_beginspell_n4:
            beginSpellSwirl(alpha: 4, context: context)
        case .ef_beginspell_n5:
            beginSpellSwirl(alpha: 5, context: context)
        case .ef_beginspell_n6:
            beginSpellSwirl(alpha: 6, context: context)
        case .ef_beginspell_n7:
            beginSpellSwirl(alpha: 7, context: context)
        case .ef_beginspell_n8:
            beginSpellSwirl(alpha: 8, context: context)
        case .ef_water_smoke:
            for _ in 0..<40 {
                frostSplash(context: context)
            }
        case .ef_dance1:
            if stateCnt >= 4 && stateCnt <= 90, let targetID = targetObjectID ?? ownerObjectID {
                let color = stateCnt % 2 == 0
                    ? SIMD4<Float>(1.0, 89.0 / 255.0, 182.0 / 255.0, 1.0)
                    : SIMD4<Float>(1.0, 1.0, 1.0, 1.0)
                context.world.applyTargetModifier(.tint(color: color, durationTicks: 2), to: targetID)
            }
            risingSparkles(colorMode: 1, context: context)
        case .ef_dance2:
            if stateCnt >= 4 && stateCnt <= 90, let targetID = targetObjectID ?? ownerObjectID {
                let color = stateCnt % 2 == 0
                    ? SIMD4<Float>(182.0 / 255.0, 89.0 / 255.0, 1.0, 1.0)
                    : SIMD4<Float>(1.0, 1.0, 1.0, 1.0)
                context.world.applyTargetModifier(.tint(color: color, durationTicks: 2), to: targetID)
            }
            risingSparkles(colorMode: 2, context: context)
        case .ef_linkparticle:
            texturedTumbleOrb(texturePath: "effect\\whitelight.tga", flag: 0, context: context)
        case .ef_soullight2:
            texturedStorm2(texturePath: "effect\\whitelight.tga", kind: 2, context: context)
        case .ef_spr_particle:
            mavka(flag: 0, context: context)
        case .ef_spr_particle2:
            mavka(flag: 2, context: context)
        case .ef_spr_plant:
            monsterSpriteBurst(kind: 0, context: context)
        case .ef_chemical_v:
            texturedBeam(flag: 0, texturePath: "effect\\line3.tga", context: context)
            texturedForkBolt(texturePath: "effect\\melody_a.bmp", flag: 0, context: context)
            texturedForkBolt(texturePath: "effect\\melody_b.bmp", flag: 0, context: context)
        case .ef_bot_reverb:
            texturedDrop(texturePath: "effect\\melody_a.bmp", flag: 0, context: context)
        case .ef_rain_particle:
            texturedFloatingDust(texturePath: K2L("effect\\번개1.bmp"), context: context)
        case .ef_chemical_v2:
            texturedBeam(flag: 1, texturePath: "effect\\line3.tga", context: context)
            texturedForkBolt(texturePath: "effect\\melody_a.bmp", flag: 1, context: context)
            texturedForkBolt(texturePath: "effect\\melody_b.bmp", flag: 1, context: context)
        case .ef_secra:
            texturedSlam(texturePath: "effect\\priest_spell.bmp", kind: 1, context: context)
        case .ef_bot_reverb2:
            texturedDrop(texturePath: "effect\\melody_a.bmp", flag: 1, context: context)
        case .ef_circlepower2:
            texturedTwinkleRing(texturePath: "effect\\freeze_a.bmp", level: 2, context: context)
        case .ef_secra2:
            texturedSlam(texturePath: "effect\\priest_spell.bmp", kind: 2, context: context)
        case .ef_chemical_v3:
            texturedBeam(flag: 2, texturePath: "effect\\line3.tga", context: context)
        case .ef_enervation7:
            if stateCnt >= 4 && stateCnt <= 90, let targetID = targetObjectID ?? ownerObjectID {
                let color = stateCnt % 2 == 0
                    ? SIMD4<Float>(182.0 / 255.0, 89.0 / 255.0, 1.0, 1.0)
                    : SIMD4<Float>(1.0, 1.0, 1.0, 1.0)
                context.world.applyTargetModifier(.tint(color: color, durationTicks: 2), to: targetID)
            }
            risingSparkles(colorMode: 2, context: context)
            tintedRisingSparkles(kind: 6, context: context)
        case .ef_circlepower3:
            texturedTwinkleRing(texturePath: "effect\\freeze_a.bmp", level: 3, context: context)
        case .ef_spr_plant2:
            monsterSpriteBurst(kind: 2, context: context)
        case .ef_circlepower4:
            texturedTwinkleRing(texturePath: "effect\\freeze_a.bmp", level: 4, context: context)
        case .ef_spr_plant3:
            monsterSpriteBurst(kind: 3, context: context)
        case .ef_rg_coin6:
            if stateCnt == 1 || stateCnt == 11 || stateCnt == 21 || stateCnt == 31 {
                context.world.playSound(
                    named: K2L("effect\\복호격.wav"),
                    atWorldPosition: EffectSpace.toWorldPosition(position),
                    delay: 0
                )
            }
            for _ in 0..<2 {
                texturedSprayKind(texturePath: "effect\\melody_a.bmp", spin: 6.0, kind: 1, context: context)
                texturedSprayKind(texturePath: "effect\\melody_b.bmp", spin: 6.0, kind: 1, context: context)
            }
        case .ef_spr_plant4:
            monsterSpriteBurst(kind: 4, context: context)
        case .ef_circlepower5:
            texturedTwinkleRing(texturePath: "effect\\freeze_a.bmp", level: 5, context: context)
        case .ef_spr_plant5:
            monsterSpriteBurst(kind: 5, context: context)
        case .ef_circlepower6:
            texturedTwinkleRing(texturePath: "effect\\freeze_a.bmp", level: 6, context: context)
        case .ef_spr_plant6:
            monsterSpriteBurst(kind: 6, context: context)
        case .ef_circlepower7:
            texturedTwinkleRing(texturePath: "effect\\freeze_a.bmp", level: 7, context: context)
        case .ef_spr_plant7:
            monsterSpriteBurst(kind: 7, context: context)
        case .ef_circlepower8:
            texturedTwinkleRing(texturePath: "effect\\freeze_a.bmp", level: 8, context: context)
        case .ef_spr_plant8:
            monsterSpriteBurst(kind: 8, context: context)
        case .ef_heartasura:
            texturedSlam(texturePath: "effect\\kiss2.bmp", kind: 2, context: context)
        case .ef_beginspell_150:
            bubbleSpiral(angle: 45, flag: 1, context: context)
            bubbleSpiral(angle: 25, flag: 1, context: context)
        case .ef_level99_150:
            texturedDoubleRing(texturePath: "effect\\emp shock.tga", level: 2, context: context)
            texturedDoubleRing(texturePath: "effect\\cir0002.bmp", level: 3, context: context)
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
        case .ef_glasswall4:
            texturedColumn(texturePath: "effect\\ef_epitree.tga", kind: 30, context: context)
            whiteRingWave(context: context)
            _ = texturedRisingRingStages(texturePath: "effect\\alpha_down.tga", level: 1, context: context)
        case .ef_gradius_laser:
            texturedTripleOrbit(texturePath: "effect\\white02.bmp", context: context)
        case .ef_bash3d6:
            if stateCnt == 5 {
                context.world.playSound(
                    named: K2L("effect\\mon_맹룡과강.wav"),
                    atWorldPosition: EffectSpace.toWorldPosition(position),
                    delay: 0
                )
            }
            for index in 0..<8 {
                texturedQuadSpin(texturePath: "effect\\alpha_center.tga", phase: Int8(index), kind: 6, context: context)
            }
        case .ef_gumgang5:
            texturedCrossKind(texturePath: "effect\\ring_blue.tga", level: 3, context: context)
            if stateCnt <= 30, let targetID = targetObjectID ?? ownerObjectID {
                context.world.applyTargetModifier(
                    .tint(color: SIMD4<Float>(0.0, 0.0, 1.0, 1.0), durationTicks: 2),
                    to: targetID
                )
            }
        case .ef_hitline8:
            whiteSparks(kind: 8, context: context)
        case .ef_electric4:
            electricRing(kind: 0, angle: 0, context: context)
            electricRing(kind: 0, angle: 180, context: context)
        case .ef_teihit1t:
            if stateCnt == 5 {
                context.world.playSound(
                    named: K2L("effect\\mon_맹룡과강.wav"),
                    atWorldPosition: EffectSpace.toWorldPosition(position),
                    delay: 0
                )
            }
            let count = context.usesMinimalEffects ? 6 : 20
            for _ in 0..<count {
                texturedScatter(texturePath: "effect\\alpha_center.tga", flag: 2, context: context)
            }
        case .ef_spinmove:
            if let targetID = targetObjectID ?? ownerObjectID {
                let cumulativeYaw: Float = if stateCnt <= 7 {
                    Float((stateCnt + 1) * 12)
                } else if stateCnt <= 15 {
                    Float(8 * 12 + (stateCnt - 7) * 18)
                } else if stateCnt <= 20 {
                    Float(8 * 12 + 8 * 18 + (stateCnt - 15) * 24)
                } else if stateCnt <= 25 {
                    Float(8 * 12 + 8 * 18 + 5 * 24 + (stateCnt - 20) * 48)
                } else if stateCnt <= 32 {
                    Float(8 * 12 + 8 * 18 + 5 * 24 + 5 * 48 + (stateCnt - 25) * 24)
                } else if stateCnt <= 37 {
                    Float(8 * 12 + 8 * 18 + 5 * 24 + 5 * 48 + 7 * 24 + (stateCnt - 32) * 18)
                } else if stateCnt <= 45 {
                    Float(8 * 12 + 8 * 18 + 5 * 24 + 5 * 48 + 7 * 24 + 5 * 18 + (stateCnt - 37) * 12)
                } else {
                    Float(8 * 12 + 8 * 18 + 5 * 24 + 5 * 48 + 7 * 24 + 5 * 18 + 8 * 12)
                }
                let spinYaw = cumulativeYaw.truncatingRemainder(dividingBy: 360.0)
                context.world.applyTargetModifier(.facingYaw(degrees: spinYaw, durationTicks: 2), to: targetID)
            }
        case .ef_fireball4:
            blueFireballVolley(context: context)
        case .ef_tripleattack4:
            cloudBurst(context: context)
        case .ef_chemical3s:
            for _ in 0..<4 {
                lineStreakKind(kind: 0, context: context)
                lineStreakKind(kind: 1, context: context)
            }
        case .ef_groundshake:
            texturedLevelRing(texturePath: "effect\\explosive_1_128.bmp", process: 0, level: 4, context: context)
        case .ef_dq9_charge:
            texturedSpiral(texturePath: "effect\\alpha_center.tga", context: context)
        case .ef_dq9_charge2:
            texturedSpiralSmall(texturePath: "effect\\shockwave_c.bmp", context: context)
        case .ef_dq9_charge3:
            texturedSpiralTall(texturePath: "effect\\shockwave_c.bmp", context: context)
        case .ef_dq9_charge4:
            texturedSpiralFade(texturePath: "effect\\shockwave_c.bmp", context: context)
        case .ef_blueline:
            for _ in 0..<6 {
                texturedSpreadFlat(texturePath: "effect\\ring_blue.tga", kind: 12, context: context)
            }
        default:
            return false
        }
        return true
    }

    // MARK: - EF_TETRA (804)

    /// Spawns animated Tetra Vortex pillar (`140`) on ticks 0, 25, 50, 75 for `EF_TETRA` (804) and elemental variants.
    func tetraVortexPillar(kind: Int8, context: EffectTickContext) {
        switch stateCnt {
        case 0:
            context.world.playSound(
                named: "effect\\wizard_meteo.wav",
                atWorldPosition: EffectSpace.toWorldPosition(position),
                delay: 0
            )
            context.world.playSound(
                named: "effect\\hunter_blastmine.wav",
                atWorldPosition: EffectSpace.toWorldPosition(position),
                delay: 0
            )
        case 10, 20, 50, 80:
            context.world.playSound(
                named: "effect\\wl_tetravortex.wav",
                atWorldPosition: EffectSpace.toWorldPosition(position),
                delay: 0
            )
        default:
            break
        }

        guard stateCnt <= 80, stateCnt % 25 == 0 else {
            return
        }

        let primitive = launchPrimitive(140)
        primitive.state.renderFlag = EffectPrimitiveState.RenderFlag.alpha | EffectPrimitiveState.RenderFlag.customBlend
        primitive.state.duration = duration
        if kind == 4 {
            let paths = (1...8).map { "effect\\tv-\($0).bmp" }
            primitive.state.totalTexture = paths.count
            primitive.state.texturePaths = paths
            for path in paths {
                _ = context.assets?.texture(atPath: path)
            }
        }

        primitive.state.size = 0
        for i in 1..<4 {
            primitive.state.slots[i].life = 0
        }
        primitive.state.slots[0].life = 1
        primitive.state.slots[0].process = 0
        primitive.state.slots[0].distance = param[0] <= 0 ? 30.0 : param[0]
        primitive.state.slots[0].vecBPre.y = position.y - 10.0

        if kind == 4 {
            switch effectID {
            case .ef_tetra_wind:
                primitive.state.slots[0].flag1[2] = 17
            case .ef_tetra_water:
                primitive.state.slots[0].flag1[2] = 18
            case .ef_tetra_ground:
                primitive.state.slots[0].flag1[2] = 19
            case .ef_tetra_fire:
                primitive.state.slots[0].flag1[2] = 20
            default:
                break
            }
            primitive.state.slots[0].fullDisplayAngle = 120
            primitive.state.slots[0].height[10] = 1.0
        } else {
            primitive.state.slots[0].flag1[2] = 17
            primitive.state.slots[0].fullDisplayAngle = 135
            primitive.state.slots[0].height[10] = 0
        }

        primitive.state.slots[0].height[8] = 0
        primitive.state.slots[0].alphaB = 200
        primitive.state.slots[0].vecBNow = SIMD3<Float>(deltaPos.x, deltaPos.y - 35.0, deltaPos.z)
        primitive.state.slots[0].rotStart = Int16(Int.random(in: 0..<360))
        primitive.state.slots[0].flag1[0] = 0
        primitive.state.slots[0].flag1[4] = kind
    }

    /// Spawns 4-slot radial height-ramp spread (`137`) anchored toward `deltaPos` for `EF_TETRA` (804).
    func texturedSpread(texturePath: String, kind: Int8, context: EffectTickContext) {
        guard stateCnt == 0 else {
            return
        }

        _ = context.assets?.texture(atPath: texturePath)

        let primitive = launchPrimitive(137)
        primitive.state.renderFlag = EffectPrimitiveState.RenderFlag.alpha | EffectPrimitiveState.RenderFlag.customBlend
        primitive.state.duration = duration
        primitive.state.totalTexture = 1
        primitive.state.texturePaths = [texturePath]

        if kind <= 1 {
            primitive.state.size = 4.0
        } else if kind == 2 {
            primitive.state.size = 7.0
        } else if kind == 3 {
            primitive.state.size = 6.0
        } else if kind == 10 {
            primitive.state.size = Float(Int.random(in: 0..<5) + 4)
        } else if kind == 11 {
            primitive.state.size = 5.0
        }

        let offsetToDelta = deltaPos - position
        for index in 0..<4 {
            primitive.state.slots[index].life = 1
            primitive.state.slots[index].fullDisplayAngle = 360
            primitive.state.slots[index].rotStart = Int16(index * 90)
            let radius: Float
            if kind == 11 {
                primitive.state.slots[index].alphaB = 50
                primitive.state.slots[index].maxHeight = Float(index * 20) + 60.0
                primitive.state.slots[index].process = Int.random(in: 0..<40) + 60
                radius = Float(Int.random(in: 0..<31)) * 0.1 + 6.0
            } else {
                primitive.state.slots[index].alphaB = 150
                primitive.state.slots[index].maxHeight = 120.0
                if kind == 10 {
                    primitive.state.slots[index].process = Int.random(in: 0..<100)
                    radius = Float(Int.random(in: 0..<41))
                } else {
                    primitive.state.slots[index].process = Int.random(in: 0..<40) + 60
                    radius = 5.0
                }
            }

            let angle = Int.random(in: 0..<360)
            primitive.state.slots[index].vecBNow = SIMD3<Float>(
                radius * EffectSpace.cosine(degrees: angle),
                0,
                radius * EffectSpace.sine(degrees: angle)
            )
            primitive.state.slots[index].distance = Float(Int.random(in: 0..<11)) * 0.015 + 0.15
            primitive.state.slots[index].alphaT = 0
            primitive.state.slots[index].riseAngle = 90
            primitive.state.slots[index].height = Array(repeating: 0, count: 21)
            primitive.state.slots[index].flag1 = Array(repeating: 0, count: 21)
            primitive.state.slots[index].vecTPre = offsetToDelta
        }
    }

    // MARK: - EF_TETRACASTING (805)

    /// Spawns 4-layer breathing-wave rings (`139`) for `EF_TETRACASTING` (805).
    func texturedQuadRing(baseAlpha: Int16, texturePath: String, kind: Int8, context: EffectTickContext) {
        guard stateCnt == 0 else {
            return
        }

        if duration < 56 {
            duration = 56
        }

        _ = context.assets?.texture(atPath: texturePath)

        let primitive = launchPrimitive(139)
        primitive.state.renderFlag = EffectPrimitiveState.RenderFlag.alpha | EffectPrimitiveState.RenderFlag.customBlend
        primitive.state.duration = duration
        primitive.state.totalTexture = 1
        primitive.state.texturePaths = [texturePath]
        primitive.state.size = 4.0

        let baseHeight: Float = if kind == 2 {
            25.0
        } else if kind == 22 {
            15.0
        } else {
            20.0
        }

        let configs: [(rotStart: Int16, alphaOffset: Int16)] = [
            (180, 135),
            (270, 90),
            (0, 45),
            (90, 0),
        ]

        for (index, config) in configs.enumerated() {
            primitive.state.slots[index].life = 1
            primitive.state.slots[index].process = duration <= 60 ? index * -5 : 0
            primitive.state.slots[index].fullDisplayAngle = 360
            primitive.state.slots[index].maxHeight = baseHeight - Float(index)
            primitive.state.slots[index].rotStart = config.rotStart
            primitive.state.slots[index].alphaB = duration <= 60 ? 0 : (baseAlpha + config.alphaOffset)
            primitive.state.slots[index].distance = 4.1
            primitive.state.slots[index].riseAngle = 80
            primitive.state.slots[index].alphaT = Int16(kind)
            primitive.state.slots[index].vecBNow.y = 0
            primitive.state.slots[index].height = Array(repeating: 0, count: 21)
            primitive.state.slots[index].flag1 = Array(repeating: 0, count: 21)
        }
    }

    // MARK: - EF_FIREBALL3 (806)

    /// Spawns directional rocket-punch sprite volleys (`PP_3DPARTICLE` (5)) on ticks 0, 2, 4, 6 for `EF_FIREBALL3` (806).
    func rocketPunch(context: EffectTickContext) {
        guard stateCnt == 0 || stateCnt == 2 || stateCnt == 4 || stateCnt == 6 else {
            return
        }

        let spritePath = K2L("이팩트\\남_로켓트펀치.spr")
        let actionPath = K2L("이팩트\\남_로켓트펀치.act")
        _ = context.assets?.spriteAsset(spritePath: spritePath, actionPath: actionPath)

        let primitive = launchPrimitive(.pp_3dparticle)
        primitive.state.duration = 20
        primitive.state.pattern |= 0x100
        primitive.state.deltaPos2 = SIMD3<Float>(0, -15.0, 0)

        var face = Self.effectHeading(fromX: position.x, fromZ: position.z, toX: deltaPos.x, toZ: deltaPos.z)
        primitive.state.longitude = -face
        if face < 0 {
            face += 360.0
        }
        primitive.angle = face

        let dist = Self.effectDistanceXZ(from: position, to: deltaPos)
        primitive.state.speed = -(dist / Float(primitive.state.duration))
        primitive.state.transform = EffectSpace.rotationY(radians: EffectSpace.radian(degrees: Int(primitive.state.longitude)))
        primitive.state.size = 1.0
        primitive.state.animSpeed = 1
        if stateCnt == 0 {
            primitive.state.pattern |= 0x200
        } else {
            primitive.state.alpha = Float((8 - stateCnt) * 10)
        }

        primitive.state.spritePath = spritePath
        primitive.state.actionPath = actionPath

        let rawAngle = Int(EffectPrimitive.angle(dx: position.x - deltaPos.x, dy: position.z - deltaPos.z))
        var angle = (Int(context.world.cameraYawDegrees) + rawAngle) % 360
        if angle < 0 {
            angle += 360
        }

        let actionIndex: Int = if angle >= 180 && angle < 270 {
            4
        } else if angle >= 90 && angle < 180 {
            6
        } else if angle >= 0 && angle < 90 {
            0
        } else {
            2
        }
        primitive.previousAnimation = actionIndex
        primitive.currentMotion = 0
        primitive.initSegment()
    }

    // MARK: - EF_STRETCH (811)

    /// Spawns 4-layer descending rings (`141`) for `EF_STRETCH` (811).
    func texturedDescendingRings(texturePath: String, flag: Int8, context: EffectTickContext) {
        guard stateCnt == 0 else {
            return
        }

        _ = context.assets?.texture(atPath: texturePath)

        let primitive = launchPrimitive(141)
        primitive.state.renderFlag = EffectPrimitiveState.RenderFlag.alpha | EffectPrimitiveState.RenderFlag.customBlend
        primitive.state.duration = duration
        primitive.state.totalTexture = 1
        primitive.state.texturePaths = [texturePath]
        primitive.state.size = 0

        let yOffsets: [Float] = [-30.0, -20.0, -10.0, 0.0]
        for i in 0..<4 {
            primitive.state.slots[i].life = 1
            primitive.state.slots[i].process = i * -10
            primitive.state.slots[i].distance = 20.0
            primitive.state.slots[i].flag1[2] = 2
            primitive.state.slots[i].vecBPre.y = position.y + yOffsets[i]
            primitive.state.slots[i].fullDisplayAngle = 215
            primitive.state.slots[i].height[8] = 0
            primitive.state.slots[i].alphaB = 255
            primitive.state.slots[i].vecBNow.x = position.x
            primitive.state.slots[i].vecBNow.z = position.z
            primitive.state.slots[i].rotStart = 0
            primitive.state.slots[i].flag1[0] = 0
            primitive.state.slots[i].flag1[4] = flag
        }
    }

    // MARK: - EF_ENERVATION (813...818, 864)

    /// Spawns randomly tinted rising cross-texture sparkles (`PP_3DCROSSTEXTURE` (16)) every 2 ticks for `EF_ENERVATION...7`.
    func tintedRisingSparkles(kind: Int8, context: EffectTickContext) {
        guard (stateCnt & 1) == 0 else {
            return
        }

        let texturePath = "effect\\ac_center2.tga"
        _ = context.assets?.texture(atPath: texturePath)

        let primitive = launchPrimitive(.pp_3dcrosstexture)
        primitive.state.duration = 50
        let yaw = EffectSpace.rotationY(radians: EffectSpace.radian(degrees: Int.random(in: 0..<360)))
        var offset = EffectSpace.transformVector(SIMD3<Float>(0, 0, Float(Int.random(in: 0..<7) + 3)), by: yaw)
        offset.y -= 20.0
        primitive.state.deltaPos2 = offset
        primitive.state.transform = EffectSpace.rotationX(radians: EffectSpace.radian(degrees: -90))
        primitive.state.accel = 0.015
        primitive.state.widthSize = Float(Int.random(in: 0..<60) + 30) / 10.0
        primitive.state.heightSize = 0.18
        primitive.state.alpha = 0
        primitive.state.maxAlpha = 200.0
        primitive.state.red = Int.random(in: 0..<3) == 0 ? 255 : 140
        primitive.state.green = Int.random(in: 0..<3) == 0 ? 255 : 140
        primitive.state.blue = Int.random(in: 0..<3) == 0 ? 255 : 140
        primitive.state.alphaSpeed = primitive.state.maxAlpha / 20.0
        primitive.state.fadeOutCnt = primitive.state.duration - 20
        primitive.state.totalTexture = 1
        primitive.state.texturePaths = [texturePath]
        primitive.state.slots[0].life = 0
    }

    // MARK: - EF_WATERFALL_ANI (821)

    /// Spawns 117-frame animated waterfall panels (`142`) for `EF_WATERFALL_ANI` (821).
    func waterBubble(context: EffectTickContext) {
        guard stateCnt == 0 else {
            return
        }

        var paths: [String] = []
        paths.reserveCapacity(117)
        for index in 0..<30 {
            paths.append(String(format: "effect\\W_C_water_%02d.tga", index))
        }
        for index in 0..<30 {
            paths.append(String(format: "effect\\W_B_water_%02d.tga", index))
        }
        for index in 0..<27 {
            paths.append(String(format: "effect\\W_bubble%02d.tga", index + 1))
        }
        for index in 0..<30 {
            paths.append(String(format: "effect\\W_A_water_%02d.tga", index))
        }
        for path in paths {
            _ = context.assets?.texture(atPath: path)
        }

        let primitive = launchPrimitive(142)
        primitive.state.renderFlag = EffectPrimitiveState.RenderFlag.alpha | EffectPrimitiveState.RenderFlag.customBlend
        primitive.state.duration = duration
        primitive.state.totalTexture = paths.count
        primitive.state.texturePaths = paths

        for i in 1..<4 {
            primitive.state.slots[i].life = 0
        }
        primitive.state.slots[0].life = 1
        primitive.state.slots[0].process = 0
        primitive.state.slots[0].alphaB = 230
        primitive.state.slots[0].vecBNow.z = 0
        primitive.state.slots[0].distance = param[0] < 20.0 ? 40.0 : param[0]
        primitive.state.slots[0].rotStart = param[1] >= 360.0 ? 0 : Int16(param[1])
    }

    // MARK: - EF_BOTTOM_MANHOLE (822)

    /// Spawns periodic portal ripples (`63`) every 100 ticks for `EF_BOTTOM_MANHOLE` (822), `EF_FORESTLIGHT6` (825), `EF_BOTTOM_ANI` (827), and `EF_BOTTOM_BLOODYLUST` (829).
    func whiteRingRipple(size: Int8, context: EffectTickContext) {
        guard stateCnt % 100 == 0 else {
            return
        }

        let texturePath = "effect\\ring_white.tga"
        _ = context.assets?.texture(atPath: texturePath)

        let primitive = launchPrimitive(63)
        primitive.state.renderFlag = EffectPrimitiveState.RenderFlag.alpha | EffectPrimitiveState.RenderFlag.customBlend
        primitive.state.duration = duration
        primitive.state.totalTexture = 1
        primitive.state.texturePaths = [texturePath]
        if size == 1 {
            primitive.state.size = 8.0
        } else if size == 2 {
            primitive.state.size = 6.0
        } else {
            primitive.state.size = 4.0
        }

        let configs: [(process: Int, rotStart: Int16, riseAngle: Int16)] = [
            (0, 0, 2),
            (-10, 25, 3),
            (-20, 50, 4),
        ]
        for (index, config) in configs.enumerated() {
            primitive.state.slots[index].life = 1
            primitive.state.slots[index].process = config.process
            primitive.state.slots[index].fullDisplayAngle = 360
            primitive.state.slots[index].maxHeight = 6.001
            primitive.state.slots[index].rotStart = config.rotStart
            primitive.state.slots[index].alphaB = 0
            primitive.state.slots[index].distance = 0
            primitive.state.slots[index].riseAngle = config.riseAngle
            primitive.state.slots[index].alphaT = 100
            primitive.state.slots[index].vecBNow.y = 0
            primitive.state.slots[index].height = Array(repeating: 0, count: 21)
            primitive.state.slots[index].flag1 = Array(repeating: 1, count: 21)
        }
        primitive.state.slots[3].life = 0
        primitive.state.slots[3].process = 0
        primitive.state.slots[3].alphaT = 4
    }

    // MARK: - EF_BOTTOM_ANI (827)

    /// Spawns animated spinning texture disc (`143`) for `EF_BOTTOM_ANI` (827), `EF_BOTTOM_BLOODYLUST` (829), and `EF_WATER_BELOW` (838).
    func torchDustRing(kind: Int8, angle: Int16, context: EffectTickContext) {
        guard stateCnt == 0 else {
            return
        }

        let paths: [String]
        if kind == 1 {
            paths = (1...13).map { String(format: "effect\\torch_red%02d.bmp", $0) }
        } else if kind == 2 {
            paths = (0..<51).map { String(format: "effect\\W_c_%02d.tga", $0) }
        } else {
            paths = (1...9).map { String(format: "effect\\dust%02d.bmp", $0) }
        }
        for path in paths {
            _ = context.assets?.texture(atPath: path)
        }

        let primitive = launchPrimitive(143)
        primitive.state.renderFlag = EffectPrimitiveState.RenderFlag.alpha | EffectPrimitiveState.RenderFlag.customBlend
        primitive.state.duration = duration
        primitive.state.totalTexture = paths.count
        primitive.state.texturePaths = paths

        for i in 1..<4 {
            primitive.state.slots[i].life = 0
        }
        primitive.state.slots[0].life = 1
        primitive.state.slots[0].process = 0

        if kind == 2 {
            primitive.state.slots[0].distance = param[0] < 5.0 ? 20.0 : param[0]
            let start = param[1]
            primitive.state.slots[0].rotStart = (start < 0 || start >= 360) ? 45 : Int16(start)
            primitive.state.slots[0].alphaB = 200
            primitive.state.slots[0].height[2] = 1.0
        } else {
            primitive.state.slots[0].distance = 18.0
            primitive.state.slots[0].rotStart = angle
            primitive.state.slots[0].alphaB = 200
            primitive.state.slots[0].height[2] = 0
        }

        primitive.state.slots[0].riseAngle = Int16(Int.random(in: 0..<360))
        primitive.state.slots[0].height[0] = -2.0
        primitive.state.slots[0].height[1] = 0
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

    // MARK: - EF_BEGINSPELL_N2...N8 (831, 840...845)

    /// Spawns animated wave-height spell swirl (`149`) for `EF_BEGINSPELL_N2...N8`.
    func beginSpellSwirl(alpha: Int8, context: EffectTickContext) {
        guard stateCnt == 0 else {
            return
        }

        context.world.playSound(
            named: "effect\\EF_BeginSpell.wav",
            atWorldPosition: EffectSpace.toWorldPosition(position),
            delay: 0
        )

        if duration < 120 {
            duration = 120
        }

        let paths: [String] = if alpha == 10 {
            (1...4).map { String(format: "effect\\YBfire_%02d.bmp", $0) }
        } else {
            (1...27).map { String(format: "effect\\W_bubble%02d.tga", $0) }
        }
        for path in paths {
            _ = context.assets?.texture(atPath: path)
        }

        let primitive = launchPrimitive(149)
        primitive.state.renderFlag = EffectPrimitiveState.RenderFlag.alpha | EffectPrimitiveState.RenderFlag.customBlend
        primitive.state.duration = duration
        primitive.state.totalTexture = paths.count
        primitive.state.texturePaths = paths
        primitive.state.size = 0

        let configs: [(rotStart: Int16, riseAngle: Int16)] = [
            (180, 75),
            (270, 63),
            (0, 52),
            (90, 40),
        ]
        for (index, config) in configs.enumerated() {
            primitive.state.slots[index].life = 1
            primitive.state.slots[index].process = 0
            primitive.state.slots[index].fullDisplayAngle = 360
            primitive.state.slots[index].maxHeight = 23.0
            primitive.state.slots[index].rotStart = config.rotStart
            primitive.state.slots[index].alphaB = 0
            primitive.state.slots[index].distance = 4.3
            primitive.state.slots[index].riseAngle = config.riseAngle
            primitive.state.slots[index].alphaT = Int16(alpha)
            primitive.state.slots[index].vecBNow.y = 0
            primitive.state.slots[index].height = Array(repeating: 0, count: 21)
            primitive.state.slots[index].flag1 = Array(repeating: 0, count: 21)
        }
    }

    /// Spawns twin counter-rotating ground discs (`161`) for `EF_BEGINSPELL_N2` (831).
    func texturedTwinSpin(texturePath: String, kind: Int8, context: EffectTickContext) {
        guard stateCnt == 0 else {
            return
        }

        _ = context.assets?.texture(atPath: texturePath)

        let primitive = launchPrimitive(161)
        primitive.state.renderFlag = EffectPrimitiveState.RenderFlag.alpha | EffectPrimitiveState.RenderFlag.customBlend
        primitive.state.duration = duration
        primitive.state.totalTexture = 1
        primitive.state.texturePaths = [texturePath]

        if kind == 1 {
            primitive.state.size = 15.0
        } else if kind == 2 {
            primitive.state.size = 17.0
        } else if kind == 3 {
            primitive.state.size = 18.0
        } else {
            primitive.state.size = 4.0
        }

        let distance: Float = kind == 3 ? 24.0 : 15.0
        for i in 0..<2 {
            primitive.state.slots[i].life = 1
            primitive.state.slots[i].distance = distance
            primitive.state.slots[i].process = 0
            primitive.state.slots[i].riseAngle = Int16(i * 180)
            primitive.state.slots[i].alphaB = 200
            primitive.state.slots[i].height[0] = -1.0
        }
        primitive.state.slots[2].life = 0
        primitive.state.slots[3].life = 0
    }

    // MARK: - EF_HEAL_N (832)

    /// Spawns 4-slot sweeping bubble fan (`146`) for `EF_HEAL_N` (832).
    func bubbleFanSweep(rising: Int8, context: EffectTickContext) {
        guard stateCnt == 0 else {
            return
        }

        let paths = (0..<13).map { String(format: "effect\\W_bubble%02d.tga", $0 * 2 + 2) }
        for path in paths {
            _ = context.assets?.texture(atPath: path)
        }

        let primitive = launchPrimitive(146)
        primitive.state.renderFlag = EffectPrimitiveState.RenderFlag.alpha | EffectPrimitiveState.RenderFlag.customBlend
        primitive.state.duration = duration
        primitive.state.totalTexture = paths.count
        primitive.state.texturePaths = paths

        let baseAngle = EffectPrimitive.angle(dx: deltaPos.x - position.x, dy: deltaPos.z - position.z)
        var rotStart = baseAngle + 195
        if rotStart >= 360 {
            rotStart -= 360
        }

        for index in 0..<4 {
            primitive.state.slots[index].life = 1
            primitive.state.slots[index].process = index * -8
            primitive.state.slots[index].maxHeight = 30.0
            primitive.state.slots[index].fullDisplayAngle = 315
            primitive.state.slots[index].rotStart = rotStart
            primitive.state.slots[index].alphaB = 0
            primitive.state.slots[index].distance = 3.0 - Float(index) * 0.1
            primitive.state.slots[index].riseAngle = Int16((14 - index) * 5)
            primitive.state.slots[index].vecBNow.y = 0
            primitive.state.slots[index].vecTNow.x = 0
            primitive.state.slots[index].vecTNow.z = 0
            primitive.state.slots[index].vecTPre.x = rising == 1 ? 7.0 : 0
        }
    }

    // MARK: - EF_CHOOKGI_N (833)

    /// Spawns orbiting thunder-freeze spheres (`145`) based on spirit count in `deltaPos.x` for `EF_CHOOKGI_N` (833).
    func thunderFreeze(context: EffectTickContext) {
        guard stateCnt == 0 else {
            return
        }

        var total = Int(deltaPos.x)
        if total > 5 {
            total = 5
        } else if total <= 0 {
            return
        }

        let textures = ["effect\\thunder_center.bmp", "effect\\freeze_a.bmp"]
        for path in textures {
            _ = context.assets?.texture(atPath: path)
        }

        for bolt in 0..<total {
            let primitive = launchPrimitive(145)
            primitive.state.renderFlag = EffectPrimitiveState.RenderFlag.alpha | EffectPrimitiveState.RenderFlag.customBlend
            primitive.state.duration = duration
            primitive.state.totalTexture = 2
            primitive.state.texturePaths = textures

            primitive.state.slots[0].life = 1
            for h in 0..<6 {
                primitive.state.slots[0].height[h] = Float(Int.random(in: 0..<360))
            }
            primitive.state.slots[0].height[6] = Float(bolt * 360) / deltaPos.x
            primitive.state.slots[0].height[7] = -15.0
            primitive.state.slots[0].distance = 1.0
            primitive.state.slots[0].height[10] = 0
            primitive.state.slots[0].flag1[0] = 1
            primitive.state.slots[0].height[8] = Float(Int.random(in: 0..<360))
            primitive.state.slots[0].alphaB = 0

            for slot in 0..<4 {
                primitive.state.slots[slot].process = -20 * slot
                primitive.state.slots[slot].fullDisplayAngle = Int16(Int.random(in: 0..<360))
                primitive.state.slots[slot].maxHeight = 3.0
                primitive.state.slots[slot].rotStart = Int16(Int.random(in: 0..<360))
                primitive.state.slots[slot].riseAngle = 200
            }
        }
    }

    // MARK: - EF_CHEMICAL2DASH3 (836)

    /// Spawns textured directional line streaks (`PP_CHEMICAL3` (56)) for `EF_CHEMICAL2DASH3` (836).
    func lineStreakTextured(kind: Int16, texturePath: String, context: EffectTickContext) {
        guard stateCnt == 0 else {
            return
        }

        _ = context.assets?.texture(atPath: texturePath)

        let primitive = launchPrimitive(.pp_chemical3)
        primitive.state.renderFlag = EffectPrimitiveState.RenderFlag.alpha | EffectPrimitiveState.RenderFlag.noDepth
        primitive.state.duration = duration
        primitive.state.totalTexture = 1
        primitive.state.texturePaths = [texturePath]

        let mode = Int(kind) % 10
        let riseAngle = EffectPrimitive.angle(dx: deltaPos.x - position.x, dy: deltaPos.z - position.z)

        for index in 0..<4 {
            primitive.state.slots[index].life = 1
            primitive.state.slots[index].process = 0
            primitive.state.slots[index].distance = 100.0
            if mode == 0 {
                primitive.state.slots[index].height[0] = -15.0 - Float(Int.random(in: 0..<11))
            } else if mode == 1 {
                primitive.state.slots[index].height[0] = Float(Int.random(in: 0..<11)) + 15.0
            }
            primitive.state.slots[index].height[1] = Float(Int.random(in: 0..<200))
            primitive.state.slots[index].maxHeight = Float(Int.random(in: 0..<6)) * 0.1 + 0.5
            primitive.state.slots[index].height[2] = Float(Int.random(in: 0..<31)) + 40.0
            primitive.state.slots[index].flag1[0] = Int8(Int.random(in: 0..<3) + 10)
            primitive.state.slots[index].height[3] = Float(Int.random(in: 0..<11)) * 0.1 + 1.0

            if kind >= 20 && kind < 30 {
                primitive.state.slots[index].flag1[0] = Int8(Int.random(in: 0..<3) + 33)
            } else if kind >= 30 && kind < 40 {
                primitive.state.slots[index].flag1[0] = Int8(Int.random(in: 0..<3) + 36)
            }

            primitive.state.slots[index].riseAngle = riseAngle
            primitive.state.slots[index].alphaB = 0
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

    // MARK: - EF_WATER_SMOKE (846)

    /// Spawns falling frost/water mist particles (`150`) for `EF_WATER_SMOKE` (846).
    func frostSplash(context: EffectTickContext) {
        guard stateCnt == 0 else {
            return
        }

        let isWater = Int.random(in: 0..<10) == 0
        let texturePath = isWater ? "effect\\waterp1.tga" : "effect\\freeze_a_small.bmp"
        _ = context.assets?.texture(atPath: texturePath)

        let primitive = launchPrimitive(150)
        primitive.state.renderFlag = EffectPrimitiveState.RenderFlag.alpha | EffectPrimitiveState.RenderFlag.customBlend
        primitive.state.duration = duration
        primitive.state.totalTexture = 1
        primitive.state.texturePaths = [texturePath]
        primitive.state.size = 4.0

        if param[0] < 10.0 {
            param[0] = 10.0
        }
        let riseAngle = Int16(param[0])
        let scale = Float(riseAngle) / 10.0
        let rawAngle = ((Int(param[1]) % 360) + 360) % 360
        let cosVal = EffectSpace.cosine(degrees: rawAngle)
        let sinVal = EffectSpace.sine(degrees: rawAngle)
        let rawColor = param[2] >= 0 ? Int(param[2]) % 1_000_000 : 0
        let c10 = Int8(truncatingIfNeeded: rawColor / 10_000)
        let c11 = Int8(truncatingIfNeeded: (rawColor % 10_000) / 100)
        let c12 = Int8(truncatingIfNeeded: rawColor % 100)

        func randomRotatedPoint() -> SIMD3<Float> {
            let x = Float(Int.random(in: 0..<45) - 22) * scale
            let y = Float(Int.random(in: 0..<30)) * scale
            let z = Float(Int.random(in: 0..<11) - 5) * scale
            return SIMD3<Float>(
                cosVal * x - sinVal * z,
                y,
                sinVal * x + cosVal * z
            )
        }

        for index in 0..<4 {
            primitive.state.slots[index].fullDisplayAngle = Int16(rawAngle)
            primitive.state.slots[index].riseAngle = riseAngle
            primitive.state.slots[index].flag1[10] = c10
            primitive.state.slots[index].flag1[11] = c11
            primitive.state.slots[index].flag1[12] = c12
            primitive.state.slots[index].life = 1
            primitive.state.slots[index].maxHeight = 0.05
            primitive.state.slots[index].distance = scale * (isWater ? 7.0 : 4.5)
            primitive.state.slots[index].vecBPre = randomRotatedPoint()
            primitive.state.slots[index].vecBNow = randomRotatedPoint()
            primitive.state.slots[index].vecTPre = randomRotatedPoint()
            primitive.state.slots[index].vecTNow = randomRotatedPoint()
            for h in 0..<16 {
                primitive.state.slots[index].height[h] = Float(Int.random(in: 0..<360))
            }
            primitive.state.slots[index].flag1[0] = 2
        }
    }

    // MARK: - EF_DANCE1 / EF_DANCE2 (847...848, 864)

    /// Spawns rising cross-texture sparkles (`PP_3DCROSSTEXTURE` (16)) every 2 ticks for `EF_DANCE1`, `EF_DANCE2`, and `EF_ENERVATION7`.
    func risingSparkles(colorMode: Int8, context: EffectTickContext) {
        guard (stateCnt & 1) == 0 else {
            return
        }

        let texturePath = "effect\\ac_center2.tga"
        _ = context.assets?.texture(atPath: texturePath)

        let primitive = launchPrimitive(.pp_3dcrosstexture)
        primitive.state.duration = 50
        let yaw = EffectSpace.rotationY(radians: EffectSpace.radian(degrees: Int.random(in: 0..<360)))
        var offset = EffectSpace.transformVector(SIMD3<Float>(0, 0, Float(Int.random(in: 0..<7) + 3)), by: yaw)
        offset.y -= 5.0
        primitive.state.deltaPos2 = offset
        primitive.state.transform = EffectSpace.rotationX(radians: EffectSpace.radian(degrees: -90))
        primitive.state.accel = -0.015
        primitive.state.widthSize = Float(Int.random(in: 0..<60) + 30) / 10.0
        primitive.state.heightSize = 0.18
        primitive.state.alpha = 0
        primitive.state.maxAlpha = 200.0

        if colorMode == 2 {
            let level = Int.random(in: 0..<256)
            primitive.state.red = level
            primitive.state.green = level
            primitive.state.blue = 255
        } else {
            let level = Int.random(in: 0..<256)
            primitive.state.red = 255
            primitive.state.green = level
            primitive.state.blue = level
        }

        primitive.state.alphaSpeed = primitive.state.maxAlpha / 20.0
        primitive.state.fadeOutCnt = primitive.state.duration - 20
        primitive.state.totalTexture = 1
        primitive.state.texturePaths = [texturePath]
        primitive.state.slots[0].life = 0
    }

    // MARK: - EF_LINKPARTICLE (849)

    /// Spawns orbiting tumble orb (`151`) for `EF_LINKPARTICLE` (849).
    func texturedTumbleOrb(texturePath: String, flag: Int8, context: EffectTickContext) {
        guard stateCnt == 0 else {
            return
        }

        _ = context.assets?.texture(atPath: texturePath)

        let primitive = launchPrimitive(151)
        primitive.state.renderFlag = EffectPrimitiveState.RenderFlag.alpha | EffectPrimitiveState.RenderFlag.customBlend
        primitive.state.duration = duration
        primitive.state.totalTexture = 1
        primitive.state.texturePaths = [texturePath]
        primitive.state.size = 0

        for i in 1..<4 {
            primitive.state.slots[i].life = 0
        }
        primitive.state.slots[0].life = 1
        primitive.state.slots[0].process = 0
        primitive.state.slots[0].distance = 2.5
        primitive.state.slots[0].height[10] = deltaPos.y
        primitive.state.slots[0].height[13] = 0
        primitive.state.slots[0].height[14] = 0
        primitive.state.slots[0].height[15] = 0
        for h in 0..<4 {
            primitive.state.slots[0].height[h] = Float(Int.random(in: 0..<360))
        }
        primitive.state.slots[0].vecTNow.x = 5.0
        primitive.state.slots[0].vecBPre = SIMD3<Float>(
            -EffectSpace.sine(degrees: 90) * 30.0,
            -(EffectSpace.sine(degrees: 0) * 20.0) - 40.0,
            0
        )
        primitive.state.slots[0].flag1[0] = flag
    }

    // MARK: - EF_SPR_PARTICLE (851...852)

    /// Spawns wandering Mavka sprite motes (`152`) on ticks `0..<10` for `EF_SPR_PARTICLE` (851) and `EF_SPR_PARTICLE2` (852).
    func mavka(flag: Int8, context: EffectTickContext) {
        guard stateCnt < 10 else {
            return
        }

        let spritePath = K2L("몬스터\\mavka.spr")
        let actionPath = K2L("몬스터\\mavka.act")
        _ = context.assets?.spriteAsset(spritePath: spritePath, actionPath: actionPath)

        let primitive = launchPrimitive(152)
        primitive.state.duration = duration
        primitive.state.size = 0.3
        primitive.state.alpha = 0
        primitive.state.spritePath = spritePath
        primitive.state.actionPath = actionPath
        primitive.state.animSpeed = 8
        primitive.state.renderFlag |= EffectPrimitiveState.RenderFlag.noDepth

        for index in 0..<4 {
            primitive.state.slots[index].process = 0
            primitive.state.slots[index].life = 1
            primitive.state.slots[index].vecBPre = .zero
            primitive.state.slots[index].vecBNow = .zero
            primitive.state.slots[index].vecTPre = .zero
            primitive.state.slots[index].rotStart = 0
            primitive.state.slots[index].riseAngle = 0
            primitive.state.slots[index].distance = 2.0
            for h in 0..<12 {
                primitive.state.slots[index].height[h] = Float(Int.random(in: 0..<360))
            }
            primitive.state.slots[index].flag1[0] = flag
        }

        primitive.previousAnimation = 0
        primitive.currentMotion = 0
        primitive.initSegment()
    }

    // MARK: - EF_SPR_PLANT (853, 866...878)

    /// Spawns radial ring of glowing monster sprites (`153`) for `EF_SPR_PLANT...8` and higher variants.
    func monsterSpriteBurst(kind: Int8, context: EffectTickContext) {
        let limit: Int = if kind == 13 || kind == 14 {
            30
        } else if kind >= 9 {
            20
        } else {
            kind >= 2 ? 10 : 50
        }
        guard stateCnt < limit else {
            return
        }

        let primitive = launchPrimitive(153)
        primitive.state.duration = duration - stateCnt
        for i in 1..<4 {
            primitive.state.slots[i].life = 0
        }
        primitive.state.slots[0].process = 0
        primitive.state.slots[0].life = 1

        let angle: Int
        let radius: Float
        if kind == 2 {
            primitive.state.size = 0.6
            angle = (stateCnt * 36) % 360
            radius = 40.0
        } else if kind == 13 {
            angle = (stateCnt * 12) % 360
            switch stateCnt % 3 {
            case 0:
                primitive.state.size = 0.9
                radius = 8.0
            case 1:
                primitive.state.size = 1.0
                radius = 15.0
            default:
                primitive.state.size = 1.1
                radius = 22.0
            }
        } else if kind == 14 {
            angle = (stateCnt * 12) % 360
            switch stateCnt % 3 {
            case 0:
                primitive.state.size = 0.5
                radius = 8.0
            case 1:
                primitive.state.size = 0.65
                radius = 14.0
            default:
                primitive.state.size = 0.8
                radius = 20.0
            }
        } else if kind == 15 {
            angle = (stateCnt * 18) % 360
            if stateCnt % 2 == 0 {
                radius = 4.0
                primitive.state.size = Float(Int.random(in: 0..<11)) * 0.05 + 1.5
            } else {
                radius = 10.0
                primitive.state.size = Float(Int.random(in: 0..<11)) * 0.05 + 2.0
            }
        } else if kind == 9 {
            angle = (stateCnt * 18) % 360
            if stateCnt % 2 == 0 {
                primitive.state.size = 0.85
                radius = 12.0
            } else {
                primitive.state.size = 0.95
                radius = 24.0
            }
        } else if kind >= 10 {
            angle = (stateCnt * 18) % 360
            if stateCnt % 2 == 0 {
                radius = 6.0
                primitive.state.size = Float(Int.random(in: 0..<11)) * 0.03 + 0.4
            } else {
                radius = 12.0
                primitive.state.size = Float(Int.random(in: 0..<11)) * 0.03 + 0.5
            }
        } else if kind >= 3 {
            primitive.state.size = 1.0
            angle = (stateCnt * 36) % 360
            radius = 40.0
        } else {
            primitive.state.size = 0.7
            angle = Int.random(in: 0..<360)
            radius = Float(Int.random(in: 0..<45) + 5)
        }

        let worldX = position.x + radius * EffectSpace.sine(degrees: angle)
        let worldZ = position.z + radius * EffectSpace.cosine(degrees: angle)
        let worldY = context.world.terrainHeight(atEffectX: worldX, effectZ: worldZ)
        primitive.position = SIMD3<Float>(worldX, worldY, worldZ)

        if kind == 5 || kind == 10 {
            primitive.state.slots[0].flag1[0] = 4
        } else if kind == 11 {
            primitive.state.slots[0].flag1[0] = 6
        } else if kind == 12 || kind == 14 || kind == 15 {
            primitive.state.slots[0].flag1[0] = 8
        } else {
            primitive.state.slots[0].flag1[0] = kind
        }
        primitive.state.slots[0].flag1[2] = kind == 15 ? 1 : 0
        primitive.state.alpha = 0
        primitive.state.slots[1].flag1[1] = Int8(Int.random(in: 0..<3))

        let spriteBase: String
        let actionIndex: Int
        switch kind {
        case 2:
            spriteBase = "워그"
            primitive.state.animSpeed = Int.random(in: 0..<3) + 6
            actionIndex = Int.random(in: 0..<8)
        case 3:
            spriteBase = "violy"
            primitive.state.animSpeed = Int.random(in: 0..<3) + 6
            actionIndex = Int.random(in: 0..<8)
        case 4:
            spriteBase = "succubus"
            primitive.state.animSpeed = Int.random(in: 0..<3) + 6
            let pose = Int.random(in: 0..<3)
            actionIndex = Int.random(in: 0..<8) + (pose == 0 ? 56 : (pose == 1 ? 48 : 40))
        case 5:
            spriteBase = "mineral"
            primitive.state.animSpeed = Int.random(in: 0..<3) + 6
            actionIndex = Int.random(in: 0..<8)
        case 6:
            spriteBase = "ktullanux"
            primitive.state.animSpeed = Int.random(in: 0..<3) + 6
            actionIndex = Int.random(in: 0..<8)
        case 7:
            spriteBase = "garm"
            primitive.state.animSpeed = Int.random(in: 0..<3) + 6
            actionIndex = Int.random(in: 0..<8)
        case 8:
            spriteBase = "miyabi_ningyo"
            primitive.state.animSpeed = Int.random(in: 0..<3) + 6
            actionIndex = Int.random(in: 0..<8) + 48
        case 9:
            spriteBase = "garden_keeper"
            primitive.state.animSpeed = 4
            actionIndex = Int.random(in: 0..<8) + 16
        case 13:
            spriteBase = "ginseng_bullet"
            primitive.state.animSpeed = 3
            actionIndex = Int.random(in: 0..<8)
        case 14:
            spriteBase = "nepenthes2_bullet"
            primitive.state.animSpeed = 4
            actionIndex = 0
        case 15:
            spriteBase = "imp"
            primitive.state.animSpeed = 4
            actionIndex = Int.random(in: 0..<8)
        default:
            if kind >= 10 {
                spriteBase = "ifrit"
                primitive.state.animSpeed = 4
                actionIndex = Int.random(in: 0..<8) + 32
            } else {
                spriteBase = "geographer"
                primitive.state.animSpeed = 4
                actionIndex = 0
            }
        }

        let spritePath = K2L("몬스터\\\(spriteBase).spr")
        let actionPath = K2L("몬스터\\\(spriteBase).act")
        _ = context.assets?.spriteAsset(spritePath: spritePath, actionPath: actionPath)
        primitive.state.spritePath = spritePath
        primitive.state.actionPath = actionPath
        primitive.previousAnimation = actionIndex
        primitive.currentMotion = 0
        primitive.initSegment()
    }

    // MARK: - EF_CHEMICAL_V (854, 858, 863)

    /// Spawns directional blade-fin beam (`154`) for `EF_CHEMICAL_V`, `EF_CHEMICAL_V2`, and `EF_CHEMICAL_V3`.
    func texturedBeam(flag: Int8, texturePath: String, context: EffectTickContext) {
        guard stateCnt == 0 else {
            return
        }

        _ = context.assets?.texture(atPath: texturePath)

        let primitive = launchPrimitive(154)
        primitive.state.renderFlag = EffectPrimitiveState.RenderFlag.alpha | EffectPrimitiveState.RenderFlag.customBlend
        primitive.state.duration = duration
        primitive.state.totalTexture = 1
        primitive.state.texturePaths = [texturePath]

        for i in 1..<4 {
            primitive.state.slots[i].life = 0
        }
        primitive.state.slots[0].life = 1
        primitive.state.slots[0].process = 0
        primitive.state.slots[0].distance = 100.0
        primitive.state.slots[0].height[0] = 50.0
        primitive.state.slots[0].maxHeight = 5.0
        primitive.state.slots[0].height[2] = 80.0
        primitive.state.slots[0].riseAngle = EffectPrimitive.angle(dx: deltaPos.x - position.x, dy: deltaPos.z - position.z)
        primitive.state.slots[0].alphaB = 0
        primitive.state.slots[0].flag1[0] = flag
    }

    /// Spawns wandering melody-note fork bolts (`155`) on ticks 0, 10, 20 for `EF_CHEMICAL_V` and `EF_CHEMICAL_V2`.
    func texturedForkBolt(texturePath: String, flag: Int8, context: EffectTickContext) {
        guard stateCnt < 30, stateCnt % 10 == 0 else {
            return
        }

        _ = context.assets?.texture(atPath: texturePath)

        let primitive = launchPrimitive(155)
        primitive.state.renderFlag = EffectPrimitiveState.RenderFlag.alpha | EffectPrimitiveState.RenderFlag.customBlend
        primitive.state.duration = duration
        primitive.state.totalTexture = 1
        primitive.state.texturePaths = [texturePath]
        primitive.state.size = 0

        for i in 1..<4 {
            primitive.state.slots[i].life = 0
        }

        let riseAngle = EffectPrimitive.angle(dx: deltaPos.x - position.x, dy: deltaPos.z - position.z)
        primitive.state.slots[0].life = 1
        primitive.state.slots[0].maxHeight = Float(Int.random(in: 0..<21)) * 0.01 + 0.8
        primitive.state.slots[0].distance = Float(Int.random(in: 0..<21)) * 0.1 + 3.0
        primitive.state.slots[0].process = 0
        primitive.state.slots[0].riseAngle = riseAngle
        primitive.state.slots[0].vecBPre = SIMD3<Float>(0, -5.0, 0)
        primitive.state.slots[0].vecBNow = SIMD3<Float>(0, -5.0, 0)
        primitive.state.slots[0].height[0] = Float(riseAngle)
        primitive.state.slots[0].height[1] = Float(Int(riseAngle) - 45 + Int.random(in: 0..<91))
        primitive.state.slots[0].height[2] = Float(Int(riseAngle) - 45 + Int.random(in: 0..<91))
        primitive.state.slots[0].height[3] = 180.0
        primitive.state.slots[0].height[4] = 180.0
        primitive.state.slots[0].height[12] = 0
        primitive.state.slots[0].height[5] = Float(riseAngle)
        primitive.state.slots[0].height[6] = Float(Int(riseAngle) - 45 + Int.random(in: 0..<91))
        primitive.state.slots[0].height[7] = Float(Int(riseAngle) - 45 + Int.random(in: 0..<91))
        primitive.state.slots[0].height[8] = 180.0
        primitive.state.slots[0].height[9] = 180.0
        for i in 0..<10 {
            if primitive.state.slots[0].height[i] < 0 {
                primitive.state.slots[0].height[i] += 360.0
            }
            if primitive.state.slots[0].height[i] >= 360.0 {
                primitive.state.slots[0].height[i] -= 360.0
            }
        }
        primitive.state.slots[0].height[13] = 0
        primitive.state.slots[0].flag1[0] = flag
    }

    // MARK: - EF_BOT_REVERB (856, 860)

    /// Spawns hovering musical note drop (`156`) for `EF_BOT_REVERB` (856) and `EF_BOT_REVERB2` (860).
    func texturedDrop(texturePath: String, flag: Int8, context: EffectTickContext) {
        guard stateCnt == 0 else {
            return
        }

        _ = context.assets?.texture(atPath: texturePath)

        let primitive = launchPrimitive(156)
        primitive.state.renderFlag = EffectPrimitiveState.RenderFlag.alpha | EffectPrimitiveState.RenderFlag.customBlend
        primitive.state.duration = duration
        primitive.state.totalTexture = 1
        primitive.state.texturePaths = [texturePath]
        primitive.state.size = 0

        for i in 1..<4 {
            primitive.state.slots[i].life = 0
        }
        primitive.state.slots[0].life = 1
        primitive.state.slots[0].process = 0
        primitive.state.slots[0].distance = 6.0
        primitive.state.slots[0].height[8] = 0
        primitive.state.slots[0].alphaB = 120
        primitive.state.slots[0].vecBNow.x = position.x
        primitive.state.slots[0].vecBNow.z = position.z
        primitive.state.slots[0].vecBPre.y = position.y - 6.0
        primitive.state.slots[0].rotStart = Int16(Int.random(in: 0..<360))
        primitive.state.slots[0].fullDisplayAngle = 45
        primitive.state.slots[0].flag1[0] = 0
        primitive.state.slots[0].flag1[1] = flag
    }

    // MARK: - EF_RAIN_PARTICLE (857)

    /// Spawns periodic falling rain/lightning motes (`157`) every 10 ticks up to tick 990 for `EF_RAIN_PARTICLE` (857).
    func texturedFloatingDust(texturePath: String, context: EffectTickContext) {
        guard stateCnt < 1000, stateCnt % 10 == 0 else {
            return
        }

        _ = context.assets?.texture(atPath: texturePath)

        let primitive = launchPrimitive(157)
        primitive.state.renderFlag = EffectPrimitiveState.RenderFlag.alpha | EffectPrimitiveState.RenderFlag.customBlend
        primitive.state.duration = duration
        primitive.state.totalTexture = 1
        primitive.state.texturePaths = [texturePath]
        primitive.state.size = 0

        for index in 0..<4 {
            primitive.state.slots[index].life = 1
            primitive.state.slots[index].maxHeight = Float(Int.random(in: 0..<51)) * 0.01 + 2.5
            primitive.state.slots[index].distance = Float(Int.random(in: 0..<31)) * 0.1 + 7.0
            primitive.state.slots[index].process = 0
            primitive.state.slots[index].fullDisplayAngle = Int16(Int.random(in: 0..<360))
            primitive.state.slots[index].height[0] = Float(Int.random(in: 0..<33))
            primitive.state.slots[index].vecBNow.y = Float(Int.random(in: 0..<21) - 80)
            primitive.state.slots[index].alphaB = 0
            primitive.state.slots[index].flag1[0] = Int8(Int.random(in: 0..<3))
        }
    }

    // MARK: - EF_CIRCLEPOWER2...8 (861, 865, 867, 871, 873, 875, 877)

    /// Spawns dual-wave twinkling ring panels (`132`) on ticks 0 and 10 for `EF_CIRCLEPOWER2...8`.
    func texturedTwinkleRing(texturePath: String, level: Int8, context: EffectTickContext) {
        guard stateCnt == 0 || stateCnt == 10 else {
            return
        }

        _ = context.assets?.texture(atPath: texturePath)

        let primitive = launchPrimitive(132)
        primitive.state.renderFlag = EffectPrimitiveState.RenderFlag.alpha | EffectPrimitiveState.RenderFlag.customBlend
        primitive.state.duration = duration
        primitive.state.totalTexture = 1
        primitive.state.texturePaths = [texturePath]
        primitive.state.size = 1.0

        for i in 0..<4 {
            primitive.state.slots[i].life = 1
            primitive.state.slots[i].process = i * -20
            primitive.state.slots[i].fullDisplayAngle = Int16(Int.random(in: 0..<360))
            primitive.state.slots[i].maxHeight = 10.0
            primitive.state.slots[i].rotStart = Int16(Int.random(in: 0..<360))
            primitive.state.slots[i].alphaB = 100
            primitive.state.slots[i].height[4] = 10.0
            primitive.state.slots[i].height[3] = Float(i)
            primitive.state.slots[i].height[5] = Float(level)
        }
    }

    // MARK: - EF_BEGINSPELL_150 (880)

    /// Spawns 27-frame bubble ground arc (`158`) for `EF_BEGINSPELL_150` (880).
    func bubbleSpiral(angle: Int16, flag: Int8, context: EffectTickContext) {
        guard stateCnt == 0 else {
            return
        }

        if duration < 100 {
            duration = 100
        }

        let paths = (1...27).map { String(format: "effect\\W_bubble%02d.tga", $0) }
        for path in paths {
            _ = context.assets?.texture(atPath: path)
        }

        let primitive = launchPrimitive(158)
        primitive.state.renderFlag = EffectPrimitiveState.RenderFlag.alpha | EffectPrimitiveState.RenderFlag.customBlend
        primitive.state.duration = duration
        primitive.state.totalTexture = paths.count
        primitive.state.texturePaths = paths
        primitive.state.size = flag == 1 ? 4.0 : 0.0

        let configs: [(maxHeight: Float, rotStart: Int16, alphaOffset: Int16)] = [
            (30.0, 180, 135),
            (29.0, 270, 90),
            (28.0, 0, 45),
            (27.0, 90, 0),
        ]

        for (index, config) in configs.enumerated() {
            primitive.state.slots[index].life = 1
            primitive.state.slots[index].process = 0
            primitive.state.slots[index].fullDisplayAngle = 360
            primitive.state.slots[index].maxHeight = config.maxHeight
            primitive.state.slots[index].rotStart = config.rotStart
            primitive.state.slots[index].alphaB = angle + config.alphaOffset
            primitive.state.slots[index].distance = 3.5
            primitive.state.slots[index].riseAngle = 80
            primitive.state.slots[index].alphaT = Int16(flag)
            primitive.state.slots[index].vecBNow.y = 0
            primitive.state.slots[index].height = Array(repeating: 0, count: 21)
            primitive.state.slots[index].flag1 = Array(repeating: 0, count: 21)
        }
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

    // MARK: - EF_GLASSWALL4 (883)

    /// Spawns glowing vertical column (`160`) for `EF_GLASSWALL4` (883).
    func texturedColumn(texturePath: String, kind: Int8, context: EffectTickContext) {
        guard stateCnt == 0 else {
            return
        }

        _ = context.assets?.texture(atPath: texturePath)

        let primitive = launchPrimitive(160)
        primitive.state.renderFlag = EffectPrimitiveState.RenderFlag.alpha | EffectPrimitiveState.RenderFlag.customBlend
        primitive.state.duration = duration
        primitive.state.totalTexture = 1
        primitive.state.texturePaths = [texturePath]
        primitive.state.size = 0

        for i in 1..<4 {
            primitive.state.slots[i].life = 0
        }
        primitive.state.slots[0].life = 1
        primitive.state.slots[0].process = 0

        if kind == 30 {
            primitive.state.slots[0].distance = 36.0
            primitive.state.slots[0].vecBPre.y = position.y
            primitive.state.slots[0].flag1[2] = 19
        } else if kind == 31 {
            primitive.state.slots[0].distance = 36.0
            primitive.state.slots[0].vecBPre.y = position.y
            primitive.state.slots[0].flag1[2] = 21
        } else {
            primitive.state.slots[0].distance = 5.0
            primitive.state.slots[0].vecBPre.y = position.y - 10.0
            primitive.state.slots[0].flag1[2] = 2
        }

        primitive.state.slots[0].height[10] = 0
        primitive.state.slots[0].fullDisplayAngle = 135
        primitive.state.slots[0].height[8] = 0
        primitive.state.slots[0].alphaB = 0
        primitive.state.slots[0].vecBNow.x = position.x
        primitive.state.slots[0].vecBNow.z = position.z
        primitive.state.slots[0].rotStart = Int16(Int.random(in: 0..<360))
        primitive.state.slots[0].flag1[0] = 0
        primitive.state.slots[0].flag1[4] = kind
    }

    // MARK: - EF_GRADIUS_LASER (884)

    /// Spawns 3-layer lime-green orbiting laser columns (`60`) for `EF_GRADIUS_LASER` (884).
    func texturedTripleOrbit(texturePath: String, context: EffectTickContext) {
        guard stateCnt == 0 else {
            return
        }

        _ = context.assets?.texture(atPath: texturePath)

        let primitive = launchPrimitive(60)
        primitive.state.renderFlag = EffectPrimitiveState.RenderFlag.alpha | EffectPrimitiveState.RenderFlag.customBlend
        primitive.state.duration = duration
        primitive.state.totalTexture = 1
        primitive.state.texturePaths = [texturePath]
        primitive.state.size = 16.0

        let configs: [(maxHeight: Float, distance: Float)] = [
            (74.0, 1.3),
            (77.0, 1.0),
            (80.0, 0.7),
        ]
        for (index, config) in configs.enumerated() {
            primitive.state.slots[index].life = 1
            primitive.state.slots[index].process = 0
            primitive.state.slots[index].fullDisplayAngle = 360
            primitive.state.slots[index].maxHeight = config.maxHeight
            primitive.state.slots[index].rotStart = Int16(Int.random(in: 0..<360))
            primitive.state.slots[index].alphaB = 0
            primitive.state.slots[index].distance = config.distance
            primitive.state.slots[index].riseAngle = 90
            primitive.state.slots[index].alphaT = 3080
            primitive.state.slots[index].vecBNow.y = 0
            primitive.state.slots[index].height = Array(repeating: 0, count: 21)
            primitive.state.slots[index].flag1 = Array(repeating: 0, count: 21)
        }
        primitive.state.slots[3].life = 0
    }

    // MARK: - EF_ELECTRIC4 (888)

    /// Spawns radial lightning arcs (`PP_ELECTRIC` (101)) on ticks `11...14` for `EF_ELECTRIC4` (888).
    func electricRing(kind: Int8, angle: Int16, context: EffectTickContext) {
        guard stateCnt >= 11, stateCnt <= 14 else {
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
            primitive.state.slots[index].alphaT = Int16(kind)
            primitive.state.slots[index].fullDisplayAngle = 0
        }
    }

    // MARK: - EF_FIREBALL4 (891)

    /// Emits 3 blue-tinted directional fireball volleys (`PP_3DPARTICLE` (5)) for `EF_FIREBALL4` (891).
    func blueFireballVolley(context: EffectTickContext) {
        if stateCnt == 5 {
            context.world.playSound(
                named: "effect\\EF_FireBall.wav",
                atWorldPosition: EffectSpace.toWorldPosition(position),
                delay: 0
            )
        }

        func launchVolley(turn: Float, shade: Int, fade: Int) {
            let spritePath = K2L("이팩트\\fireball.spr")
            let actionPath = K2L("이팩트\\fireball.act")
            _ = context.assets?.spriteAsset(spritePath: spritePath, actionPath: actionPath)

            let primitive = launchPrimitive(.pp_3dparticle)
            primitive.state.renderFlag = EffectPrimitiveState.RenderFlag.alpha | EffectPrimitiveState.RenderFlag.customBlend
            primitive.state.duration = 20
            primitive.state.pattern |= 0x120
            primitive.state.deltaPos2 = SIMD3<Float>(0, -15.0, 0)

            var face = Self.effectHeading(fromX: position.x, fromZ: position.z, toX: deltaPos.x, toZ: deltaPos.z)
            if turn != 0 {
                face += turn
                if face < 0 {
                    face += 360.0
                }
                if face >= 360.0 {
                    face -= 360.0
                }
            }

            primitive.state.longitude = -face
            var renderAngle = 180.0 - face
            if renderAngle < 0 {
                renderAngle += 360.0
            }
            primitive.angle = renderAngle

            let dist = Self.effectDistanceXZ(from: position, to: deltaPos)
            primitive.state.speed = -(dist / Float(primitive.state.duration))
            primitive.state.transform = EffectSpace.rotationY(radians: EffectSpace.radian(degrees: Int(primitive.state.longitude)))
            primitive.state.size = 1.0
            primitive.state.animSpeed = 1
            primitive.state.red = shade
            primitive.state.green = shade
            primitive.state.blue = 255
            primitive.state.alpha = Float((fade - stateCnt) * 40)
            primitive.state.spritePath = spritePath
            primitive.state.actionPath = actionPath
            primitive.initSegment()
        }

        if stateCnt >= 0 && stateCnt <= 3 {
            launchVolley(turn: 0, shade: 55, fade: 5)
        } else if stateCnt >= 6 && stateCnt <= 9 {
            launchVolley(turn: -5.0, shade: 30, fade: 11)
        } else if stateCnt >= 12 && stateCnt <= 15 {
            launchVolley(turn: 5.0, shade: 5, fade: 17)
        }
    }

    // MARK: - EF_TRIPLEATTACK4 (892)

    /// Spawns directional cloud burst trails (`69`) on ticks `0...1` with hit audio on ticks 10 and 20 for `EF_TRIPLEATTACK4` (892).
    func cloudBurst(context: EffectTickContext) {
        if stateCnt <= 1 {
            let texturePath = "effect\\cloud11.tga"
            _ = context.assets?.texture(atPath: texturePath)

            let primitive = launchPrimitive(69)
            primitive.state.renderFlag = EffectPrimitiveState.RenderFlag.alpha | EffectPrimitiveState.RenderFlag.customBlend
            primitive.state.duration = duration
            primitive.state.totalTexture = 1
            primitive.state.texturePaths = [texturePath]
            primitive.state.size = 0
            primitive.state.deltaPos = deltaPos

            let rotStart = EffectPrimitive.angle(dx: deltaPos.x - position.x, dy: deltaPos.z - position.z)
            let cosVal = EffectSpace.cosine(degrees: Int(rotStart))
            let sinVal = EffectSpace.sine(degrees: Int(rotStart))

            for i in 0..<4 {
                primitive.state.slots[i].life = 1
                primitive.state.slots[i].process = -Int.random(in: 0..<20)
                primitive.state.slots[i].rotStart = rotStart
                primitive.state.slots[i].alphaB = 0
                let backShift = Float(Int.random(in: 0..<100)) * 0.15
                primitive.state.slots[i].height[1] = backShift
                let bx = Float(Int.random(in: 0..<100)) * 0.06 - 3.0 + position.x - cosVal * backShift
                let bz = Float(Int.random(in: 0..<100)) * 0.06 - 3.0 + position.z - sinVal * backShift
                let point = SIMD3<Float>(bx, position.y, bz)
                primitive.state.slots[i].vecBNow = point
                primitive.state.slots[i].vecTNow = point
                primitive.state.slots[i].maxHeight = 0.25
                primitive.state.slots[i].height[0] = Float(Int.random(in: 0..<100)) * 0.04 + 8.0
                primitive.state.slots[i].distance = Float(Int.random(in: 0..<100)) * 0.2 + 20.0
                primitive.state.slots[i].height[4] = 4.0
            }
        }

        if stateCnt == 10 {
            context.world.playSound(
                named: "effect\\EF_hit2.wav",
                atWorldPosition: EffectSpace.toWorldPosition(position),
                delay: 0
            )
        }
        if stateCnt == 20 {
            context.world.playSound(
                named: "effect\\EF_hit4.wav",
                atWorldPosition: EffectSpace.toWorldPosition(position),
                delay: 0
            )
        }
    }

    // MARK: - EF_CHEMICAL3S (893)

    /// Spawns directional line streaks (`PP_CHEMICAL3` (56)) for `EF_CHEMICAL3S` (893).
    func lineStreakKind(kind: Int16, context: EffectTickContext) {
        guard stateCnt == 0 else {
            return
        }

        let texturePath = kind < 10 ? "effect\\line3.tga" : "effect\\line3y.tga"
        _ = context.assets?.texture(atPath: texturePath)

        let primitive = launchPrimitive(.pp_chemical3)
        primitive.state.renderFlag = EffectPrimitiveState.RenderFlag.alpha | EffectPrimitiveState.RenderFlag.customBlend
        primitive.state.duration = duration
        primitive.state.totalTexture = 1
        primitive.state.texturePaths = [texturePath]

        let riseAngle = EffectPrimitive.angle(dx: deltaPos.x - position.x, dy: deltaPos.z - position.z)
        let mode = Int(kind) % 10

        for index in 0..<4 {
            primitive.state.slots[index].life = 1
            primitive.state.slots[index].process = 0
            primitive.state.slots[index].distance = 100.0
            if mode == 0 {
                primitive.state.slots[index].height[0] = -15.0 - Float(Int.random(in: 0..<11))
            } else if mode == 1 {
                primitive.state.slots[index].height[0] = Float(Int.random(in: 0..<11)) + 15.0
            }
            primitive.state.slots[index].height[1] = Float(Int.random(in: 0..<200))
            if kind < 10 {
                primitive.state.slots[index].maxHeight = Float(Int.random(in: 0..<4)) * 0.1 + 0.3
                primitive.state.slots[index].height[2] = Float(Int.random(in: 0..<31)) + 20.0
                primitive.state.slots[index].flag1[0] = Int8(Int.random(in: 0..<3) + 30)
                primitive.state.slots[index].height[3] = Float(Int.random(in: 0..<21)) * 0.1 + 1.5
            }
            primitive.state.slots[index].riseAngle = riseAngle
            primitive.state.slots[index].alphaB = 0
        }
    }

    // MARK: - EF_DQ9_CHARGE (895...898)

    /// Spawns radial fan-slice charge trails (`162`) on ticks `0...2` for `EF_DQ9_CHARGE` (895).
    func texturedSpiral(texturePath: String, context: EffectTickContext) {
        guard stateCnt <= 2 else {
            return
        }

        _ = context.assets?.texture(atPath: texturePath)

        let primitive = launchPrimitive(162)
        primitive.state.renderFlag = EffectPrimitiveState.RenderFlag.alpha | EffectPrimitiveState.RenderFlag.customBlend
        primitive.state.duration = duration
        primitive.state.totalTexture = 1
        primitive.state.texturePaths = [texturePath]

        for index in 0..<4 {
            primitive.state.slots[index].life = 1
            primitive.state.slots[index].process = 0
            primitive.state.slots[index].distance = 100.0
            primitive.state.slots[index].alphaB = 255
            primitive.state.slots[index].riseAngle = Int16((stateCnt * 4 + index) * 30)
            primitive.state.slots[index].rotStart = 0
            primitive.state.slots[index].height[0] = -5.0
        }
    }

    /// Spawns compact fan-wedge charge trails (`163`) on ticks `0...2` for `EF_DQ9_CHARGE2` (896).
    func texturedSpiralSmall(texturePath: String, context: EffectTickContext) {
        guard stateCnt <= 2 else {
            return
        }

        _ = context.assets?.texture(atPath: texturePath)

        let primitive = launchPrimitive(163)
        primitive.state.renderFlag = EffectPrimitiveState.RenderFlag.alpha | EffectPrimitiveState.RenderFlag.customBlend
        primitive.state.duration = duration
        primitive.state.totalTexture = 1
        primitive.state.texturePaths = [texturePath]

        for slot in 0..<4 {
            primitive.state.slots[slot].life = 1
            primitive.state.slots[slot].process = 0
            primitive.state.slots[slot].distance = 50.0
            primitive.state.slots[slot].alphaB = 255
            primitive.state.slots[slot].riseAngle = Int16((stateCnt * 4 + slot) * 30)
            primitive.state.slots[slot].rotStart = 0
            primitive.state.slots[slot].height[0] = -5.0
            primitive.state.slots[slot].height[1] = 0
        }
    }

    /// Spawns tall scrolling-frame charge trails (`164`) on ticks `0...2` for `EF_DQ9_CHARGE3` (897).
    func texturedSpiralTall(texturePath: String, context: EffectTickContext) {
        guard stateCnt <= 2 else {
            return
        }

        _ = context.assets?.texture(atPath: texturePath)

        let primitive = launchPrimitive(164)
        primitive.state.renderFlag = EffectPrimitiveState.RenderFlag.alpha | EffectPrimitiveState.RenderFlag.customBlend
        primitive.state.duration = duration
        primitive.state.totalTexture = 1
        primitive.state.texturePaths = [texturePath]

        for slot in 0..<4 {
            primitive.state.slots[slot].life = 1
            primitive.state.slots[slot].process = 0
            primitive.state.slots[slot].distance = 100.0
            primitive.state.slots[slot].maxHeight = 15.0
            primitive.state.slots[slot].alphaB = 255
            primitive.state.slots[slot].riseAngle = Int16((stateCnt * 4 + slot) * 30)
            primitive.state.slots[slot].rotStart = 0
            primitive.state.slots[slot].height[0] = -5.0
            primitive.state.slots[slot].height[1] = 0
        }
    }

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
