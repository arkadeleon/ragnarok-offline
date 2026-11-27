//
//  RagEffect+Process1000Plus.swift
//  RagnarokEffects
//
//  Created by Leon Li on 2026/11/26.
//

import Foundation
import RagnarokCore
import simd

extension RagEffect {
    nonisolated static let proceduralEffectIDs1000Plus: [EffectID] = [
        .ef_bluelightbody,
        .ef_kagemusya,
        .ef_icemine,
        .ef_icemine_1,
        .ef_darkpiercing,
        .ef_maxpain,
        .ef_yellobody,
        .ef_colorpaper2,
        .ef_rk_dragonbreath_water,
        .ef_cloud10,
        .ef_lg_kings_grace,
        .ef_blooddrain2,
        .ef_npc_wideweb,
        .ef_npc_burnt,
        .ef_whitebody,
        .ef_jumpbody1,
        .ef_escape,
        .ef_xeno_slasher,
        .ef_power_of_gaia,
        .ef_su_cn_meteor,
        .ef_su_lunatic_carrot_beat,
        .ef_su_soul_attack,
        .ef_su_spirit_of_life,
        .ef_su_stoop,
        .ef_rl_b_trap,
        .ef_rl_hammer_of_god,
        .ef_rl_r_trip,
        .ef_immune_property,
        .ef_move_coordinate,
        .ef_warpzone3,
        .ef_autoshadowspell_active,
        .ef_sma_black,
        .ef_sma_black2,
        .ef_stin_black,
        .ef_peong_black,
        .ef_energydrain_black,
        .ef_blink_body,
        .ef_linelink5,
        .ef_solar_explosion,
        .ef_soul_reaper_collect,
        .ef_new_severerainstorm_hit,
        .ef_new_cart_tornado,
        .ef_unk_1398,
        .ef_new_heavens_drive,
        .ef_new_tripleattack,
        .ef_new_moon_slash,
        .ef_new_grandcross,
        .ef_new_jackfrost_art,
        .ef_new_frostmisty,
        .ef_whiteimprison_state,
        .ef_pok_thunder,
        .ef_new_magnum_break,
        .ef_new_heal_blue,
        .ef_new_heal_white,
        .ef_new_heal_yellow,
        .ef_new_crossimpact_hit,
        .ef_new_reverberation,
        .ef_new_gateofhell,
        .ef_new_metallicsound_line,
        .ef_new_reverberation_note,
        .ef_guard5,
        .ef_magic_circle_1,
        .ef_bio5_plant_green,
        .ef_bio5_plant_blue,
        .ef_bio5_plant_yellow,
        .ef_bio5_plant_white,
        .ef_bio5_plant_red,
        .ef_pok_magic,
        .ef_new_epiclesis_aura,
        .ef_new_epiclesis_cast,
        .ef_new_sanctuary,
        .ef_new_safetywall,
        .ef_new_sonicwave,
        .ef_new_earthdrive_cast,
        .ef_new_pneuma,
        .ef_new_sw_cast,
        .ef_abr_mother,
        .ef_abr_infinity_ring,
        .ef_new_d_cannon_entity,
        .ef_flame_trap_ring,
        .ef_new_pramen_ring,
        .ef_new_battle_w_entity,
        .ef_pneumaticus_procella_ring,
        .ef_sincere_faith_ring,
        .ef_powerful_faith_ring,
        .ef_firm_faith_ring,
        .ef_research_report_ring,
        .ef_wooden_warrior_ring,
        .ef_wooden_fairy_ring,
        .ef_unk_2277,
        .ef_unk_2278,
        .ef_status_crate_up,
        .ef_status_crate_down,
        .ef_status_hplus_up,
        .ef_status_hplus_down,
        .ef_status_mres_up,
        .ef_status_mres_down,
        .ef_status_patk_up,
        .ef_status_patk_down,
        .ef_status_res_up,
        .ef_status_res_down,
        .ef_status_smatk_up,
        .ef_status_smatk_down,
        .ef_status_patk_smatk_up,
        .ef_the_one_fighter_rises,
        .ef_pok_94,
        .ef_pok_95,
        .ef_pok_96,
        .ef_pok_97,
        .ef_pok_98,
        .ef_pok_99,
        .ef_pok_100,
        .ef_pok_101,
        .ef_pok_102,
        .ef_pok_103,
        .ef_pok_104,
        .ef_pok_105,
        .ef_beginspell_ring_yellow,
        .ef_beginspell_swirl,
        .ef_beginspell_ring_white,
        .ef_volcano_black,
        .ef_alpha_down_anim,
        .ef_glow_black,
        .ef_abc_chasing_line,
        .ef_abc_crossimpact_line,
        .ef_wh_wild_walk,
        .ef_force_anim_27,
        .ef_heal_blue_2,
        .ef_rg_coin_blue,
        .ef_rg_coin_blue_2,
        .ef_cruel_bite_line,
        .ef_quill_spear_line,
    ]

    func process1000Plus(context: EffectTickContext) -> Bool {
        switch effectID {
        case .ef_bluelightbody:
            if let targetID = targetObjectID ?? ownerObjectID,
               let alpha = Self.tintedOverlayAlpha(phase: 20) {
                context.world.applyTargetModifier(
                    .flash(color: SIMD4<Float>(5.0 / 255.0, 5.0 / 255.0, 1.0, alpha), durationTicks: 2),
                    to: targetID
                )
            }
        case .ef_kagemusya:
            if let targetID = targetObjectID ?? ownerObjectID {
                context.world.applyTargetModifier(
                    .afterimage(
                        style: .hallucination,
                        tint: SIMD4<Float>(192.0 / 255.0, 192.0 / 255.0, 192.0 / 255.0, 1.0),
                        durationTicks: 30
                    ),
                    to: targetID
                )
            }
        case .ef_icemine:
            texturedClassChange(kind: 84, context: context)
        case .ef_icemine_1:
            texturedClassChange(kind: 85, context: context)
        case .ef_darkpiercing:
            cloudSpread(context: context)
        case .ef_maxpain:
            kyrieGuard(texturePath: "effect\\guardK.tga", kind: 3, context: context)
        case .ef_yellobody, .ef_unk_2278:
            if let targetID = targetObjectID ?? ownerObjectID {
                context.world.applyTargetModifier(
                    .tint(color: SIMD4<Float>(251.0 / 255.0, 200.0 / 255.0, 4.0 / 255.0, 1.0), durationTicks: 2),
                    to: targetID
                )
            }
        case .ef_colorpaper2:
            for _ in 0..<50 {
                weddingBurst(texturePath: "effect\\white02.bmp", silent: 1, context: context)
            }
        case .ef_rk_dragonbreath_water:
            texturedClassChange(kind: 86, context: context)
        case .ef_cloud10:
            for _ in 0..<30 {
                skyCloud(kind: 5, context: context)
            }
        case .ef_lg_kings_grace:
            if stateCnt == 0 {
                let texturePath = "effect\\lg_kings_grace.tga"
                _ = context.assets?.texture(atPath: texturePath)
                for angle in stride(from: 0, to: 1440, by: 360) {
                    let primitive = launchPrimitive(171)
                    primitive.state.renderFlag = EffectPrimitiveState.RenderFlag.alpha | EffectPrimitiveState.RenderFlag.customBlend
                    primitive.state.duration = duration
                    primitive.state.totalTexture = 1
                    primitive.state.texturePaths = [texturePath]
                    primitive.state.slots[0].life = 1
                    for h in 0...10 {
                        primitive.state.slots[0].height[h] = 0
                    }
                    primitive.state.slots[0].height[6] = Float(angle / 4)
                    primitive.state.slots[0].height[7] = -8.0
                    primitive.state.slots[0].distance = 8.0
                    primitive.state.slots[0].flag1[0] = 1
                    primitive.state.slots[0].alphaB = 0
                    primitive.state.slots[0].process = 0
                }
            }
        case .ef_blooddrain2:
            redParticleSpray(count: 1, context: context)
        case .ef_npc_wideweb:
            texturedClassChange(kind: 87, context: context)
        case .ef_npc_burnt:
            texturedClassChange(kind: 88, context: context)
        case .ef_whitebody:
            if let targetID = targetObjectID ?? ownerObjectID {
                context.world.applyTargetModifier(
                    .flash(color: SIMD4<Float>(1.0, 1.0, 1.0, 1.0), durationTicks: 2),
                    to: targetID
                )
            }
        case .ef_jumpbody1:
            if stateCnt == 0 {
                context.world.playSound(
                    named: K2L("effect\\T_회피2.wav"),
                    atWorldPosition: EffectSpace.toWorldPosition(position),
                    delay: 0
                )
            }
            if stateCnt > 10, let targetID = targetObjectID ?? ownerObjectID {
                let level = stateCnt - 10
                let rise = Float(level * 20)
                let alpha = Float(max(0, 255 - level * 20)) / 255.0
                context.world.applyTargetModifier(.spriteOffset(SIMD2<Float>(0, rise), durationTicks: 2), to: targetID)
                context.world.applyTargetModifier(.alpha(alpha, durationTicks: 2), to: targetID)
            }
        case .ef_escape:
            let diff = position - deltaPos
            let length = simd_length(diff)
            if let targetID = targetObjectID ?? ownerObjectID {
                let tint = SIMD4<Float>(200.0 / 255.0, 200.0 / 255.0, 0.0, 1.0)
                context.world.applyTargetModifier(.tint(color: tint, durationTicks: 2), to: targetID)
                if stateCnt % 5 == 0 {
                    context.world.applyTargetModifier(
                        .afterimage(style: .hallucination, tint: tint, durationTicks: 20),
                        to: targetID
                    )
                }
            }
            if stateCnt % 5 == 0, length > 0 {
                deltaPos += diff * 0.5
            }
        case .ef_xeno_slasher:
            if stateCnt == 20 {
                context.world.playSound(
                    named: K2L("effect\\기공포.wav"),
                    atWorldPosition: EffectSpace.toWorldPosition(position),
                    delay: 0
                )
            }
            if stateCnt >= 0 && stateCnt <= 10, let targetID = targetObjectID ?? ownerObjectID {
                context.world.applyTargetModifier(
                    .tint(color: SIMD4<Float>(0.0, 1.0, 0.0, 1.0), durationTicks: 2),
                    to: targetID
                )
            }
            sonicWave(sonic: 2, context: context)
        case .ef_power_of_gaia:
            texturedPulseKind(texturePath: "effect\\ring_yellow.tga", kind: 4, context: context)
        case .ef_su_cn_meteor:
            for _ in 0..<40 {
                skyCloud(kind: 11, context: context)
                skyCloud(kind: 12, context: context)
                skyCloud(kind: 13, context: context)
                skyCloud(kind: 14, context: context)
            }
        case .ef_su_lunatic_carrot_beat:
            texturedClassChange(kind: 90, context: context)
        case .ef_su_soul_attack:
            if stateCnt >= effectID.defaultLifetimeTicks - 1 {
                stateCnt = 0
            }
            empShockBurst(texturePath: "effect\\emp shock.tga", flag: 0, context: context)
        case .ef_su_spirit_of_life:
            if stateCnt >= effectID.defaultLifetimeTicks - 1 {
                stateCnt = 0
            }
            if let targetID = targetObjectID ?? ownerObjectID {
                context.world.applyTargetModifier(
                    .tint(color: SIMD4<Float>(1.0, 1.0, 1.0, 1.0), durationTicks: 2),
                    to: targetID
                )
            }
        case .ef_su_stoop:
            if stateCnt == 0 {
                context.world.playSound(
                    named: K2L("effect\\mon_금강불괴.wav"),
                    atWorldPosition: EffectSpace.toWorldPosition(position),
                    delay: 0
                )
            }
        case .ef_rl_b_trap:
            elementalOrbit(kind: 4, context: context)
        case .ef_rl_hammer_of_god:
            for _ in 0..<65 {
                skyCloud(kind: 15, context: context)
            }
        case .ef_rl_r_trip:
            if let targetID = targetObjectID ?? ownerObjectID {
                context.world.applyTargetModifier(
                    .tint(color: SIMD4<Float>(220.0 / 255.0, 150.0 / 255.0, 0.0, 1.0), durationTicks: 2),
                    to: targetID
                )
            }
        case .ef_immune_property:
            kyrieGuard(texturePath: "effect\\guardK.tga", kind: 4, context: context)
        case .ef_move_coordinate:
            for _ in 0..<30 {
                whiteLightTrail(texturePath: "effect\\whitelight.tga", kind: 1, context: context)
            }
            for index in 0..<4 {
                let angle = Int16(index * 90)
                texturedScatterArc(texturePath: "effect\\peong1.tga", angle: angle, phase: 1, context: context)
                texturedScatterArc(texturePath: "effect\\peong2.tga", angle: angle, phase: 1, context: context)
                texturedScatterArc(texturePath: "effect\\peong3.tga", angle: angle, phase: 1, context: context)
                texturedScatterArc(texturePath: "effect\\peong2.tga", angle: angle, phase: 1, context: context)
            }
        case .ef_warpzone3:
            alphaDownRipples(texturePath: "effect\\ring_red.tga", kind: 1, context: context)
        case .ef_autoshadowspell_active:
            if stateCnt == 0 {
                context.world.playSound(
                    named: "effect\\EF_BeginSpell.wav",
                    atWorldPosition: EffectSpace.toWorldPosition(position),
                    delay: 0
                )
            }
            if let targetID = targetObjectID ?? ownerObjectID {
                let cumulativeYaw: Float = if stateCnt <= 15 {
                    Float((stateCnt + 1) * 12)
                } else if stateCnt <= 30 {
                    Float(16 * 12 + (stateCnt - 15) * 18)
                } else if stateCnt <= 40 {
                    Float(16 * 12 + 15 * 18 + (stateCnt - 30) * 24)
                } else {
                    Float(16 * 12 + 15 * 18 + 10 * 24 + (stateCnt - 40) * 48)
                }
                let spinYaw = cumulativeYaw.truncatingRemainder(dividingBy: 360.0)
                context.world.applyTargetModifier(.facingYaw(degrees: spinYaw, durationTicks: 2), to: targetID)
            }
        case .ef_sma_black:
            sma(flag: 99, context: context)
        case .ef_sma_black2:
            blueRingStack(context: context)
        case .ef_stin_black:
            if stateCnt == 5 || stateCnt == 20 || stateCnt == 35 || stateCnt == 50 || stateCnt == 65 {
                context.world.playSound(
                    named: K2L("effect\\T_날라차기.wav"),
                    atWorldPosition: EffectSpace.toWorldPosition(position),
                    delay: 0
                )
            }
            texturedSlashLevel(texturePath: K2L("effect\\270바람.tga"), kind: 4, context: context)
            texturedSlashLevel(texturePath: K2L("effect\\270바람.tga"), kind: 5, context: context)
        case .ef_peong_black:
            sonicSlashFan(kind: 1, context: context)
            if stateCnt >= 50 && stateCnt <= 80, let targetID = targetObjectID ?? ownerObjectID {
                let value = Float((125 - stateCnt) * 2) / 255.0
                context.world.applyTargetModifier(
                    .tint(color: SIMD4<Float>(value, value, 250.0 / 255.0, 1.0), durationTicks: 2),
                    to: targetID
                )
            }
        case .ef_energydrain_black:
            sonicSlashFan(kind: 2, context: context)
            if stateCnt >= 50 && stateCnt <= 80, let targetID = targetObjectID ?? ownerObjectID {
                let value = Float((125 - stateCnt) * 2) / 255.0
                context.world.applyTargetModifier(
                    .tint(color: SIMD4<Float>(value, value, 250.0 / 255.0, 1.0), durationTicks: 2),
                    to: targetID
                )
            }
        case .ef_blink_body:
            if stateCnt < 61, let targetID = targetObjectID ?? ownerObjectID {
                let color = stateCnt % 2 == 0
                    ? SIMD4<Float>(155.0 / 255.0, 155.0 / 255.0, 1.0, 1.0)
                    : SIMD4<Float>(50.0 / 255.0, 50.0 / 255.0, 50.0 / 255.0, 1.0)
                context.world.applyTargetModifier(.tint(color: color, durationTicks: 2), to: targetID)
            }
        case .ef_linelink5:
            trackCloud(kind: 0, context: context)
        case .ef_solar_explosion:
            if stateCnt == 5 {
                context.world.playSound(
                    named: K2L("effect\\mon_침투경.wav"),
                    atWorldPosition: EffectSpace.toWorldPosition(position),
                    delay: 0
                )
            }
            if stateCnt >= 14 && stateCnt < duration, let targetID = targetObjectID ?? ownerObjectID {
                let (degrees, offset) = Self.swingRollAndOffset(phase: stateCnt - 14)
                context.world.applyTargetModifier(.spriteRoll(degrees: degrees, durationTicks: 2), to: targetID)
                context.world.applyTargetModifier(.spriteOffset(offset, durationTicks: 2), to: targetID)
            }
        case .ef_soul_reaper_collect:
            digitalSpace(context: context)
        case .ef_new_severerainstorm_hit:
            if stateCnt % 30 == 0 {
                let childID: EffectID = context.usesMinimalEffects
                    ? .ef_mineffect_severerainstorm_cast
                    : .ef_new_severerainstorm_cast
                context.spawnChildEffect(
                    EffectSpawnRequest(
                        effectID: childID,
                        worldPosition: EffectSpace.toWorldPosition(position)
                    )
                )
            }
            severeRainstormCylinder(alpha: 3, distance: 3.0, context: context)
            severeRainstormCylinder(alpha: 3, distance: 3.0, context: context)
            severeRainstormCylinder(alpha: 3, distance: 8.0, context: context)
            severeRainstormCylinder(alpha: 3, distance: 8.0, context: context)
        case .ef_new_cart_tornado:
            if stateCnt == 5 {
                context.world.playSound(
                    named: K2L("effect\\T_회오리차기.wav"),
                    atWorldPosition: EffectSpace.toWorldPosition(position),
                    delay: 0
                )
            }
            if stateCnt <= 47, let targetID = targetObjectID ?? ownerObjectID {
                let spinYaw = Float(((stateCnt + 1) * 30) % 360)
                context.world.applyTargetModifier(.facingYaw(degrees: spinYaw, durationTicks: 2), to: targetID)
            }
        case .ef_unk_1398:
            if let targetID = targetObjectID ?? ownerObjectID {
                let phase = stateCnt <= 200 ? Int(Float(stateCnt) * 0.125) : 25
                if let alpha = Self.tintedOverlayAlpha(phase: phase) {
                    context.world.applyTargetModifier(
                        .flash(color: SIMD4<Float>(1.0, 5.0 / 255.0, 5.0 / 255.0, alpha), durationTicks: 2),
                        to: targetID
                    )
                }
            }
        case .ef_new_heavens_drive:
            stoneSpike(context: context)
        case .ef_new_tripleattack:
            for _ in 0..<4 {
                lineStreak(kind: 0, context: context)
                lineStreak(kind: 1, context: context)
            }
        case .ef_new_moon_slash:
            if stateCnt == 0 {
                context.world.playSound(
                    named: "effect\\EF_BeginSpell.wav",
                    atWorldPosition: EffectSpace.toWorldPosition(position),
                    delay: 0
                )
                texturedQuadRingSized(
                    baseAlpha: 45,
                    texturePath: "effect\\new_comet\\new_comet_cast_ring\\ring_rainbow.tga",
                    kind: 20,
                    context: context
                )
            }
        case .ef_new_grandcross:
            if let targetID = targetObjectID ?? ownerObjectID {
                let phase = stateCnt <= 150 ? stateCnt / 8 : 15
                if let alpha = Self.tintedOverlayAlpha(phase: phase) {
                    context.world.applyTargetModifier(
                        .flash(color: SIMD4<Float>(5.0 / 255.0, 5.0 / 255.0, 1.0, alpha), durationTicks: 2),
                        to: targetID
                    )
                }
            }
        case .ef_new_jackfrost_art:
            if stateCnt % 40 == 0 {
                let childID: EffectID = context.usesMinimalEffects
                    ? .ef_mineffect_jackfrost_rune
                    : .ef_new_jackfrost_rune
                for index in 1..<4 {
                    let distance = Float(max(Int.random(in: 0..<17), 5))
                    let radians = Float(index) * 5.0 * 20.0 / 180.0 * .pi
                    let rotated = EffectSpace.transformVector(
                        SIMD3<Float>(distance, 0, 0),
                        by: EffectSpace.rotationY(radians: radians)
                    )
                    context.spawnChildEffect(
                        EffectSpawnRequest(
                            effectID: childID,
                            worldPosition: EffectSpace.toWorldPosition(position + rotated)
                        )
                    )
                }
            }
            if stateCnt == 0 {
                let texturePath = "effect\\new_jackfrost\\new_jackfrost_magicrune\\jack_magic_rune.tga"
                _ = context.assets?.texture(atPath: texturePath)
                let primitive = launchPrimitive(.pp_3dtexture)
                primitive.state.duration = duration
                primitive.state.pattern |= 0x800
                primitive.state.longitude = 0
                primitive.state.longSpeed = 2.5
                primitive.state.roll = 90.0
                primitive.state.changeWidthAccel = 0
                primitive.state.changeHeightAccel = 0
                primitive.state.widthSize = 40.0
                primitive.state.heightSize = 40.0
                primitive.state.widthSpeed = -1.0
                primitive.state.heightSpeed = -1.0
                primitive.state.changePoint = 20
                primitive.state.changeWidthSpeed = 0
                primitive.state.changeHeightSpeed = 0
                primitive.state.red = 254
                primitive.state.green = 254
                primitive.state.blue = 254
                primitive.state.totalTexture = 1
                primitive.state.texturePaths = [texturePath]
            }
        case .ef_new_frostmisty:
            if stateCnt == 0 {
                context.world.playSound(
                    named: "effect\\EF_BeginSpell.wav",
                    atWorldPosition: EffectSpace.toWorldPosition(position),
                    delay: 0
                )
                quadRingStackSized(texturePath: "effect\\new_jackfrost\\ring_ice.tga", kind: 2, context: context)
            }
        case .ef_whiteimprison_state:
            texturedAura(texturePath: "effect\\Buff_Prison.bmp", kind: 31, context: context)
        case .ef_pok_thunder:
            texturedClassChange(kind: 91, context: context)
        case .ef_new_magnum_break:
            if stateCnt <= 30, let targetID = targetObjectID ?? ownerObjectID {
                context.world.applyTargetModifier(
                    .tint(color: SIMD4<Float>(0.0, 0.0, 1.0, 1.0), durationTicks: 2),
                    to: targetID
                )
            }
        case .ef_new_heal_blue:
            if stateCnt == 0 {
                context.world.playSound(
                    named: "effect\\EF_BeginSpell.wav",
                    atWorldPosition: EffectSpace.toWorldPosition(position),
                    delay: 0
                )
                texturedQuadRingSized(baseAlpha: 45, texturePath: "effect\\ring_blue.tga", kind: 20, context: context)
                texturedQuadRingSized(baseAlpha: 25, texturePath: "effect\\ring_blue.tga", kind: 21, context: context)
            }
        case .ef_new_heal_white:
            if stateCnt == 0 {
                context.world.playSound(
                    named: "effect\\EF_BeginSpell.wav",
                    atWorldPosition: EffectSpace.toWorldPosition(position),
                    delay: 0
                )
                texturedQuadRingSized(baseAlpha: 45, texturePath: "effect\\ring_white.tga", kind: 22, context: context)
                texturedQuadRingSized(baseAlpha: 25, texturePath: "effect\\ring_white.tga", kind: 22, context: context)
            }
        case .ef_new_heal_yellow:
            if stateCnt == 0 {
                context.world.playSound(
                    named: "effect\\EF_BeginSpell.wav",
                    atWorldPosition: EffectSpace.toWorldPosition(position),
                    delay: 0
                )
                texturedQuadRingSized(baseAlpha: 45, texturePath: "effect\\ring_yellow.tga", kind: 23, context: context)
                texturedQuadRingSized(baseAlpha: 25, texturePath: "effect\\ring_yellow.tga", kind: 23, context: context)
            }
        case .ef_new_crossimpact_hit:
            let prefix = context.usesMinimalEffects
                ? "effect\\mineffect\\new_crossimpact\\new_crossimpact_line\\"
                : "effect\\new_crossimpact\\new_crossimpact_line\\"
            for _ in 0..<2 {
                lineStreakTextured(kind: 10, texturePath: prefix + "line_pitch.tga", context: context)
                lineStreakTextured(kind: 11, texturePath: prefix + "line_pitch.tga", context: context)
                lineStreakTextured(kind: 10, texturePath: prefix + "line_red.tga", context: context)
                lineStreakTextured(kind: 11, texturePath: prefix + "line_red.tga", context: context)
            }
        case .ef_new_reverberation:
            let path = context.usesMinimalEffects
                ? "effect\\mineffect\\new_reverberation\\melody_a.bmp"
                : "effect\\new_reverberation\\melody_a.bmp"
            texturedDrop(texturePath: path, flag: 2, context: context)
            whiteRingRippleSized(size: 28, context: context)
        case .ef_new_gateofhell:
            let path = context.usesMinimalEffects
                ? "effect\\mineffect\\new_gateofhell\\line_hell.tga"
                : "effect\\new_gateofhell\\line_hell.tga"
            for _ in 0..<4 {
                lineStreakTextured(kind: 10, texturePath: path, context: context)
                lineStreakTextured(kind: 11, texturePath: path, context: context)
            }
        case .ef_new_metallicsound_line:
            let prefix = context.usesMinimalEffects
                ? "effect\\mineffect\\new_metalicsound\\"
                : "effect\\new_metalicsound\\"
            texturedBeam(flag: 2, texturePath: prefix + "new_metalicsound_line\\met_damege_line_1.tga", context: context)
            texturedForkBolt(texturePath: prefix + "new_metalicsound_icon\\met_particle_1.tga", flag: 2, context: context)
            texturedForkBolt(texturePath: prefix + "new_metalicsound_icon\\met_particle_2.tga", flag: 2, context: context)
            texturedForkBolt(texturePath: prefix + "new_metalicsound_icon\\met_particle_3.tga", flag: 2, context: context)
        case .ef_new_reverberation_note:
            let prefix = context.usesMinimalEffects
                ? "effect\\mineffect\\new_reverberation\\"
                : "effect\\new_reverberation\\"
            texturedSpinShards(texturePath: prefix + "rev_note_01.tga", kind: 3, context: context)
            texturedSpinShards(texturePath: prefix + "rev_note_02.tga", kind: 3, context: context)
        case .ef_guard5:
            kyrieGuard(texturePath: "effect\\guardK.tga", kind: 5, context: context)
        case .ef_magic_circle_1:
            texturedAura(texturePath: K2L("effect\\마법진1-3.bmp"), kind: 32, context: context)
        case .ef_bio5_plant_green, .ef_bio5_plant_blue, .ef_bio5_plant_yellow, .ef_bio5_plant_white, .ef_bio5_plant_red:
            if stateCnt == 0 {
                let spriteBase: String = switch effectID {
                case .ef_bio5_plant_green: "green_plant"
                case .ef_bio5_plant_blue: "blue_plant"
                case .ef_bio5_plant_yellow: "yellow_plant"
                case .ef_bio5_plant_white: "white_plant"
                default: "red_plant"
                }
                let spritePath = K2L("몬스터\\\(spriteBase).spr")
                let actionPath = K2L("몬스터\\\(spriteBase).act")
                _ = context.assets?.spriteAsset(spritePath: spritePath, actionPath: actionPath)
                let primitive = launchPrimitive(.pp_3dparticle)
                primitive.state.duration = duration
                primitive.state.repeatAnim = true
                primitive.state.animSpeed = 4
                primitive.state.spritePath = spritePath
                primitive.state.actionPath = actionPath
                primitive.previousAnimation = 0
                primitive.currentMotion = 0
                primitive.initSegment()
            }
        case .ef_pok_magic:
            texturedClassChange(kind: 63, context: context)
        case .ef_new_epiclesis_aura:
            whiteRingRippleSized(size: 29, context: context)
        case .ef_new_epiclesis_cast:
            beginSpellSwirl(alpha: 9, context: context)
        case .ef_new_sanctuary:
            if stateCnt == 0 {
                context.world.playSound(
                    named: "effect\\EF_BeginSpell.wav",
                    atWorldPosition: EffectSpace.toWorldPosition(position),
                    delay: 0
                )
                quadRingStackSized(texturePath: "effect\\ring_yellow.tga", kind: 33, context: context)
            }
        case .ef_new_safetywall:
            if stateCnt == 0 {
                context.world.playSound(
                    named: "effect\\EF_BeginSpell.wav",
                    atWorldPosition: EffectSpace.toWorldPosition(position),
                    delay: 0
                )
                texturedQuadRingSized(baseAlpha: 45, texturePath: "effect\\ring_white.tga", kind: 31, context: context)
                texturedQuadRingSized(baseAlpha: 25, texturePath: "effect\\ring_white.tga", kind: 31, context: context)
            }
        case .ef_new_sonicwave:
            texturedFanSweep(texturePath: "effect\\new_sonicwave\\new_sonicwave\\son_wave_01.tga", wide: 1, context: context)
            texturedFanSweep(texturePath: "effect\\new_sonicwave\\new_sonicwave\\son_wave_00.tga", wide: 0, context: context)
        case .ef_new_earthdrive_cast:
            if stateCnt == 0 {
                context.world.playSound(
                    named: "effect\\EF_BeginSpell.wav",
                    atWorldPosition: EffectSpace.toWorldPosition(position),
                    delay: 0
                )
                let path = context.usesMinimalEffects
                    ? "effect\\mineffect\\new_earthdrive\\ring_brown.tga"
                    : "effect\\new_earthdrive\\ring_brown.tga"
                quadRingStackSized(texturePath: path, kind: 33, context: context)
            }
        case .ef_new_pneuma:
            if stateCnt == 0 {
                context.world.playSound(
                    named: "effect\\EF_BeginSpell.wav",
                    atWorldPosition: EffectSpace.toWorldPosition(position),
                    delay: 0
                )
                texturedQuadRingSized(baseAlpha: 45, texturePath: "effect\\ring_white.tga", kind: 42, context: context)
                texturedQuadRingSized(baseAlpha: 25, texturePath: "effect\\ring_white.tga", kind: 42, context: context)
            }
        case .ef_new_sw_cast:
            if stateCnt == 0 {
                context.world.playSound(
                    named: "effect\\EF_BeginSpell.wav",
                    atWorldPosition: EffectSpace.toWorldPosition(position),
                    delay: 0
                )
                texturedQuadRingSized(baseAlpha: 45, texturePath: "effect\\ring_white.tga", kind: 43, context: context)
                texturedQuadRingSized(baseAlpha: 25, texturePath: "effect\\ring_white.tga", kind: 43, context: context)
            }
        case .ef_abr_mother:
            if stateCnt == 0 {
                context.world.playSound(
                    named: "effect\\EF_BeginSpell.wav",
                    atWorldPosition: EffectSpace.toWorldPosition(position),
                    delay: 0
                )
                texturedQuadRingSized(baseAlpha: 45, texturePath: "effect\\new_abr_mother\\abr_mother.tga", kind: 0, context: context)
                texturedQuadRingSized(baseAlpha: 25, texturePath: "effect\\new_abr_mother\\abr_mother.tga", kind: 0, context: context)
            }
        case .ef_abr_infinity_ring:
            if stateCnt == 0 {
                context.world.playSound(
                    named: "effect\\EF_BeginSpell.wav",
                    atWorldPosition: EffectSpace.toWorldPosition(position),
                    delay: 0
                )
                texturedQuadRingSized(baseAlpha: 45, texturePath: "effect\\new_abr_infinity\\ring_infinty.tga", kind: 0, context: context)
                texturedQuadRingSized(baseAlpha: 25, texturePath: "effect\\new_abr_infinity\\ring_infinty.tga", kind: 0, context: context)
            }
        case .ef_new_d_cannon_entity:
            if stateCnt == 0 {
                context.world.playSound(
                    named: "effect\\EF_BeginSpell.wav",
                    atWorldPosition: EffectSpace.toWorldPosition(position),
                    delay: 0
                )
                texturedQuadRingSized(baseAlpha: 45, texturePath: "effect\\new_d_cannon\\ABR_DUAL_CANNON.tga", kind: 0, context: context)
                texturedQuadRingSized(baseAlpha: 25, texturePath: "effect\\new_d_cannon\\ABR_DUAL_CANNON.tga", kind: 0, context: context)
            }
        case .ef_flame_trap_ring:
            if stateCnt == 0 {
                context.world.playSound(
                    named: "effect\\EF_BeginSpell.wav",
                    atWorldPosition: EffectSpace.toWorldPosition(position),
                    delay: 0
                )
                texturedQuadRingSized(baseAlpha: 45, texturePath: "effect\\ring_red.tga", kind: 44, context: context)
                texturedQuadRingSized(baseAlpha: 25, texturePath: "effect\\ring_red.tga", kind: 44, context: context)
            }
        case .ef_new_pramen_ring:
            if stateCnt == 0 {
                context.world.playSound(
                    named: "effect\\EF_BeginSpell.wav",
                    atWorldPosition: EffectSpace.toWorldPosition(position),
                    delay: 0
                )
                texturedQuadRingSized(baseAlpha: 90, texturePath: "effect\\new_pramen\\ring_blue.tga", kind: 5, context: context)
            }
        case .ef_new_battle_w_entity:
            if stateCnt == 0 {
                context.world.playSound(
                    named: "effect\\EF_BeginSpell.wav",
                    atWorldPosition: EffectSpace.toWorldPosition(position),
                    delay: 0
                )
                texturedQuadRingSized(baseAlpha: 45, texturePath: "effect\\new_battle_w\\ABR_BATTLE_WARIOR.tga", kind: 0, context: context)
                texturedQuadRingSized(baseAlpha: 25, texturePath: "effect\\new_battle_w\\ABR_BATTLE_WARIOR.tga", kind: 0, context: context)
            }
        case .ef_pneumaticus_procella_ring:
            if stateCnt == 0 {
                context.world.playSound(
                    named: "effect\\EF_BeginSpell.wav",
                    atWorldPosition: EffectSpace.toWorldPosition(position),
                    delay: 0
                )
                texturedQuadRingSized(
                    baseAlpha: 45,
                    texturePath: "effect\\pneumaticusprocella\\pneumaticusprocella_cast\\ring_yellow.tga",
                    kind: 0,
                    context: context
                )
                texturedQuadRingSized(
                    baseAlpha: 25,
                    texturePath: "effect\\pneumaticusprocella\\pneumaticusprocella_cast\\ring_yellow.tga",
                    kind: 0,
                    context: context
                )
            }
        case .ef_sincere_faith_ring:
            if stateCnt == 0 {
                context.world.playSound(
                    named: "effect\\EF_BeginSpell.wav",
                    atWorldPosition: EffectSpace.toWorldPosition(position),
                    delay: 0
                )
                texturedQuadRingSized(baseAlpha: 45, texturePath: "effect\\ring_white.tga", kind: 45, context: context)
                texturedQuadRingSized(baseAlpha: 25, texturePath: "effect\\ring_white.tga", kind: 45, context: context)
            }
        case .ef_powerful_faith_ring:
            if stateCnt == 0 {
                context.world.playSound(
                    named: "effect\\EF_BeginSpell.wav",
                    atWorldPosition: EffectSpace.toWorldPosition(position),
                    delay: 0
                )
                texturedQuadRingSized(baseAlpha: 45, texturePath: "effect\\ring_white.tga", kind: 46, context: context)
                texturedQuadRingSized(baseAlpha: 25, texturePath: "effect\\ring_white.tga", kind: 46, context: context)
            }
        case .ef_firm_faith_ring:
            if stateCnt == 0 {
                context.world.playSound(
                    named: "effect\\EF_BeginSpell.wav",
                    atWorldPosition: EffectSpace.toWorldPosition(position),
                    delay: 0
                )
                texturedQuadRingSized(baseAlpha: 45, texturePath: "effect\\ring_white.tga", kind: 47, context: context)
                texturedQuadRingSized(baseAlpha: 25, texturePath: "effect\\ring_white.tga", kind: 47, context: context)
            }
        case .ef_research_report_ring:
            if stateCnt == 0 {
                context.world.playSound(
                    named: "effect\\EF_BeginSpell.wav",
                    atWorldPosition: EffectSpace.toWorldPosition(position),
                    delay: 0
                )
                texturedQuadRingSized(baseAlpha: 45, texturePath: "effect\\ring_white.tga", kind: 48, context: context)
                texturedQuadRingSized(baseAlpha: 25, texturePath: "effect\\ring_white.tga", kind: 48, context: context)
            }
        case .ef_wooden_warrior_ring:
            if stateCnt == 0 {
                context.world.playSound(
                    named: "effect\\EF_BeginSpell.wav",
                    atWorldPosition: EffectSpace.toWorldPosition(position),
                    delay: 0
                )
                texturedQuadRingSized(baseAlpha: 45, texturePath: "effect\\ring_white.tga", kind: 49, context: context)
                texturedQuadRingSized(baseAlpha: 25, texturePath: "effect\\ring_white.tga", kind: 49, context: context)
            }
        case .ef_wooden_fairy_ring:
            if stateCnt == 0 {
                context.world.playSound(
                    named: "effect\\EF_BeginSpell.wav",
                    atWorldPosition: EffectSpace.toWorldPosition(position),
                    delay: 0
                )
                texturedQuadRingSized(baseAlpha: 45, texturePath: "effect\\ring_white.tga", kind: 50, context: context)
                texturedQuadRingSized(baseAlpha: 25, texturePath: "effect\\ring_white.tga", kind: 50, context: context)
            }
        case .ef_unk_2277:
            if let targetID = targetObjectID ?? ownerObjectID {
                let gray: Float = 105.0 / 255.0
                context.world.applyTargetModifier(
                    .tint(color: SIMD4<Float>(gray, gray, gray, 1.0), durationTicks: 2),
                    to: targetID
                )
            }
        case .ef_status_crate_up:
            return agilityChange(increase: true, texturePath: "effect\\status_effect\\C_rate_Up.bmp", context: context)
        case .ef_status_crate_down:
            return agilityChange(increase: false, texturePath: "effect\\status_effect\\C_rate_Down.bmp", context: context)
        case .ef_status_hplus_up:
            return agilityChange(increase: true, texturePath: "effect\\status_effect\\H_plus_Up.bmp", context: context)
        case .ef_status_hplus_down:
            return agilityChange(increase: false, texturePath: "effect\\status_effect\\H_plus_Down.bmp", context: context)
        case .ef_status_mres_up:
            return agilityChange(increase: true, texturePath: "effect\\status_effect\\Mres_Up.bmp", context: context)
        case .ef_status_mres_down:
            return agilityChange(increase: false, texturePath: "effect\\status_effect\\Mres_Down.bmp", context: context)
        case .ef_status_patk_up:
            return agilityChange(increase: true, texturePath: "effect\\status_effect\\P_atk_Up.bmp", context: context)
        case .ef_status_patk_down:
            return agilityChange(increase: false, texturePath: "effect\\status_effect\\P_atk_Down.bmp", context: context)
        case .ef_status_res_up:
            return agilityChange(increase: true, texturePath: "effect\\status_effect\\Res_Up.bmp", context: context)
        case .ef_status_res_down:
            return agilityChange(increase: false, texturePath: "effect\\status_effect\\Res_Down.bmp", context: context)
        case .ef_status_smatk_up:
            return agilityChange(increase: true, texturePath: "effect\\status_effect\\S_matk_Up.bmp", context: context)
        case .ef_status_smatk_down:
            return agilityChange(increase: false, texturePath: "effect\\status_effect\\S_matk_Down.bmp", context: context)
        case .ef_status_patk_smatk_up:
            return agilityChange(increase: true, texturePath: "effect\\status_effect\\P_atk_S_matk_Up.bmp", context: context)
        case .ef_the_one_fighter_rises:
            if stateCnt == 0 {
                texturedQuadSpiral(
                    texturePath: "effect\\the_one_fighter_rises\\the_one_fighter_rises\\the_ring_00.tga",
                    context: context
                )
            }
        case .ef_pok_94:
            texturedClassChange(kind: 94, context: context)
        case .ef_pok_95:
            texturedClassChange(kind: 95, context: context)
        case .ef_pok_96:
            texturedClassChange(kind: 96, context: context)
        case .ef_pok_97:
            texturedClassChange(kind: 97, context: context)
        case .ef_pok_98:
            texturedClassChange(kind: 98, context: context)
        case .ef_pok_99:
            texturedClassChange(kind: 99, context: context)
        case .ef_pok_100:
            texturedClassChange(kind: 100, context: context)
        case .ef_pok_101:
            texturedClassChange(kind: 101, context: context)
        case .ef_pok_102:
            texturedClassChange(kind: 102, context: context)
        case .ef_pok_103:
            texturedClassChange(kind: 103, context: context)
        case .ef_pok_104:
            texturedClassChange(kind: 104, context: context)
        case .ef_pok_105:
            texturedClassChange(kind: 105, context: context)
        case .ef_beginspell_ring_yellow:
            if stateCnt == 0 {
                context.world.playSound(
                    named: "effect\\EF_BeginSpell.wav",
                    atWorldPosition: EffectSpace.toWorldPosition(position),
                    delay: 0
                )
                texturedQuadRingSized(baseAlpha: 45, texturePath: "effect\\ring_yellow.tga", kind: 0, context: context)
                texturedQuadRingSized(baseAlpha: 25, texturePath: "effect\\ring_yellow.tga", kind: 0, context: context)
            }
        case .ef_beginspell_swirl:
            beginSpellSwirl(alpha: 11, context: context)
        case .ef_beginspell_ring_white:
            if stateCnt == 0 {
                context.world.playSound(
                    named: "effect\\EF_BeginSpell.wav",
                    atWorldPosition: EffectSpace.toWorldPosition(position),
                    delay: 0
                )
            }
            texturedQuadRing(baseAlpha: 25, texturePath: "effect\\ring_white.tga", kind: 0, context: context)
            texturedQuadRing(baseAlpha: 45, texturePath: "effect\\ring_white.tga", kind: 0, context: context)
        case .ef_volcano_black:
            texturedCrossKind(texturePath: "effect\\ring_black.tga", level: 4, context: context)
            if stateCnt <= 30, let targetID = targetObjectID ?? ownerObjectID {
                context.world.applyTargetModifier(
                    .tint(color: SIMD4<Float>(1.0, 0.0, 0.0, 1.0), durationTicks: 2),
                    to: targetID
                )
            }
        case .ef_alpha_down_anim:
            if stateCnt >= duration - 1 {
                stateCnt = 0
            }
            texturedFourRing(texturePath: "effect\\alpha_down.tga", kind: 0, context: context)
            texturedFourRing(texturePath: "effect\\alpha_down.tga", kind: 1, context: context)
        case .ef_glow_black:
            mapMagicZone(texturePath: "effect\\glow04_bk.bmp", type: 5, context: context)
            for index in stride(from: 2, to: 21, by: 2) {
                texturedOrbitDust(texturePath: "effect\\mpa3.tga", rise: Int8(index), kind: 2, context: context)
            }
        case .ef_abc_chasing_line:
            let prefix = "effect\\ABYSS_CHASER\\ABC_CHASING_BREAK\\chasing_line\\"
            let pitch = prefix + (context.usesMinimalEffects ? "min_line_pitch2.tga" : "line_pitch2.tga")
            let purple = prefix + (context.usesMinimalEffects ? "min_line_pur.tga" : "line_pur.tga")
            for _ in 0..<2 {
                lineStreakTextured(kind: 20, texturePath: pitch, context: context)
                lineStreakTextured(kind: 21, texturePath: pitch, context: context)
                lineStreakTextured(kind: 20, texturePath: purple, context: context)
                lineStreakTextured(kind: 21, texturePath: purple, context: context)
            }
        case .ef_abc_crossimpact_line:
            let prefix = context.usesMinimalEffects
                ? "effect\\mineffect\\new_crossimpact\\new_crossimpact_line\\"
                : "effect\\new_crossimpact\\new_crossimpact_line\\"
            for _ in 0..<2 {
                lineStreakTextured(kind: 30, texturePath: prefix + "line_pitch.tga", context: context)
                lineStreakTextured(kind: 31, texturePath: prefix + "line_pitch.tga", context: context)
                lineStreakTextured(kind: 30, texturePath: prefix + "line_red.tga", context: context)
                lineStreakTextured(kind: 31, texturePath: prefix + "line_red.tga", context: context)
            }
        case .ef_wh_wild_walk:
            for index in 0..<12 {
                texturedQuadSpin(
                    texturePath: "effect\\WINDHAWK\\WH_WILD_WALK\\alpha_center_green.tga",
                    phase: Int8(index),
                    kind: 3,
                    context: context
                )
            }
        case .ef_force_anim_27:
            break
        case .ef_heal_blue_2:
            healRingSparkle(texturePath: "effect\\ring_blue.tga", type: 2, context: context)
        case .ef_rg_coin_blue:
            if stateCnt == 1 || stateCnt == 11 || stateCnt == 21 || stateCnt == 31 {
                context.world.playSound(
                    named: K2L("effect\\복호격.wav"),
                    atWorldPosition: EffectSpace.toWorldPosition(position),
                    delay: 0
                )
            }
            for _ in 0..<4 {
                texturedSprayKind(texturePath: "effect\\shield.bmp", spin: 5.0, kind: 8, context: context)
                texturedSprayKind(texturePath: "effect\\sword.bmp", spin: 9.0, kind: 8, context: context)
            }
        case .ef_rg_coin_blue_2:
            if stateCnt == 1 || stateCnt == 11 || stateCnt == 21 || stateCnt == 31 {
                context.world.playSound(
                    named: K2L("effect\\복호격.wav"),
                    atWorldPosition: EffectSpace.toWorldPosition(position),
                    delay: 0
                )
            }
            for _ in 0..<4 {
                texturedSprayKind(texturePath: "effect\\shield.bmp", spin: 5.0, kind: 9, context: context)
                texturedSprayKind(texturePath: "effect\\sword.bmp", spin: 9.0, kind: 9, context: context)
            }
        case .ef_cruel_bite_line:
            let dir = context.usesMinimalEffects
                ? "effect\\DRUID\\DR_CRUEL_BITE\\min_cruel_bite_line\\"
                : "effect\\DRUID\\DR_CRUEL_BITE\\cruel_bite_line\\"
            for _ in 0..<2 {
                texturedSwirl(clockwise: true, texturePath: dir + "line_black.tga", context: context)
                texturedSwirl(clockwise: false, texturePath: dir + "line_black.tga", context: context)
                texturedSwirl(clockwise: true, texturePath: dir + "line_red.tga", context: context)
                texturedSwirl(clockwise: false, texturePath: dir + "line_red.tga", context: context)
            }
        case .ef_quill_spear_line:
            let dir = context.usesMinimalEffects
                ? "effect\\DRUID\\AT_QUILL_SPEAR\\min_quill_spear_line\\"
                : "effect\\DRUID\\AT_QUILL_SPEAR\\quill_spear_line\\"
            for _ in 0..<2 {
                texturedSwirl(clockwise: true, texturePath: dir + "line_black.tga", context: context)
                texturedSwirl(clockwise: false, texturePath: dir + "line_black.tga", context: context)
                texturedSwirl(clockwise: true, texturePath: dir + "line_color.tga", context: context)
                texturedSwirl(clockwise: false, texturePath: dir + "line_color.tga", context: context)
            }
        default:
            return false
        }
        return true
    }

    // MARK: - EF_DARKPIERCING (1030)

    /// Spawns long-range directional cloud spread (`69`) on ticks `0...1` with hit audio on ticks 10 and 20 for `EF_DARKPIERCING` (1030).
    func cloudSpread(context: EffectTickContext) {
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
                let backShift: Float = 100.0
                primitive.state.slots[i].height[1] = backShift
                let bx = Float(Int.random(in: 0..<100)) * 0.3 - 15.0 + position.x - cosVal * backShift
                let bz = Float(Int.random(in: 0..<100)) * 0.3 - 15.0 + position.z - sinVal * backShift
                let point = SIMD3<Float>(bx, position.y, bz)
                primitive.state.slots[i].vecBNow = point
                primitive.state.slots[i].vecTNow = point
                primitive.state.slots[i].maxHeight = 0.25
                primitive.state.slots[i].height[0] = Float(Int.random(in: 0..<100)) * 0.04 + 8.0
                primitive.state.slots[i].distance = Float(Int.random(in: 0..<100)) * 0.5 + 100.0
                primitive.state.slots[i].height[4] = 5.0
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

    // MARK: - EF_SMA_BLACK2 (1205)

    /// Spawns black-variant 3-layer SMA pillar (`PP_SMA2` (121)) for `EF_SMA_BLACK2` (1205).
    func blueRingStack(context: EffectTickContext) {
        guard stateCnt == 0 else {
            return
        }

        let texturePath = "effect\\ring_blue.tga"
        _ = context.assets?.texture(atPath: texturePath)

        let primitive = launchPrimitive(.pp_sma2)
        primitive.state.renderFlag = EffectPrimitiveState.RenderFlag.alpha | EffectPrimitiveState.RenderFlag.customBlend
        primitive.state.duration = duration
        primitive.state.totalTexture = 1
        primitive.state.texturePaths = [texturePath]
        primitive.state.size = 4.0
        primitive.state.deltaPos = deltaPos
        primitive.state.deltaPos2 = deltaPos2

        let isWide = deltaPos2.y == 0
        for index in 0..<3 {
            let step = Float(index)
            primitive.state.slots[index].life = 1
            primitive.state.slots[index].process = 0
            primitive.state.slots[index].fullDisplayAngle = 315
            primitive.state.slots[index].maxHeight = 13.0 - (step + step)
            primitive.state.slots[index].rotStart = Int16(index * 90)
            primitive.state.slots[index].alphaB = 0
            primitive.state.slots[index].distance = step * 0.2 + (isWide ? 3.4 : 2.4)
            primitive.state.slots[index].riseAngle = Int16((11 - index) * 5)
            primitive.state.slots[index].vecBNow.y = 0
            primitive.state.slots[index].height = Array(repeating: 0, count: 21)
            primitive.state.slots[index].flag1 = Array(repeating: 0, count: 21)
            primitive.state.slots[index].alphaT = 99
        }
        primitive.state.slots[3].life = 0
    }

    // MARK: - EF_SOUL_REAPER_COLLECT (1240)

    /// Spawns looping ground sprite (`168`) for `EF_SOUL_REAPER_COLLECT` (1240).
    func digitalSpace(context: EffectTickContext) {
        if stateCnt == 0 {
            let spritePath = K2L("이팩트\\digital_space\\digital_space.spr")
            let actionPath = K2L("이팩트\\digital_space\\digital_space.act")
            _ = context.assets?.spriteAsset(spritePath: spritePath, actionPath: actionPath)

            let primitive = launchPrimitive(168)
            primitive.state.duration = duration
            primitive.state.spritePath = spritePath
            primitive.state.actionPath = actionPath
            primitive.previousAnimation = 0
            primitive.currentMotion = 0
            primitive.state.repeatAnim = true
            primitive.state.animSpeed = 8
            primitive.state.renderFlag = EffectPrimitiveState.RenderFlag.alpha
                | EffectPrimitiveState.RenderFlag.topmost
                | EffectPrimitiveState.RenderFlag.noDepth
            primitive.state.pattern |= 0x200
            primitive.state.alpha = 255.0
            primitive.initSegment()
        }

        if stateCnt == duration - 1 {
            stateCnt = 0
            if let last = primitives.last {
                last.state.stateCnt = 0
            }
        }
    }

    // MARK: - EF_NEW_SEVERERAINSTORM_HIT (1286)

    /// Spawns slow wave-height musical rainstorm cylinder (`173`) for `EF_NEW_SEVERERAINSTORM_HIT` (1286).
    func severeRainstormCylinder(alpha: Int8, distance: Float, context: EffectTickContext) {
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

        let paths = (1...9).map {
            String(format: "effect\\new_severerainstorm\\new_severerainstorm_cylinder\\music_%02d.tga", $0)
        }
        for path in paths {
            _ = context.assets?.texture(atPath: path)
        }

        let primitive = launchPrimitive(173)
        primitive.state.renderFlag = EffectPrimitiveState.RenderFlag.alpha | EffectPrimitiveState.RenderFlag.customBlend
        primitive.state.duration = duration
        primitive.state.totalTexture = paths.count
        primitive.state.texturePaths = paths
        primitive.state.size = 0

        let configs: [(rotStart: Int16, riseAngle: Int16)] = [
            (0, 60),
            (90, 55),
            (180, 65),
            (270, 70),
        ]
        for (slot, config) in configs.enumerated() {
            primitive.state.slots[slot].life = 1
            primitive.state.slots[slot].process = 0
            primitive.state.slots[slot].fullDisplayAngle = 120
            primitive.state.slots[slot].maxHeight = 20.0
            primitive.state.slots[slot].rotStart = config.rotStart
            primitive.state.slots[slot].alphaB = 0
            primitive.state.slots[slot].distance = distance
            primitive.state.slots[slot].riseAngle = config.riseAngle
            primitive.state.slots[slot].alphaT = Int16(alpha)
            primitive.state.slots[slot].vecBNow.y = 0
            primitive.state.slots[slot].height = Array(repeating: 0, count: 21)
            primitive.state.slots[slot].flag1 = Array(repeating: 0, count: 21)
        }
    }

    // MARK: - EF_NEW_TRIPLEATTACK (1409)

    /// Spawns yellow directional line streaks (`PP_CHEMICAL3` (56)) for `EF_NEW_TRIPLEATTACK` (1409).
    func lineStreak(kind: Int16, context: EffectTickContext) {
        guard stateCnt == 0 else {
            return
        }

        let texturePath = "effect\\line3y.tga"
        _ = context.assets?.texture(atPath: texturePath)

        let primitive = launchPrimitive(.pp_chemical3)
        primitive.state.renderFlag = EffectPrimitiveState.RenderFlag.alpha | EffectPrimitiveState.RenderFlag.noDepth
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
            primitive.state.slots[index].maxHeight = Float(Int.random(in: 0..<4)) * 0.1 + 0.3
            primitive.state.slots[index].height[2] = Float(Int.random(in: 0..<31)) + 20.0
            primitive.state.slots[index].flag1[0] = Int8(Int.random(in: 0..<3))
            primitive.state.slots[index].height[3] = Float(Int.random(in: 0..<21)) * 0.1 + 1.5
            primitive.state.slots[index].riseAngle = riseAngle
            primitive.state.slots[index].alphaB = 0
        }
    }

    // MARK: - EF_NEW_REVERBERATION (1569, 1655)

    /// Spawns periodic sized white ring ripples (`63`) every 100 ticks for `EF_NEW_REVERBERATION` (1569) and `EF_NEW_EPICLESIS_AURA` (1655).
    func whiteRingRippleSized(size: Int8, context: EffectTickContext) {
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
        primitive.state.size = Float(size)

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
        primitive.state.slots[3].alphaT = size == 29 ? 5 : 1
    }

    // MARK: - EF_NEW_SONICWAVE (1678)

    /// Spawns sweeping sonic fan rings (`146`) on ticks 0, 20, 40 for `EF_NEW_SONICWAVE` (1678).
    func texturedFanSweep(texturePath: String, wide: Int8, context: EffectTickContext) {
        guard stateCnt == 0 || stateCnt == 20 || stateCnt == 40 else {
            return
        }

        _ = context.assets?.texture(atPath: texturePath)

        let primitive = launchPrimitive(146)
        primitive.state.renderFlag = EffectPrimitiveState.RenderFlag.alpha | EffectPrimitiveState.RenderFlag.customBlend
        primitive.state.duration = duration
        primitive.state.totalTexture = 1
        primitive.state.texturePaths = [texturePath]

        let baseAngle = EffectPrimitive.angle(dx: deltaPos.x - position.x, dy: deltaPos.z - position.z)
        var rotStart = baseAngle + 195
        if rotStart >= 360 {
            rotStart -= 360
        }

        for index in 0..<4 {
            primitive.state.slots[index].life = 1
            primitive.state.slots[index].process = index * -8
            primitive.state.slots[index].maxHeight = wide == 0 ? 30.0 : 20.0
            primitive.state.slots[index].fullDisplayAngle = 315
            primitive.state.slots[index].rotStart = rotStart
            primitive.state.slots[index].alphaB = 0
            primitive.state.slots[index].distance = (wide == 0 ? 6.0 : 9.0) - Float(index) * 0.1
            primitive.state.slots[index].riseAngle = Int16((14 - index) * 5)
            primitive.state.slots[index].vecBNow.y = 0
            primitive.state.slots[index].vecTNow.x = 0
            primitive.state.slots[index].vecTNow.z = 0
            primitive.state.slots[index].vecTPre.x = 0
        }
    }

    // MARK: - EF_STATUS_* (2288...2300)

    /// Spawns 2D status banner (`PP_2DTEXTURE` (0)) on tick 0 and rising/falling streaks (`PP_3DCROSSTEXTURE` (16)) every 2 ticks.
    func agilityChange(increase: Bool, texturePath: String, context: EffectTickContext) -> Bool {
        if stateCnt == 0 {
            let texture = context.assets?.texture(atPath: texturePath)
            let primitive = launchPrimitive(.pp_2dtexture)
            primitive.state.totalTexture = 1
            primitive.state.texturePaths = [texturePath]
            primitive.state.widthSize = Float(texture?.width ?? 64) * 0.625
            primitive.state.heightSize = Float(texture?.height ?? 64) * 0.625
            primitive.state.duration = duration
            primitive.state.slots[0].life = 99
            primitive.state.alpha = 0
            primitive.state.maxAlpha = 200.0
            primitive.state.alphaSpeed = primitive.state.maxAlpha / 15.0
            primitive.state.fadeOutCnt = primitive.state.duration - 15

            if increase {
                primitive.state.speed = 1.5
                primitive.state.accel = -(primitive.state.speed / Float(max(primitive.state.duration, 1))) * 1.2
                context.world.playSound(
                    named: "effect\\EF_IncAgility.wav",
                    atWorldPosition: EffectSpace.toWorldPosition(position),
                    delay: 0
                )
            } else {
                primitive.state.deltaPos2.y -= 80.0
                primitive.state.longitude = 180.0
                primitive.state.speed = 1.0
                primitive.state.accel = -(primitive.state.speed / Float(max(primitive.state.duration, 1)))
                context.world.playSound(
                    named: "effect\\EF_DecAgility.wav",
                    atWorldPosition: EffectSpace.toWorldPosition(position),
                    delay: 0
                )
            }
        }

        guard (stateCnt & 1) == 0 else {
            return true
        }

        let streakPath = "effect\\ac_center2.tga"
        _ = context.assets?.texture(atPath: streakPath)

        let streak = launchPrimitive(.pp_3dcrosstexture)
        streak.state.totalTexture = 1
        streak.state.texturePaths = [streakPath]
        streak.state.duration = 50
        streak.state.slots[0].life = 99
        streak.state.alpha = 0
        streak.state.maxAlpha = 200.0
        streak.state.alphaSpeed = streak.state.maxAlpha / 20.0
        streak.state.fadeOutCnt = streak.state.duration - 20
        streak.state.widthSize = Float(Int.random(in: 0..<60) + 30) / 10.0
        streak.state.heightSize = 0.18
        let yaw = EffectSpace.rotationY(radians: EffectSpace.radian(degrees: Int.random(in: 0..<360)))
        streak.state.deltaPos2 = EffectSpace.transformVector(SIMD3<Float>(0, 0, Float(Int.random(in: 0..<7) + 2)), by: yaw)

        if increase {
            streak.state.transform = EffectSpace.rotationX(radians: EffectSpace.radian(degrees: 90))
            streak.state.speed = Float(Int.random(in: 0..<50) + 20) / 100.0
            streak.state.red = 0
            streak.state.green = 255
            streak.state.blue = 255
        } else {
            streak.state.deltaPos2.y -= 20.0
            streak.state.transform = EffectSpace.rotationX(radians: EffectSpace.radian(degrees: -90))
            streak.state.accel = 0.015
            streak.state.red = 255
            streak.state.green = 0
            streak.state.blue = 0
        }

        return true
    }

    // MARK: - EF_THE_ONE_FIGHTER_RISES (2338)

    /// Spawns 4-ring rising spiral (`31`) for `EF_THE_ONE_FIGHTER_RISES` (2338).
    func texturedQuadSpiral(texturePath: String, context: EffectTickContext) {
        guard stateCnt == 0 else {
            return
        }

        _ = context.assets?.texture(atPath: texturePath)

        let primitive = launchPrimitive(31)
        primitive.state.renderFlag = EffectPrimitiveState.RenderFlag.alpha | EffectPrimitiveState.RenderFlag.customBlend
        primitive.state.duration = duration
        primitive.state.totalTexture = 1
        primitive.state.texturePaths = [texturePath]
        primitive.state.size = 0
        primitive.state.accel = 99.0

        for i in 0..<4 {
            primitive.state.slots[i].life = 1
            primitive.state.slots[i].process = 0
            primitive.state.slots[i].fullDisplayAngle = 360
            primitive.state.slots[i].maxHeight = 25.0
            primitive.state.slots[i].riseAngle = 80
            primitive.state.slots[i].rotStart = Int16(i * 90)
            primitive.state.slots[i].alphaB = 0
            primitive.state.slots[i].alphaT = 5
            primitive.state.slots[i].distance = Float(i) + 1.0
            primitive.state.slots[i].vecBNow.y = 0
            primitive.state.slots[i].height = Array(repeating: 0, count: 21)
            primitive.state.slots[i].flag1 = Array(repeating: 0, count: 21)
        }
    }

    // MARK: - EF_CRUEL_BITE_LINE / EF_QUILL_SPEAR_LINE (2439, 2442)

    /// Spawns directional swirl streaks (`PP_CHEMICAL3` (56)) for `EF_CRUEL_BITE_LINE` (2439) and `EF_QUILL_SPEAR_LINE` (2442).
    func texturedSwirl(clockwise: Bool, texturePath: String, context: EffectTickContext) {
        guard stateCnt == 0 else {
            return
        }

        _ = context.assets?.texture(atPath: texturePath)

        let primitive = launchPrimitive(.pp_chemical3)
        primitive.state.renderFlag = EffectPrimitiveState.RenderFlag.alpha | EffectPrimitiveState.RenderFlag.noDepth
        primitive.state.duration = duration
        primitive.state.totalTexture = 1
        primitive.state.texturePaths = [texturePath]

        let direction: Float = clockwise ? 1.0 : -1.0
        let riseAngle = EffectPrimitive.angle(dx: deltaPos.x - position.x, dy: deltaPos.z - position.z)

        for index in 0..<4 {
            primitive.state.slots[index].life = 1
            primitive.state.slots[index].process = 0
            primitive.state.slots[index].distance = 100.0
            primitive.state.slots[index].maxHeight = Float(Int.random(in: 0..<6)) * 0.1 + 0.5
            primitive.state.slots[index].flag1[0] = Int8(Int.random(in: 0..<3) + 125)
            primitive.state.slots[index].height[0] = (Float(Int.random(in: 0..<11)) + 15.0) * direction
            primitive.state.slots[index].height[1] = Float(Int.random(in: 0..<200))
            primitive.state.slots[index].height[2] = Float(Int.random(in: 0..<31)) + 40.0
            primitive.state.slots[index].height[3] = Float(Int.random(in: 0..<11)) * 0.1 + 1.0
            primitive.state.slots[index].riseAngle = riseAngle
            primitive.state.slots[index].alphaB = 0
        }
    }
}
