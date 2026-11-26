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
        .ef_bash3d4,
        .ef_napalmvalcan,
        .ef_portal5,
        .ef_magiccrasher2,
        .ef_bottom_spider,
        .ef_bottom_fogwall,
        .ef_baby,
        .ef_soulbreaker2,
        .ef_rainbow,
        .ef_peong,
        .ef_tanji2,
        .ef_pressedbody,
        .ef_spinedbody,
        .ef_kickedbody,
        .ef_airtexture,
        .ef_hitbody,
        .ef_doublegumgang,
        .ef_reflectbody,
        .ef_babybody,
        .ef_babybody2,
        .ef_giantbody,
        .ef_giantbody2,
        .ef_asurabody,
        .ef_4waybody,
        .ef_quakebody,
        .ef_asurabody_monster,
        .ef_hitline3,
        .ef_hitline4,
        .ef_hitline5,
        .ef_hitline6,
        .ef_electric,
        .ef_electric2,
        .ef_hitline7,
        .ef_stormkick,
        .ef_halfsphere,
        .ef_attackenergy,
        .ef_attackenergy2,
        .ef_chemical3,
        .ef_bluecasting,
        .ef_run,
        .ef_stoprun,
        .ef_stopeffect,
        .ef_jumpbody,
        .ef_landbody,
        .ef_foot3,
        .ef_foot4,
        .ef_tae_ready,
        .ef_grandcross2,
        .ef_soulstrike2,
        .ef_yufitel2,
        .ef_npc_stop,
        .ef_darkcasting,
        .ef_gumgangnpc,
        .ef_agiup,
        .ef_jumpkick,
        .ef_quakebody2,
        .ef_stormkick1,
        .ef_stormkick2,
        .ef_stormkick3,
        .ef_stormkick4,
        .ef_stormkick5,
        .ef_stormkick6,
        .ef_stormkick7,
        .ef_spinedbody2,
        .ef_beginasura1,
        .ef_beginasura2,
        .ef_beginasura3,
        .ef_beginasura4,
        .ef_beginasura5,
        .ef_beginasura6,
        .ef_beginasura7,
        .ef_aurablade2,
        .ef_devil1,
        .ef_devil2,
        .ef_devil3,
        .ef_devil4,
        .ef_devil5,
        .ef_devil6,
        .ef_devil7,
        .ef_devil8,
        .ef_devil9,
        .ef_devil10,
        .ef_doublegumgang2,
        .ef_doublegumgang3,
        .ef_blackdevil,
        .ef_flowercast,
        .ef_flowercast2,
        .ef_flowercast3,
        .ef_edp,
        .ef_shieldboomerang2,
        .ef_rg_coin2,
        .ef_guard2,
        .ef_slim,
        .ef_slim2,
        .ef_slim3,
    ]

    func process0400To0499(context: EffectTickContext) -> Bool {
        switch effectID {
        case .ef_bash3d4:
            if stateCnt == 22 {
                context.world.playSound(
                    named: K2L("effect\\비트 조인트.wav"),
                    atWorldPosition: EffectSpace.toWorldPosition(position),
                    delay: 0
                )
            }
            for phase in 0..<6 {
                texturedQuadSpin(texturePath: "effect\\alpha_center.tga", phase: Int8(phase), kind: 5, context: context)
            }
            if stateCnt >= 20 && stateCnt <= 50, let targetID = targetObjectID ?? ownerObjectID {
                context.world.applyTargetModifier(
                    .flash(color: SIMD4<Float>(1.0, 1.0, 1.0, 1.0), durationTicks: 2),
                    to: targetID
                )
            }
        case .ef_napalmvalcan:
            if stateCnt == 20 || stateCnt == 30 || stateCnt == 40 || stateCnt == 50 || stateCnt == 60 {
                context.world.playSound(
                    named: "effect\\EF_NapalmBeat.wav",
                    atWorldPosition: EffectSpace.toWorldPosition(position),
                    delay: 0
                )
                hit2(option: 0, context: context)
            }
        case .ef_portal5:
            cloud11Burst(kind: 1, context: context)
            if stateCnt >= 5 && stateCnt <= 65, let targetID = targetObjectID ?? ownerObjectID {
                context.world.applyTargetModifier(
                    .tint(color: SIMD4<Float>(250.0 / 255.0, 250.0 / 255.0, 200.0 / 255.0, 1.0), durationTicks: 2),
                    to: targetID
                )
            }
        case .ef_magiccrasher2:
            if stateCnt == 25 {
                context.world.playSound(
                    named: "effect\\swordman_provoke.wav",
                    atWorldPosition: EffectSpace.toWorldPosition(position),
                    delay: 0
                )
            }
            if stateCnt >= 0 && stateCnt <= 60, let targetID = targetObjectID ?? ownerObjectID {
                context.world.applyTargetModifier(
                    .tint(
                        color: SIMD4<Float>(
                            Float(Int.random(in: 0..<255)) / 255.0,
                            Float(Int.random(in: 0..<255)) / 255.0,
                            Float(Int.random(in: 0..<255)) / 255.0,
                            1.0
                        ),
                        durationTicks: 2
                    ),
                    to: targetID
                )
            }
        case .ef_bottom_spider:
            texturedHalo(texturePath: "effect\\spiderweb.tga", kind: 2, context: context)
        case .ef_bottom_fogwall:
            texturedPulseKind(texturePath: "effect\\ring_white.tga", kind: 2, context: context)
        case .ef_baby:
            if stateCnt == 0 {
                context.world.playSound(
                    named: "effect\\EF_Blessing.wav",
                    atWorldPosition: EffectSpace.toWorldPosition(position),
                    delay: 0
                )
            }
            for angle in stride(from: 0, to: 45, by: 9) {
                featherBurst(texturePath: "effect\\fire_ivy.bmp", angle: Int16(angle), flag: 0, context: context)
            }
        case .ef_soulbreaker2:
            if stateCnt == 0 {
                context.world.playSound(
                    named: K2L("effect\\메테오 어썰트.wav"),
                    atWorldPosition: EffectSpace.toWorldPosition(position),
                    delay: 0
                )
            }
            if stateCnt >= 0 && stateCnt <= 10, let targetID = targetObjectID ?? ownerObjectID {
                context.world.applyTargetModifier(
                    .tint(color: SIMD4<Float>(1.0, 0.0, 1.0, 1.0), durationTicks: 2),
                    to: targetID
                )
            }
            for angle in stride(from: 0, to: 360, by: 45) {
                purpleSlash(angle: angle, context: context)
            }
        case .ef_rainbow:
            rainbow(texturePath: "effect\\alpha_center.tga", context: context)
        case .ef_peong:
            for _ in 0..<30 {
                whiteLightTrail(texturePath: "effect\\whitelight.tga", kind: 0, context: context)
            }
            for quarter in 0..<4 {
                let angle = Int16(quarter * 90)
                texturedScatterArc(texturePath: "effect\\peong1.tga", angle: angle, phase: 0, context: context)
                texturedScatterArc(texturePath: "effect\\peong2.tga", angle: angle, phase: 0, context: context)
                texturedScatterArc(texturePath: "effect\\peong3.tga", angle: angle, phase: 0, context: context)
                texturedScatterArc(texturePath: "effect\\peong2.tga", angle: angle, phase: 0, context: context)
            }
        case .ef_tanji2:
            tanji2(context: context)
        case .ef_pressedbody:
            if stateCnt == 5 {
                context.world.playSound(
                    named: K2L("effect\\T_내려찍기.wav"),
                    atWorldPosition: EffectSpace.toWorldPosition(position),
                    delay: 0
                )
            }
            if stateCnt >= 17 && stateCnt <= 50, let targetID = targetObjectID ?? ownerObjectID {
                context.world.applyTargetModifier(.scale(SIMD3<Float>(1.3, 0.5, 1.3), durationTicks: 2), to: targetID)
            }
        case .ef_spinedbody:
            if stateCnt < 18, let targetID = targetObjectID ?? ownerObjectID {
                let spinRoll = Float(stateCnt * 20).truncatingRemainder(dividingBy: 360.0)
                context.world.applyTargetModifier(.spriteRoll(degrees: spinRoll, durationTicks: 2), to: targetID)
            }
        case .ef_kickedbody:
            if stateCnt == 17 {
                context.world.playSound(
                    named: "effect\\EF_hit2.wav",
                    atWorldPosition: EffectSpace.toWorldPosition(position),
                    delay: 0
                )
            }
            if stateCnt == 25 {
                context.world.playSound(
                    named: "effect\\EF_hit4.wav",
                    atWorldPosition: EffectSpace.toWorldPosition(position),
                    delay: 0
                )
            }
            if stateCnt >= 30, let targetID = targetObjectID ?? ownerObjectID {
                let spinRoll = Float((stateCnt - 30) * 15).truncatingRemainder(dividingBy: 360.0)
                context.world.applyTargetModifier(.spriteRoll(degrees: spinRoll, durationTicks: 2), to: targetID)
            }
        case .ef_airtexture:
            airTexture(texturePath: "effect\\emp shock.tga", context: context)
        case .ef_hitbody:
            if stateCnt < 15, let targetID = targetObjectID ?? ownerObjectID {
                context.world.applyTargetModifier(.shake(amplitude: 1.5, durationTicks: 2), to: targetID)
            }
        case .ef_doublegumgang:
            superSlashSpread(count: 2, value: 2, context: context)
        case .ef_reflectbody:
            if let targetID = targetObjectID ?? ownerObjectID {
                context.world.applyTargetModifier(
                    .flash(color: SIMD4<Float>(1.0, 1.0, 1.0, 1.0), durationTicks: 2),
                    to: targetID
                )
            }
        case .ef_babybody:
            if let targetID = targetObjectID ?? ownerObjectID {
                let phase = min(stateCnt, 45)
                let scale = max(0.5, 1.0 - Float(phase) / 90.0)
                context.world.applyTargetModifier(.scale(SIMD3<Float>(scale, scale, scale), durationTicks: 2), to: targetID)
            }
        case .ef_babybody2:
            if stateCnt >= EffectID.ef_babybody2.defaultLifetimeTicks - 1 {
                stateCnt = 0
            }
            if let targetID = targetObjectID ?? ownerObjectID {
                context.world.applyTargetModifier(.scale(SIMD3<Float>(0.5, 0.5, 0.5), durationTicks: 2), to: targetID)
            }
        case .ef_giantbody:
            if let targetID = targetObjectID ?? ownerObjectID {
                let phase = min(stateCnt, 45)
                let scale = 1.0 + Float(phase) / 90.0
                context.world.applyTargetModifier(.scale(SIMD3<Float>(scale, scale, scale), durationTicks: 2), to: targetID)
            }
        case .ef_giantbody2:
            if let targetID = targetObjectID ?? ownerObjectID {
                context.world.applyTargetModifier(.scale(SIMD3<Float>(1.5, 1.5, 1.5), durationTicks: 2), to: targetID)
            }
        case .ef_asurabody:
            if let targetID = targetObjectID ?? ownerObjectID {
                let alpha = Float(min(stateCnt, 200)) / 255.0
                context.world.applyTargetModifier(
                    .flash(color: SIMD4<Float>(1.0, 1.0, 1.0, alpha), durationTicks: 2),
                    to: targetID
                )
            }
        case .ef_4waybody:
            if stateCnt >= 30, let targetID = targetObjectID ?? ownerObjectID {
                context.world.applyTargetModifier(
                    .afterimage(style: .hallucination, tint: nil, durationTicks: 2),
                    to: targetID
                )
            }
        case .ef_quakebody, .ef_quakebody2:
            if let targetID = targetObjectID ?? ownerObjectID {
                context.world.applyTargetModifier(.shake(amplitude: 2.0, durationTicks: 2), to: targetID)
            }
        case .ef_asurabody_monster:
            if stateCnt < 150, let targetID = targetObjectID ?? ownerObjectID {
                let alpha = Float(min(stateCnt + 50, 200)) / 255.0
                context.world.applyTargetModifier(
                    .flash(color: SIMD4<Float>(1.0, 1.0, 1.0, alpha), durationTicks: 2),
                    to: targetID
                )
            }
        case .ef_hitline3:
            whiteSparkStreak(kind: 0, context: context)
        case .ef_hitline4:
            white02Burst(kind: 3, context: context)
        case .ef_hitline5:
            whiteSparkRing(kind: 3, context: context)
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
        case .ef_stormkick:
            if stateCnt == 5 {
                context.world.playSound(
                    named: K2L("effect\\T_회오리차기.wav"),
                    atWorldPosition: EffectSpace.toWorldPosition(position),
                    delay: 0
                )
            }
            texturedMark(texturePath: "effect\\storm2.tga", kind: 0, context: context)
            cloud11Burst(kind: 2, context: context)
            cloud11Burst(kind: 3, context: context)
            if stateCnt <= 47, let targetID = targetObjectID ?? ownerObjectID {
                let spinYaw = Float((stateCnt + 1) * 30).truncatingRemainder(dividingBy: 360.0)
                context.world.applyTargetModifier(.facingYaw(degrees: spinYaw, durationTicks: 2), to: targetID)
            }
        case .ef_halfsphere:
            texturedPulse(texturePath: "effect\\white02.bmp", context: context)
        case .ef_attackenergy:
            texturedPulse(texturePath: "effect\\white02.bmp", context: context)
            texturedBurst(texturePath: "effect\\ring_blue.tga", context: context)
        case .ef_attackenergy2:
            if stateCnt == 0 {
                context.world.playSound(
                    named: K2L("effect\\T_마법반사.wav"),
                    atWorldPosition: EffectSpace.toWorldPosition(position),
                    delay: 0
                )
            }
            attackEnergy2(texturePath: "effect\\cloud11.tga", context: context)
        case .ef_chemical3:
            for _ in 0..<4 {
                lineStreakLayered(kind: 0, context: context)
                lineStreakLayered(kind: 1, context: context)
            }
        case .ef_bluecasting:
            blueSpellRings(context: context)
        case .ef_run:
            if let targetID = targetObjectID ?? ownerObjectID {
                context.world.applyTargetModifier(
                    .afterimage(style: .blur, tint: nil, durationTicks: 2),
                    to: targetID
                )
            }
        case .ef_stoprun, .ef_flowercast2, .ef_flowercast3:
            break
        case .ef_stopeffect:
            if stateCnt == 0 {
                context.world.playSound(
                    named: K2L("effect\\T_효과음1.wav"),
                    atWorldPosition: EffectSpace.toWorldPosition(position),
                    delay: 0
                )
            }
            runStop(angle: 0, context: context)
            runStop(angle: 45, context: context)
        case .ef_jumpbody:
            if stateCnt == 30 {
                context.world.playSound(
                    named: K2L("effect\\T_회피2.wav"),
                    atWorldPosition: EffectSpace.toWorldPosition(position),
                    delay: 0
                )
            }
            if stateCnt > 35, let targetID = targetObjectID ?? ownerObjectID {
                context.world.applyTargetModifier(.scale(SIMD3<Float>(0.9, 1.15, 0.9), durationTicks: 2), to: targetID)
            }
        case .ef_landbody:
            if let targetID = targetObjectID ?? ownerObjectID {
                context.world.applyTargetModifier(.scale(SIMD3<Float>(1.15, 0.85, 1.15), durationTicks: 2), to: targetID)
                if stateCnt < 25 {
                    let spinRoll = Float((stateCnt + 11) * 10).truncatingRemainder(dividingBy: 360.0)
                    context.world.applyTargetModifier(.spriteRoll(degrees: spinRoll, durationTicks: 2), to: targetID)
                }
            }
        case .ef_foot3:
            texturedRise(texturePath: "effect\\foot_l2.tga", large: 1, context: context)
        case .ef_foot4:
            texturedRise(texturePath: "effect\\foot_r2.tga", large: 1, context: context)
        case .ef_tae_ready:
            if stateCnt <= 50, let targetID = targetObjectID ?? ownerObjectID {
                let alpha = Float(stateCnt) / 50.0
                context.world.applyTargetModifier(
                    .flash(color: SIMD4<Float>(1.0, 1.0, 200.0 / 255.0, alpha), durationTicks: 2),
                    to: targetID
                )
            }
        case .ef_grandcross2:
            grandCrossRings(angle: 0, kind: 1, context: context)
            grandCross2(flag: 1, context: context)
        case .ef_soulstrike2:
            soulStrike(flag: 1, context: context)
        case .ef_yufitel2:
            yufitelHit(kind: 1, context: context)
        case .ef_npc_stop:
            npcStop(type: 0, context: context)
        case .ef_darkcasting:
            blackSpellRings(silent: 0, context: context)
        case .ef_gumgangnpc:
            superSlashFan(count: 2, value: 1, context: context)
        case .ef_agiup:
            incAgilityCenter(kind: 0, context: context)
        case .ef_jumpkick:
            if stateCnt == 5 {
                context.world.playSound(
                    named: K2L("effect\\T_날라차기.wav"),
                    atWorldPosition: EffectSpace.toWorldPosition(position),
                    delay: 0
                )
            }
        case .ef_stormkick1:
            texturedMark(texturePath: "effect\\storm2.tga", kind: 1, context: context)
            cloud11Burst(kind: 2, context: context)
            cloud11Burst(kind: 3, context: context)
            if stateCnt <= 50, let targetID = targetObjectID ?? ownerObjectID {
                let spinYaw = Float((stateCnt + 1) * 14).truncatingRemainder(dividingBy: 360.0)
                context.world.applyTargetModifier(.facingYaw(degrees: spinYaw, durationTicks: 2), to: targetID)
            }
        case .ef_stormkick2:
            if stateCnt == 5 {
                context.world.playSound(
                    named: "ice_titan_attack.wav",
                    atWorldPosition: EffectSpace.toWorldPosition(position),
                    delay: 0
                )
            }
            texturedMark(texturePath: "effect\\storm2.tga", kind: 6, context: context)
            cloud11Burst(kind: 2, context: context)
            cloud11Burst(kind: 3, context: context)
        case .ef_stormkick3:
            texturedMark(texturePath: "effect\\storm2.tga", kind: 3, context: context)
            cloud11Burst(kind: 2, context: context)
            cloud11Burst(kind: 3, context: context)
        case .ef_stormkick4, .ef_stormkick5:
            if stateCnt == 15 {
                context.world.playSound(
                    named: K2L("effect\\T_회피.wav"),
                    atWorldPosition: EffectSpace.toWorldPosition(position),
                    delay: 0
                )
            }
            for _ in 0..<30 {
                whiteLightTrail(texturePath: "effect\\whitelight.tga", kind: 1, context: context)
            }
        case .ef_stormkick6:
            if stateCnt == 0 {
                context.world.playSound(
                    named: "effect\\REVERBERATION.wav",
                    atWorldPosition: EffectSpace.toWorldPosition(position),
                    delay: 0
                )
            }
            texturedMark(texturePath: "effect\\storm2.tga", kind: 11, context: context)
            cloud11Burst(kind: 2, context: context)
            cloud11Burst(kind: 3, context: context)
        case .ef_stormkick7:
            texturedMark(texturePath: "effect\\storm2.tga", kind: 2, context: context)
            cloud11Burst(kind: 2, context: context)
            cloud11Burst(kind: 3, context: context)
        case .ef_spinedbody2:
            if stateCnt == 5 {
                context.world.playSound(
                    named: K2L("effect\\T_돌려차기.wav"),
                    atWorldPosition: EffectSpace.toWorldPosition(position),
                    delay: 0
                )
            }
            if stateCnt >= 14 && stateCnt <= 49, let targetID = targetObjectID ?? ownerObjectID {
                let spinRoll = Float((stateCnt - 14) * 10).truncatingRemainder(dividingBy: 360.0)
                context.world.applyTargetModifier(.spriteRoll(degrees: spinRoll, durationTicks: 2), to: targetID)
            }
        case .ef_beginasura1:
            texturedSkillIcon(texturePath: "effect\\hanmoon1.tga", level: 0, mode: 0, context: context)
        case .ef_beginasura2:
            texturedSkillIcon(texturePath: "effect\\hanmoon2.tga", level: 0, mode: 0, context: context)
        case .ef_beginasura3:
            texturedSkillIcon(texturePath: "effect\\hanmoon3.tga", level: 0, mode: 0, context: context)
        case .ef_beginasura4:
            texturedSkillIcon(texturePath: "effect\\hanmoon4.tga", level: 0, mode: 0, context: context)
        case .ef_beginasura5:
            texturedSkillIcon(texturePath: "effect\\hanmoon7.tga", level: 0, mode: 0, context: context)
        case .ef_beginasura6:
            texturedSkillIcon(texturePath: "effect\\hanmoon5.tga", level: 0, mode: 0, context: context)
        case .ef_beginasura7:
            texturedSkillIcon(texturePath: "effect\\hanmoon6.tga", level: 0, mode: 0, context: context)
        case .ef_aurablade2:
            if let targetID = targetObjectID ?? ownerObjectID {
                context.world.applyTargetModifier(
                    .flash(color: SIMD4<Float>(1.0, 1.0, 220.0 / 255.0, 1.0), durationTicks: 2),
                    to: targetID
                )
            }
        case .ef_devil1:
            blind(flag: 1, context: context)
        case .ef_devil2:
            blind(flag: 2, context: context)
        case .ef_devil3:
            blind(flag: 3, context: context)
        case .ef_devil4:
            blind(flag: 4, context: context)
        case .ef_devil5:
            blind(flag: 5, context: context)
        case .ef_devil6:
            blind(flag: 6, context: context)
        case .ef_devil7:
            blind(flag: 7, context: context)
        case .ef_devil8:
            blind(flag: 8, context: context)
        case .ef_devil9:
            blind(flag: 9, context: context)
        case .ef_devil10:
            blind(flag: 10, context: context)
        case .ef_doublegumgang2:
            superSlashSpread(count: 2, value: 1, context: context)
        case .ef_doublegumgang3:
            superSlashSpread(count: 2, value: 0, context: context)
        case .ef_blackdevil:
            texturedRisingRing(texturePath: "effect\\ring_black.tga", context: context)
        case .ef_flowercast:
            if stateCnt == 5 {
                context.world.playSound(
                    named: K2L("effect\\T_안락한마법.wav"),
                    atWorldPosition: EffectSpace.toWorldPosition(position),
                    delay: 0
                )
            }
            if stateCnt < 400, let targetID = targetObjectID ?? ownerObjectID {
                let outlineAlpha = stateCnt < 200 ? stateCnt : (400 - stateCnt)
                context.world.applyTargetModifier(
                    .flash(color: SIMD4<Float>(1.0, 1.0, 1.0, Float(outlineAlpha) / 255.0), durationTicks: 2),
                    to: targetID
                )
            }
            texturedSlashAir(texturePath: "effect\\ring_blue.tga", size: 4, phase: 0, context: context)
            texturedSlashAir(texturePath: "effect\\ring_blue.tga", size: 4, phase: 1, context: context)
        case .ef_edp:
            enchantPoison2(context: context)
            if stateCnt < 81, let targetID = targetObjectID ?? ownerObjectID {
                let color = stateCnt % 2 == 0
                    ? SIMD4<Float>(1.0, 0.0, 1.0, 1.0)
                    : SIMD4<Float>(1.0, 1.0, 1.0, 1.0)
                context.world.applyTargetModifier(.tint(color: color, durationTicks: 2), to: targetID)
            }
        case .ef_shieldboomerang2:
            texturedShieldThrow(texturePath: K2L("effect\\토마.bmp"), context: context)
        case .ef_rg_coin2:
            if stateCnt == 1 || stateCnt == 11 || stateCnt == 21 || stateCnt == 31 {
                context.world.playSound(
                    named: K2L("effect\\복호격.wav"),
                    atWorldPosition: EffectSpace.toWorldPosition(position),
                    delay: 0
                )
            }
            for _ in 0..<4 {
                texturedSprayKind(texturePath: "effect\\shield.bmp", spin: 5.0, kind: 0, context: context)
                texturedSprayKind(texturePath: "effect\\sword.bmp", spin: 9.0, kind: 0, context: context)
            }
        case .ef_guard2:
            blackMaximize(texturePath: "effect\\a01.bmp", context: context)
            if stateCnt >= 10 && stateCnt <= 30, let targetID = targetObjectID ?? ownerObjectID {
                let color = stateCnt % 2 == 0
                    ? SIMD4<Float>(250.0 / 255.0, 250.0 / 255.0, 250.0 / 255.0, 1.0)
                    : SIMD4<Float>(1.0, 1.0, 1.0, 1.0)
                context.world.applyTargetModifier(.tint(color: color, durationTicks: 2), to: targetID)
            }
        case .ef_slim:
            texturedRain(texturePath: K2L("유저인터페이스\\item\\레드슬림포션.bmp"), kind: 1, context: context)
            texturedLevelRing(texturePath: "effect\\bbbb.bmp", process: -16, level: 1, context: context)
        case .ef_slim2:
            texturedRain(texturePath: K2L("유저인터페이스\\item\\옐로우슬림포션.bmp"), kind: 2, context: context)
            texturedLevelRing(texturePath: "effect\\bbbb.bmp", process: -16, level: 2, context: context)
        case .ef_slim3:
            texturedRain(texturePath: K2L("유저인터페이스\\item\\화이트슬림포션.bmp"), kind: 3, context: context)
            texturedLevelRing(texturePath: "effect\\bbbb.bmp", process: -16, level: 0, context: context)
        default:
            return false
        }
        return true
    }

    // MARK: - EF_BABY (408)

    /// Spawns 4-slot orbiting feather/ivy bursts (`PP_SPHEREWIND2` (91)) for `EF_BABY` (408).
    func featherBurst(texturePath: String, angle: Int16, flag: Int8, context: EffectTickContext) {
        guard stateCnt == 0 else {
            return
        }

        _ = context.assets?.texture(atPath: texturePath)

        let primitive = launchPrimitive(.pp_spherewind2)
        primitive.state.renderFlag = EffectPrimitiveState.RenderFlag.alpha | EffectPrimitiveState.RenderFlag.customBlend
        primitive.state.duration = duration
        primitive.state.totalTexture = 1
        primitive.state.texturePaths = [texturePath]
        primitive.state.size = 10.0

        for slot in 0..<4 {
            primitive.state.slots[slot].life = 1
            primitive.state.slots[slot].process = -Int.random(in: 0..<20)
            primitive.state.slots[slot].maxHeight = Float(Int.random(in: 0..<11)) * 0.2 + 2.0
            primitive.state.slots[slot].distance = 5.0
            primitive.state.slots[slot].height[0] = -10.0
            primitive.state.slots[slot].rotStart = Int16(Int.random(in: 0..<360))
            primitive.state.slots[slot].riseAngle = Int16(slot * 45) + angle
            primitive.state.slots[slot].alphaB = 0
            primitive.state.slots[slot].fullDisplayAngle = Int16(Int.random(in: 0..<91) + 180)
            primitive.state.slots[slot].height[1] = Float(Int.random(in: 0..<4) + 3)
        }
    }

    // MARK: - EF_SOULBREAKER2 (409)

    /// Spawns 4-slot radial purple slash waves (`92`) for `EF_SOULBREAKER2` (409).
    func purpleSlash(angle: Int, context: EffectTickContext) {
        guard stateCnt == 0 else {
            return
        }

        let texturePath = "effect\\purpleslash.tga"
        _ = context.assets?.texture(atPath: texturePath)

        let primitive = launchPrimitive(92)
        primitive.state.renderFlag = EffectPrimitiveState.RenderFlag.alpha | EffectPrimitiveState.RenderFlag.customBlend
        primitive.state.duration = duration
        primitive.state.totalTexture = 1
        primitive.state.texturePaths = [texturePath]
        primitive.state.size = 0

        let offset = Int.random(in: 0..<6)
        for index in 0..<4 {
            primitive.state.slots[index].life = 1
            primitive.state.slots[index].process = index - 28 - offset
            primitive.state.slots[index].distance = 20.0
            primitive.state.slots[index].alphaB = 0
            primitive.state.slots[index].vecBNow = SIMD3<Float>(
                position.x,
                Float(Int.random(in: 0..<5)) + (position.y - 10.0),
                position.z
            )
            primitive.state.slots[index].rotStart = Int16(angle)
            primitive.state.slots[index].height[1] = 0.8
            primitive.state.slots[index].flag1[0] = 0
            primitive.state.slots[index].flag1[1] = 0
        }
    }

    // MARK: - EF_RAINBOW (410)

    /// Spawns `PP_RAINBOW` (93) 7-band spectral arch for `EF_RAINBOW` (410).
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

    // MARK: - EF_PEONG (411)

    /// Spawns rising light streak trails (`PP_PEONGUP` (96)) for `EF_PEONG` (411), `EF_STORMKICK4` (462), and `EF_STORMKICK5` (463).
    func whiteLightTrail(texturePath: String, kind: Int8, context: EffectTickContext) {
        let limit: Int
        if kind == 0 {
            limit = 35
        } else if kind == 1 {
            limit = 0
        } else {
            return
        }
        guard stateCnt == limit else {
            return
        }

        _ = context.assets?.texture(atPath: texturePath)

        let primitive = launchPrimitive(.pp_peongup)
        primitive.state.renderFlag = EffectPrimitiveState.RenderFlag.alpha | EffectPrimitiveState.RenderFlag.customBlend
        primitive.state.duration = duration
        primitive.state.texturePaths = [texturePath]
        primitive.state.size = 0
        for i in 0..<4 {
            primitive.state.slots[i].life = 0
        }

        if kind == 0 {
            let heading = Int.random(in: 0..<360)
            primitive.state.slots[0].life = 1
            primitive.state.slots[0].maxHeight = Float(Int.random(in: 0..<16)) * 0.01 + 0.1
            primitive.state.slots[0].distance = Float(Int.random(in: 0..<11)) * 0.1 + 3.0
            primitive.state.slots[0].process = -Int.random(in: 0..<26)
            primitive.state.slots[0].alphaB = 0
            primitive.state.slots[0].vecBPre = SIMD3<Float>(
                EffectSpace.cosine(degrees: heading) * 2.5,
                Float(-Int.random(in: 0..<8)),
                EffectSpace.sine(degrees: heading) * 2.5
            )
            for h in 0..<4 {
                primitive.state.slots[0].height[h] = Float(Int.random(in: 0..<360))
            }
            primitive.state.slots[0].flag1[0] = 1
            return
        }

        if kind == 1 {
            for index in 0..<4 {
                let heading = Int.random(in: 0..<360)
                primitive.state.slots[index].life = 1
                primitive.state.slots[index].maxHeight = Float(Int.random(in: 0..<11)) * 0.005 + 0.08
                primitive.state.slots[index].distance = Float(Int.random(in: 0..<11)) * 0.05 + 2.0
                primitive.state.slots[index].process = -Int.random(in: 0..<26)
                primitive.state.slots[index].alphaB = 0
                primitive.state.slots[index].vecBPre = SIMD3<Float>(
                    EffectSpace.cosine(degrees: heading) * 3.5,
                    Float(-Int.random(in: 0..<8)),
                    EffectSpace.sine(degrees: heading) * 3.5
                )
                for h in 0..<4 {
                    primitive.state.slots[index].height[h] = Float(Int.random(in: 0..<360))
                }
                primitive.state.slots[index].flag1[0] = 2
            }
        }
    }

    /// Spawns 4-slot radial scatter bursts (`PP_PEONG` (94)) for `EF_PEONG` (411).
    func texturedScatterArc(texturePath: String, angle: Int16, phase: Int, context: EffectTickContext) {
        let startCnt: Int
        if phase == 0 {
            startCnt = 35
        } else if phase == 1 {
            startCnt = 0
        } else {
            startCnt = phase
        }
        guard stateCnt == startCnt else {
            return
        }

        _ = context.assets?.texture(atPath: texturePath)

        let primitive = launchPrimitive(.pp_peong)
        primitive.state.renderFlag = EffectPrimitiveState.RenderFlag.alpha | EffectPrimitiveState.RenderFlag.customBlend
        primitive.state.duration = duration
        primitive.state.texturePaths = [texturePath]
        primitive.state.size = 0

        for index in 0..<4 {
            var direction = Int16(Int.random(in: 0..<90)) + angle
            if direction >= 360 {
                direction -= 360
            }
            let cosine = EffectSpace.cosine(degrees: Int(direction))
            let sine = EffectSpace.sine(degrees: Int(direction))
            primitive.state.slots[index].life = 1
            primitive.state.slots[index].distance = Float(Int.random(in: 0..<11)) * 0.2 + 2.5
            primitive.state.slots[index].alphaB = 0
            primitive.state.slots[index].process = -Int.random(in: 0..<11)
            primitive.state.slots[index].riseAngle = direction
            primitive.state.slots[index].maxHeight = 0.03
            primitive.state.slots[index].vecBPre = SIMD3<Float>(cosine * 4.0, 0, sine * 4.0)
            primitive.state.slots[index].vecBNow.y = -4.0
            for h in 0..<4 {
                primitive.state.slots[index].height[h] = Float(Int.random(in: 0..<360))
            }
        }
    }

    // MARK: - EF_TANJI2 (412)

    /// Spawns an enhanced spirit sphere throw (`PP_TANJI2` (97)) for `EF_TANJI2` (412).
    func tanji2(context: EffectTickContext) {
        guard stateCnt == 0 else {
            return
        }

        let texturePath = "effect\\blue_ivy.bmp"
        _ = context.assets?.texture(atPath: texturePath)

        let (origin, destination) = directionalLaunchEndpoints()
        let dx = destination.x - origin.x
        let dz = destination.z - origin.z
        let travelDistance = max(0.001, sqrtf(dx * dx + dz * dz))

        let primitive = launchPrimitive(.pp_tanji2)
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

    // MARK: - EF_AIRTEXTURE (416)

    /// Spawns directional shockwave billboard (`98`) for `EF_AIRTEXTURE` (416).
    func airTexture(texturePath: String, context: EffectTickContext) {
        guard stateCnt == 0 else {
            return
        }

        _ = context.assets?.texture(atPath: texturePath)

        let primitive = launchPrimitive(98)
        primitive.state.renderFlag = EffectPrimitiveState.RenderFlag.alpha | EffectPrimitiveState.RenderFlag.customBlend
        primitive.state.duration = duration
        primitive.state.texturePaths = [texturePath]
        primitive.state.size = 0
        primitive.state.slots[0].life = 1
        primitive.state.slots[0].process = 0
        primitive.state.slots[0].distance = 5.0
        primitive.state.slots[0].alphaB = 0
        primitive.state.slots[0].vecBNow = deltaPos
        primitive.state.slots[0].fullDisplayAngle = Int16(Int.random(in: 0..<360))
        var rise = EffectPrimitive.angle(dx: deltaPos.x - position.x, dy: deltaPos.z - position.z) + 90
        if rise >= 360 {
            rise -= 360
        }
        primitive.state.slots[0].riseAngle = rise
        for i in 1..<4 {
            primitive.state.slots[i].life = 0
            primitive.state.slots[i].alphaB = 0
        }
    }

    // MARK: - EF_DOUBLEGUMGANG (418)

    /// Spawns spreading aura slash streaks (`PP_DOUBLEGUMGANG` (99)) for `EF_DOUBLEGUMGANG` (418), `EF_DOUBLEGUMGANG2` (485), and `EF_DOUBLEGUMGANG3` (486).
    func superSlashSpread(count: Int8, value: Int8, context: EffectTickContext) {
        guard stateCnt == 0 else {
            return
        }

        let textures = (1...5).map { "effect\\super\($0).bmp" }
        for path in textures {
            _ = context.assets?.texture(atPath: path)
        }

        let primitive = launchPrimitive(.pp_doublegumgang)
        primitive.state.renderFlag = EffectPrimitiveState.RenderFlag.alpha | EffectPrimitiveState.RenderFlag.customBlend
        primitive.state.duration = duration
        primitive.state.totalTexture = 5
        primitive.state.texturePaths = textures
        primitive.state.size = 0

        for i in 0..<4 {
            primitive.state.slots[i].life = 0
        }

        for i in 0..<max(0, Int(count)) where i < 4 {
            primitive.state.slots[i].process = 0
            primitive.state.slots[i].life = 1
            primitive.state.slots[i].distance = 2.0
            primitive.state.slots[i].vecBPre.y = -Float(Int.random(in: 0..<10))
            primitive.state.slots[i].height[0] = 10.0
            primitive.state.slots[i].height[1] = 40.0
            primitive.state.slots[i].height[2] = Float(Int.random(in: 0..<5))
            primitive.state.slots[i].height[3] = Float(Int.random(in: 0..<360))
            primitive.state.slots[i].vecBNow.y = -Float(Int.random(in: 0..<10))
            primitive.state.slots[i].height[4] = 10.0
            primitive.state.slots[i].height[5] = 80.0
            primitive.state.slots[i].height[6] = Float(Int.random(in: 0..<5))
            primitive.state.slots[i].height[7] = Float(Int.random(in: 0..<360))
            primitive.state.slots[i].vecTPre.y = -Float(Int.random(in: 0..<10))
            primitive.state.slots[i].height[8] = 10.0
            primitive.state.slots[i].height[9] = 120.0
            primitive.state.slots[i].height[10] = Float(Int.random(in: 0..<5))
            primitive.state.slots[i].height[11] = Float(Int.random(in: 0..<360))
            primitive.state.slots[i].vecTNow.y = -Float(Int.random(in: 0..<10))
            primitive.state.slots[i].height[12] = 10.0
            primitive.state.slots[i].height[13] = 160.0
            primitive.state.slots[i].height[14] = Float(Int.random(in: 0..<5))
            primitive.state.slots[i].height[15] = Float(Int.random(in: 0..<360))
            primitive.state.slots[i].flag1[4] = value
        }
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

    // MARK: - EF_HITLINE4 (429)

    /// Emits `PP_HITLINE3` (100) delayed spark bursts on ticks `6...9` for `EF_HITLINE4` (429).
    func white02Burst(kind: Int16, context: EffectTickContext) {
        guard stateCnt >= 6, stateCnt <= 9 else {
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
            primitive.state.slots[index].process = -Int.random(in: 0..<31)
            primitive.state.slots[index].maxHeight = kind == 3 ? 0.05 : 0.1
            primitive.state.slots[index].alphaB = Int16(Int.random(in: 0..<121) + 125)
            primitive.state.slots[index].riseAngle = Int16(Int.random(in: 0..<360))
            primitive.state.slots[index].distance = Float(Int.random(in: 0..<6)) + 6.0
            primitive.state.slots[index].height[0] = 0
            primitive.state.slots[index].vecTNow.x = Float(Int.random(in: 0..<7)) * 0.1 + 0.8
            primitive.state.slots[index].vecBNow = position
            primitive.state.slots[index].vecTNow.y = 4.0
            for step in 1...20 {
                primitive.state.slots[index].height[step] = 0
                primitive.state.slots[index].flag1[step] = 0
            }
            primitive.state.slots[index].alphaT = kind
        }
    }

    // MARK: - EF_HITLINE5 (430)

    /// Emits `PP_HITLINE3` (100) directional fan sparks on ticks `0...2` for `EF_HITLINE5` (430).
    func whiteSparkRing(kind: Int16, context: EffectTickContext) {
        guard stateCnt >= 0, stateCnt <= 2 else {
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
        primitive.state.deltaPos = deltaPos
        primitive.position = position

        let baseAngle = EffectPrimitive.angle(dx: position.x - deltaPos.x, dy: position.z - deltaPos.z)
        for index in 0..<4 {
            primitive.state.slots[index].life = 1
            if kind == 3 {
                primitive.state.slots[index].process = -(25 + Int.random(in: 0..<21))
                primitive.state.slots[index].maxHeight = 0.06
            } else {
                primitive.state.slots[index].process = -(15 + Int.random(in: 0..<26))
                primitive.state.slots[index].maxHeight = 0.07
            }
            primitive.state.slots[index].alphaB = Int16(Int.random(in: 0..<121) + 125)
            var rise = baseAngle + Int16(Int.random(in: 0..<121) - 60)
            if rise >= 360 {
                rise -= 360
            }
            if rise < 0 {
                rise += 360
            }
            primitive.state.slots[index].riseAngle = rise
            primitive.state.slots[index].distance = Float(Int.random(in: 0..<7)) + 6.0
            primitive.state.slots[index].height[0] = 0
            primitive.state.slots[index].vecTNow.x = Float(Int.random(in: 0..<7)) * 0.1 + 0.8
            primitive.state.slots[index].vecBNow = position
            primitive.state.slots[index].vecTNow.y = 3.0
            for step in 1...20 {
                primitive.state.slots[index].height[step] = 0
                primitive.state.slots[index].flag1[step] = 0
            }
            primitive.state.slots[index].alphaT = kind
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

    // MARK: - EF_STORMKICK (435)

    /// Spawns stacked tornado ring cylinder (`103`) for `EF_STORMKICK` (435) and `EF_STORMKICK1..7` variants.
    func texturedMark(texturePath: String, kind: Int8, context: EffectTickContext) {
        guard stateCnt == 0 else {
            return
        }

        _ = context.assets?.texture(atPath: texturePath)

        let primitive = launchPrimitive(103)
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
        primitive.state.slots[0].maxHeight = 40.0
        primitive.state.slots[0].alphaB = 0
        primitive.state.slots[0].rotStart = Int16(Int.random(in: 0..<360))
        primitive.state.slots[0].distance = 2.0
        primitive.state.slots[0].height[0] = 50.0
        primitive.state.slots[0].height[1] = 5.0
        primitive.state.slots[0].flag1[0] = 10
        primitive.state.slots[0].flag1[4] = kind
        primitive.state.slots[0].flag1[5] = 0

        if kind == 10 {
            primitive.state.slots[0].maxHeight = 14.0
            primitive.state.slots[0].height[0] = 70.0
            primitive.state.slots[0].flag1[0] = 14
            primitive.state.slots[0].distance = 0
            primitive.state.slots[0].flag1[5] = 1
        } else if kind == 2 {
            primitive.state.slots[0].flag1[5] = 10
        }
    }

    // MARK: - EF_HALFSPHERE (436)

    /// Spawns pulsing energy dome (`PP_HALFSPHERE` (104)) for `EF_HALFSPHERE` (436) and `EF_ATTACKENERGY` (437).
    func texturedPulse(texturePath: String, context: EffectTickContext) {
        guard stateCnt == 0 else {
            return
        }

        _ = context.assets?.texture(atPath: texturePath)

        let primitive = launchPrimitive(.pp_halfsphere)
        primitive.state.renderFlag = EffectPrimitiveState.RenderFlag.alpha | EffectPrimitiveState.RenderFlag.noDepth
        primitive.state.duration = duration
        primitive.state.totalTexture = 1
        primitive.state.texturePaths = [texturePath]
        primitive.state.size = 0

        for i in 1..<4 {
            primitive.state.slots[i].life = 0
        }
        primitive.state.slots[0].life = 1
        primitive.state.slots[0].process = 0
        primitive.state.slots[0].maxHeight = 8.0
        primitive.state.slots[0].alphaB = 0
        primitive.state.slots[0].distance = 8.0
        primitive.state.slots[0].fullDisplayAngle = 180
    }

    // MARK: - EF_ATTACKENERGY (437)

    /// Spawns 4-slot ice-white energy burst (`105`) for `EF_ATTACKENERGY` (437).
    func texturedBurst(texturePath: String, context: EffectTickContext) {
        guard stateCnt == 0 else {
            return
        }

        _ = context.assets?.texture(atPath: texturePath)

        let primitive = launchPrimitive(105)
        primitive.state.renderFlag = EffectPrimitiveState.RenderFlag.alpha | EffectPrimitiveState.RenderFlag.noDepth
        primitive.state.duration = duration
        primitive.state.totalTexture = 1
        primitive.state.texturePaths = [texturePath]
        primitive.state.size = 100.0

        for index in 0..<4 {
            primitive.state.slots[index].life = 1
            primitive.state.slots[index].process = 0
            primitive.state.slots[index].maxHeight = 8.0
            primitive.state.slots[index].alphaB = 0
            primitive.state.slots[index].distance = 8.0
            primitive.state.slots[index].fullDisplayAngle = 360
            primitive.state.slots[index].height[0] = 20.0
            primitive.state.slots[index].riseAngle = Int16(index * 45)
        }
    }

    // MARK: - EF_ATTACKENERGY2 (438)

    /// Spawns 4-slot rotating reflection arcs (`PP_ATTACKENERGY2` (106)) on ticks 0 and 4 for `EF_ATTACKENERGY2` (438).
    func attackEnergy2(texturePath: String, context: EffectTickContext) {
        guard stateCnt == 0 || stateCnt == 4 else {
            return
        }

        _ = context.assets?.texture(atPath: texturePath)

        let primitive = launchPrimitive(.pp_attackenergy2)
        primitive.state.renderFlag = EffectPrimitiveState.RenderFlag.alpha | EffectPrimitiveState.RenderFlag.customBlend
        primitive.state.duration = duration
        primitive.state.totalTexture = 1
        primitive.state.texturePaths = [texturePath]
        primitive.state.size = 4.0

        for index in 0..<4 {
            primitive.state.slots[index].life = 1
            primitive.state.slots[index].process = 0
            primitive.state.slots[index].maxHeight = 8.0
            primitive.state.slots[index].alphaB = 0
            primitive.state.slots[index].distance = 8.0
            primitive.state.slots[index].fullDisplayAngle = 360
            primitive.state.slots[index].height[0] = 10.0
            primitive.state.slots[index].riseAngle = Int16(index * 45)
            primitive.state.slots[index].height[1] = Float(index * 22)
        }
    }

    // MARK: - EF_CHEMICAL3 (439)

    /// Spawns 4-slot layered line streaks (`PP_CHEMICAL3` (56)) for `EF_CHEMICAL3` (439).
    func lineStreakLayered(kind: Int16, context: EffectTickContext) {
        guard stateCnt == 0 else {
            return
        }

        let texturePath = kind < 10 ? "effect\\line3.tga" : "effect\\line3y.tga"
        _ = context.assets?.texture(atPath: texturePath)

        let primitive = launchPrimitive(.pp_chemical3)
        primitive.state.renderFlag = EffectPrimitiveState.RenderFlag.alpha | EffectPrimitiveState.RenderFlag.noDepth
        primitive.state.duration = duration
        primitive.state.texturePaths = [texturePath]

        let riseAngle = EffectPrimitive.angle(dx: deltaPos.x - position.x, dy: deltaPos.z - position.z)
        for i in 0..<4 {
            primitive.state.slots[i].life = 1
            primitive.state.slots[i].process = 0
            primitive.state.slots[i].distance = 100.0

            if kind % 10 == 0 {
                primitive.state.slots[i].height[0] = -15.0 - Float(Int.random(in: 0..<11))
            } else if kind % 10 == 1 {
                primitive.state.slots[i].height[0] = Float(Int.random(in: 0..<11)) + 15.0
            }

            primitive.state.slots[i].height[1] = Float(Int.random(in: 0..<200))

            if kind < 10 {
                primitive.state.slots[i].maxHeight = Float(Int.random(in: 0..<4)) * 0.1 + 0.3
                primitive.state.slots[i].height[2] = Float(Int.random(in: 0..<31)) + 20.0
                primitive.state.slots[i].flag1[0] = Int8(Int.random(in: 0..<3))
                primitive.state.slots[i].height[3] = Float(Int.random(in: 0..<21)) * 0.1 + 1.5
            } else if kind < 20 {
                primitive.state.slots[i].maxHeight = Float(Int.random(in: 0..<6)) * 0.1 + 0.5
                primitive.state.slots[i].height[2] = Float(Int.random(in: 0..<31)) + 40.0
                primitive.state.slots[i].flag1[0] = Int8(Int.random(in: 0..<3) + 10)
                primitive.state.slots[i].height[3] = Float(Int.random(in: 0..<11)) * 0.1 + 1.0
            } else {
                primitive.state.slots[i].maxHeight = Float(Int.random(in: 0..<4)) * 0.1 + 0.4
                primitive.state.slots[i].height[2] = Float(Int.random(in: 0..<31)) + 30.0
                primitive.state.slots[i].flag1[0] = Int8(Int.random(in: 0..<3) + 20)
                primitive.state.slots[i].height[3] = Float(Int.random(in: 0..<21)) * 0.1 + 1.5
            }

            primitive.state.slots[i].riseAngle = riseAngle
            primitive.state.slots[i].alphaB = 0
        }
    }

    // MARK: - EF_BLUECASTING (441)

    /// Spawns dual blue spell-casting rings and plays begin-spell audio for `EF_BLUECASTING` (441).
    func blueSpellRings(context: EffectTickContext) {
        guard stateCnt == 0 else {
            return
        }

        context.world.playSound(
            named: "effect\\EF_BeginSpell.wav",
            atWorldPosition: EffectSpace.toWorldPosition(position),
            delay: 0
        )
        texturedQuadRingSized(baseAlpha: 45, texturePath: "effect\\ring_blue.tga", kind: 5, context: context)
        texturedQuadRingSized(baseAlpha: 25, texturePath: "effect\\ring_blue.tga", kind: 5, context: context)
    }

    // MARK: - EF_STOPEFFECT (444)

    /// Spawns 4-slot blue brake rays (`PP_SLASH1` (75)) for `EF_STOPEFFECT` (444).
    func runStop(angle: Int16, context: EffectTickContext) {
        guard stateCnt == 0 else {
            return
        }

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
            primitive.state.slots[i].distance = 2.0
            primitive.state.slots[i].height[0] = 1.0
            primitive.state.slots[i].maxHeight = 0
            primitive.state.slots[i].rotStart = Int16(i * 90) + angle
            primitive.state.slots[i].alphaB = 0
            primitive.state.slots[i].flag1[0] = 1
        }
    }

    // MARK: - EF_NPC_STOP (453)

    /// Spawns stop/confine status sprite (`51`) for `EF_NPC_STOP` (453).
    func npcStop(type: Int8, context: EffectTickContext) {
        guard stateCnt == 0 else {
            return
        }

        let primitive = launchPrimitive(51)
        primitive.state.renderFlag |= EffectPrimitiveState.RenderFlag.noDepth
        primitive.state.duration = duration
        primitive.state.slots[0].life = 1
        primitive.state.slots[0].process = 0
        primitive.state.slots[0].maxHeight = 0
        primitive.state.size = 1.0
        primitive.state.slots[0].vecBPre = position
        primitive.state.slots[0].flag1[4] = 1

        let spritePath: String
        let actionPath: String
        if type != 2 {
            primitive.state.slots[0].vecBPre.y -= 7.0
            primitive.state.alpha = 200.0
            spritePath = K2L("이팩트\\스톱.spr")
            actionPath = K2L("이팩트\\스톱.act")
            primitive.state.animSpeed = 4
            primitive.currentMotion = 0
        } else {
            primitive.state.alpha = 100.0
            spritePath = K2L("이팩트\\cconfine.spr")
            actionPath = K2L("이팩트\\cconfine.act")
            primitive.state.animSpeed = 12
            primitive.state.repeatAnim = false
            primitive.state.pattern = 0x800
        }

        _ = context.assets?.spriteAsset(spritePath: spritePath, actionPath: actionPath)
        primitive.state.spritePath = spritePath
        primitive.state.actionPath = actionPath
        primitive.initSegment()
        for i in 1..<4 {
            primitive.state.slots[i].life = 0
        }
    }

    // MARK: - EF_DARKCASTING (454)

    /// Spawns dual black spell-casting rings for `EF_DARKCASTING` (454).
    func blackSpellRings(silent: Int8, context: EffectTickContext) {
        guard stateCnt == 0 else {
            return
        }

        if silent == 0 {
            context.world.playSound(
                named: "effect\\EF_BeginSpell.wav",
                atWorldPosition: EffectSpace.toWorldPosition(position),
                delay: 0
            )
        }
        texturedQuadRingSized(baseAlpha: 45, texturePath: "effect\\ring_black.tga", kind: 6, context: context)
        texturedQuadRingSized(baseAlpha: 25, texturePath: "effect\\ring_black.tga", kind: 6, context: context)
    }

    // MARK: - EF_AGIUP (456)

    /// Spawns rising speed-up streaks (`PP_3DCROSSTEXTURE` (16)) on even ticks for `EF_AGIUP` (456).
    func incAgilityCenter(kind: Int8, context: EffectTickContext) {
        if stateCnt == 0 {
            let soundName = kind == 3 ? K2L("effect\\소울 체인지.wav") : "effect\\EF_IncAgility.wav"
            context.world.playSound(
                named: soundName,
                atWorldPosition: EffectSpace.toWorldPosition(position),
                delay: 0
            )
        }

        guard (stateCnt & 1) == 0 else {
            return
        }

        let texturePath = "effect\\ac_center2.tga"
        _ = context.assets?.texture(atPath: texturePath)

        let streak = launchPrimitive(.pp_3dcrosstexture)
        streak.state.duration = 50
        let yaw = EffectSpace.rotationY(radians: EffectSpace.radian(degrees: Int.random(in: 0..<360)))
        streak.state.deltaPos2 = EffectSpace.transformVector(SIMD3<Float>(0, 0, Float(Int.random(in: 0..<7) + 2)), by: yaw)
        streak.state.transform = EffectSpace.rotationX(radians: EffectSpace.radian(degrees: 90))

        if kind >= 2 {
            streak.state.speed = Float(Int.random(in: 0..<50) + 40) / 100.0
            streak.state.widthSize = Float(Int.random(in: 0..<100) + 40) / 10.0
            streak.state.heightSize = Float(Int.random(in: 0..<6)) * 0.05 + 0.1
        } else {
            streak.state.speed = Float(Int.random(in: 0..<50) + 20) / 100.0
            streak.state.widthSize = Float(Int.random(in: 0..<100) + 20) / 10.0
            streak.state.heightSize = Float(Int.random(in: 0..<4)) * 0.1 + 0.1
        }

        streak.state.alpha = 0
        streak.state.maxAlpha = 60.0
        streak.state.alphaSpeed = streak.state.maxAlpha / 20.0
        streak.state.fadeOutCnt = streak.state.duration - 20
        streak.state.texturePaths = [texturePath]
    }

    // MARK: - EF_BEGINASURA1 (467)

    /// Spawns calligraphic/skill icon billboard (`PP_ASURACASTING` (68)) for `EF_BEGINASURA1...7` (467...473).
    func texturedSkillIcon(texturePath: String, level: Int16, mode: Int16, context: EffectTickContext) {
        guard stateCnt == Int(level) else {
            return
        }

        _ = context.assets?.texture(atPath: texturePath)

        let primitive = launchPrimitive(.pp_asuracasting)
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
        if level > 0 {
            primitive.state.slots[0].distance = 5.0
            primitive.state.slots[0].height[0] = 1.0
            primitive.state.slots[0].flag1[4] = 4
        } else {
            primitive.state.slots[0].distance = mode == 3 ? 7.0 : 18.0
            primitive.state.slots[0].height[0] = 0
            primitive.state.slots[0].flag1[4] = 1
        }
        primitive.state.slots[0].alphaB = 0
        primitive.state.slots[0].flag1[0] = 0
        for index in 1..<21 {
            primitive.state.slots[0].height[index] = 0
        }
        primitive.state.slots[0].flag1[5] = 0
    }

    // MARK: - EF_BLACKDEVIL (487)

    /// Spawns two-wave dark-gray rising rings (`107`) on ticks 1 and 2 for `EF_BLACKDEVIL` (487).
    func texturedRisingRing(texturePath: String, context: EffectTickContext) {
        guard stateCnt == 1 || stateCnt == 2 else {
            return
        }

        _ = context.assets?.texture(atPath: texturePath)

        let primitive = launchPrimitive(107)
        primitive.state.renderFlag = EffectPrimitiveState.RenderFlag.alpha | EffectPrimitiveState.RenderFlag.customBlend
        primitive.state.duration = duration
        primitive.state.texturePaths = [texturePath]
        primitive.state.size = 12.0

        let isSecondWave = stateCnt == 2
        let configs: [(rotStart: Int16, distance: Float, riseAngle: Int16)] = isSecondWave
            ? [
                (271, 2.7, 52),
                (1, 5.2, 59),
                (91, 7.7, 54),
                (181, 10.2, 49),
            ]
            : [
                (270, 2.5, 53),
                (0, 5.0, 60),
                (90, 7.5, 55),
                (180, 10.0, 50),
            ]

        for (index, config) in configs.enumerated() {
            primitive.state.slots[index].life = 1
            primitive.state.slots[index].process = 0
            primitive.state.slots[index].fullDisplayAngle = 360
            primitive.state.slots[index].rotStart = config.rotStart
            primitive.state.slots[index].alphaB = 0
            primitive.state.slots[index].distance = config.distance
            primitive.state.slots[index].maxHeight = config.distance
            primitive.state.slots[index].riseAngle = config.riseAngle
            primitive.state.slots[index].vecBNow.y = 0
            primitive.state.slots[index].height = Array(repeating: 0, count: 21)
            primitive.state.slots[index].flag1 = Array(repeating: 0, count: 21)
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

    // MARK: - EF_EDP (493)

    /// Emits rising poison sprites (`PP_3DPARTICLE` (5)) and enchant poison sounds for `EF_EDP` (493).
    func enchantPoison2(context: EffectTickContext) {
        if stateCnt == 0 || stateCnt == 5 || stateCnt == 11 || stateCnt == 18 || stateCnt == 26 || stateCnt == 40 {
            context.world.playSound(
                named: "effect\\assasin_enchantpoison.wav",
                atWorldPosition: EffectSpace.toWorldPosition(position),
                delay: 0
            )
        }

        guard stateCnt % 3 == 0 else {
            return
        }

        let spritePath = K2L("이팩트\\particle3.spr")
        let actionPath = K2L("이팩트\\particle3.act")
        _ = context.assets?.spriteAsset(spritePath: spritePath, actionPath: actionPath)

        let particle = launchPrimitive(.pp_3dparticle)
        particle.state.duration = 40
        let yaw = EffectSpace.rotationY(radians: EffectSpace.radian(degrees: Int.random(in: 0..<360)))
        particle.state.deltaPos2 = EffectSpace.transformVector(SIMD3<Float>(0, 0, Float(Int.random(in: 0..<6) + 2)), by: yaw)
        particle.state.transform = EffectSpace.rotationX(radians: EffectSpace.radian(degrees: 90))
        particle.state.speed = Float(Int.random(in: 0..<50) + 30) / 100.0
        particle.state.accel = -(particle.state.speed / Float(particle.state.duration)) * 0.5
        particle.state.size = Float(Int.random(in: 0..<20) + 20) / 100.0
        particle.state.rollSpeed = 3.0
        particle.state.alpha = 0
        particle.state.alphaSpeed = particle.state.maxAlpha / 10.0
        particle.state.fadeOutCnt = particle.state.duration - particle.state.duration / 5
        particle.state.spritePath = spritePath
        particle.state.actionPath = actionPath
        particle.initSegment()
    }

    // MARK: - EF_RG_COIN2 (495)

    /// Spawns 4-slot spinning item spray (`PP_INTIMIDATE` (43)) for `EF_RG_COIN2` (495).
    func texturedSprayKind(texturePath: String, spin: Float, kind: Int8, context: EffectTickContext) {
        guard stateCnt == 0 else {
            return
        }

        _ = context.assets?.texture(atPath: texturePath)

        let primitive = launchPrimitive(.pp_intimidate)
        primitive.state.renderFlag = EffectPrimitiveState.RenderFlag.alpha | EffectPrimitiveState.RenderFlag.customBlend
        primitive.state.duration = duration
        primitive.state.texturePaths = [texturePath]
        position.y -= 12.0

        let modeFlag: Int8 = switch kind {
        case 1: 6
        case 7: 7
        case 8: 8
        case 9: 9
        default: 2
        }

        for index in 0..<4 {
            primitive.state.slots[index].life = 1
            primitive.state.slots[index].vecBNow = deltaPos
            primitive.state.slots[index].process = -18 - Int.random(in: 0..<30)
            primitive.state.slots[index].distance = 12.0
            primitive.state.slots[index].height[0] = 1.0
            primitive.state.slots[index].riseAngle = Int16(Int.random(in: 0..<360))
            primitive.state.slots[index].fullDisplayAngle = Int16(Int.random(in: 0..<360))
            primitive.state.slots[index].rotStart = Int16(Int.random(in: 0..<360))
            primitive.state.slots[index].height[2] = Float(Int.random(in: 0..<360))
            primitive.state.slots[index].height[1] = spin
            primitive.state.slots[index].alphaB = 0
            primitive.state.slots[index].flag1[0] = modeFlag
        }
    }

    // MARK: - EF_GUARD2 (496)

    /// Spawns `PP_GUARD` (61) sphere cage and plays maximize-power sound for `EF_GUARD2` (496).
    func blackMaximize(texturePath: String, context: EffectTickContext) {
        guard stateCnt == 0 else {
            return
        }

        context.world.playSound(
            named: "effect\\black_maximize_power_sword_bic.wav",
            atWorldPosition: EffectSpace.toWorldPosition(position),
            delay: 0
        )

        let secondaryTexture = "effect\\a01.bmp"
        _ = context.assets?.texture(atPath: texturePath)
        _ = context.assets?.texture(atPath: secondaryTexture)

        let primitive = launchPrimitive(.pp_guard)
        primitive.state.renderFlag = EffectPrimitiveState.RenderFlag.alpha | EffectPrimitiveState.RenderFlag.customBlend
        primitive.state.duration = duration
        primitive.state.totalTexture = 2
        primitive.state.texturePaths = [texturePath, secondaryTexture]
        primitive.state.size = 11.0
        for i in 1..<4 {
            primitive.state.slots[i].life = 0
        }
        primitive.state.slots[0].life = 1
        primitive.state.slots[0].process = 0
        primitive.state.slots[0].maxHeight = 10.0
        primitive.state.slots[0].alphaB = 0
        primitive.state.slots[0].distance = 1.0
        primitive.state.slots[0].height[0] = 0
        primitive.state.slots[0].flag1[0] = 1
    }
}
