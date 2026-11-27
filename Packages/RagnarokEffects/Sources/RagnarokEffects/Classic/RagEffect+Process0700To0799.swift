//
//  RagEffect+Process0700To0799.swift
//  RagnarokEffects
//
//  Created by Leon Li on 2026/11/26.
//

import Foundation
import RagnarokCore
import simd

extension RagEffect {
    nonisolated static let proceduralEffectIDs0700To0799: [EffectID] = [
        .ef_mapsphere2,
        .ef_glow11,
        .ef_glow12,
        .ef_circlelight,
        .ef_item318,
        .ef_map_greenlight,
        .ef_map_magicwall,
        .ef_map_greenlight2,
        .ef_yellowfly1,
        .ef_yellowfly2,
        .ef_bottom_blue,
        .ef_bottom_blue2,
        .ef_firepillaron2,
        .ef_forestlight5,
        .ef_soulbreaker3,
        .ef_ign_str,
        .ef_chimto2,
        .ef_windcutter,
        .ef_detect2,
        .ef_frostmysty,
        .ef_spr_mash,
        .ef_spr_soule,
        .ef_earthwall,
        .ef_soulbreaker4,
        .ef_chookgi_fire,
        .ef_chookgi_wind,
        .ef_chookgi_water,
        .ef_chookgi_ground,
        .ef_magenta_trap,
        .ef_cobalt_trap,
        .ef_maize_trap,
        .ef_verdure_trap,
        .ef_normal_trap,
        .ef_cloaking2,
        .ef_concentration2,
        .ef_fireball2,
        .ef_bunsinjyutsu2,
        .ef_cleartime,
        .ef_glasswall3,
        .ef_oratio,
        .ef_potion_berserk2,
        .ef_circlepower,
        .ef_rolling1,
        .ef_rolling2,
        .ef_rolling3,
        .ef_rolling4,
        .ef_rolling5,
        .ef_rolling6,
        .ef_rolling7,
        .ef_rolling8,
        .ef_rolling9,
        .ef_rolling10,
        .ef_purplebody,
        .ef_stin6,
        .ef_rg_coin4,
        .ef_poisonwav,
        .ef_poisonsmoke,
        .ef_gumgang4,
        .ef_shieldboomerang4,
        .ef_castspin2,
        .ef_vulcanwav,
        .ef_agiup2,
        .ef_detect3,
        .ef_agiup3,
        .ef_detect4,
        .ef_electric3,
        .ef_guard4,
        .ef_bottom_barrier,
        .ef_bottom_stealth,
        .ef_repairtime,
        .ef_nc_anal,
        .ef_firethrow,
        .ef_venomimpress,
        .ef_frostmisty,
        .ef_burning,
        .ef_coldthrow,
        .ef_makehallu,
        .ef_hallutime,
        .ef_infraredscan,
        .ef_gthunder,
        .ef_stonering,
        .ef_intimidate2,
        .ef_stasis,
    ]

    func process0700To0799(context: EffectTickContext) -> Bool {
        switch effectID {
        case .ef_mapsphere2:
            texturedAura(texturePath: K2L("effect\\구체12.bmp"), kind: 12, context: context)
            texturedAura(texturePath: K2L("effect\\구체3.bmp"), kind: 13, context: context)
            texturedAura(texturePath: K2L("effect\\구체14.bmp"), kind: 11, context: context)
            texturedAura(texturePath: K2L("effect\\구체15.bmp"), kind: 10, context: context)
        case .ef_glow11:
            texturedAura(texturePath: "effect\\glow11.bmp", kind: 15, context: context)
        case .ef_glow12:
            texturedAura(texturePath: "effect\\glow12b .bmp", kind: 14, context: context)
        case .ef_circlelight:
            texturedBeams(texturePath: "effect\\alpha_upper.tga", flag: 0, context: context)
            freezingCircle(kind: 4, context: context)
        case .ef_item318:
            texturedClassChange(kind: 37, context: context)
        case .ef_map_greenlight:
            texturedAura(texturePath: "effect\\b.bmp", kind: 18, context: context)
            texturedAura(texturePath: "effect\\glow02.bmp", kind: 16, context: context)
            texturedAura(texturePath: "effect\\glow02.bmp", kind: 17, context: context)
            freezingCircle(kind: 5, context: context)
        case .ef_map_magicwall:
            waterfallSheets(first: 0, second: 10, third: 10, context: context)
            for _ in 0..<2 {
                freezingCircle(kind: 6, context: context)
            }
        case .ef_map_greenlight2:
            texturedAura(texturePath: "effect\\b.bmp", kind: 18, context: context)
            texturedAura(texturePath: "effect\\glow03.bmp", kind: 16, context: context)
            texturedAura(texturePath: "effect\\glow03.bmp", kind: 17, context: context)
            freezingCircle(kind: 7, context: context)
        case .ef_yellowfly1:
            whiteLightSparkle(kind: 0, context: context)
        case .ef_yellowfly2:
            whiteLightSparkle(kind: 1, context: context)
        case .ef_bottom_blue, .ef_bottom_blue2:
            texturedFourRing(texturePath: "effect\\ring_blue.tga", kind: 10, context: context)
            texturedFourRing(texturePath: "effect\\ring_blue.tga", kind: 11, context: context)
        case .ef_firepillaron2:
            ringStack(white: 1, context: context)
            for _ in 0..<3 {
                texturedSpreadFlat(texturePath: "effect\\ring_white.tga", kind: 11, context: context)
            }
        case .ef_forestlight5:
            forestLight(texturePath: "effect\\cloud11.tga", flag: 12, context: context)
        case .ef_soulbreaker3:
            if stateCnt == 20 {
                context.world.playSound(
                    named: K2L("effect\\기공포.wav"),
                    atWorldPosition: EffectSpace.toWorldPosition(position),
                    delay: 0
                )
            }
            if stateCnt >= 0 && stateCnt <= 10, let targetID = targetObjectID ?? ownerObjectID {
                context.world.applyTargetModifier(
                    .tint(color: SIMD4<Float>(205.0 / 255.0, 205.0 / 255.0, 0.0, 1.0), durationTicks: 2),
                    to: targetID
                )
            }
            sonicWave(sonic: 1, context: context)
        case .ef_ign_str:
            if stateCnt == 0 {
                configureSTR(path: K2L("이그니션브레이크.str"))
            }
            texturedSkillAura(type: Int(7), context: context)
            _ = processEZ2STR(offset: SIMD3<Float>(0, -80.0, 0), context: context)
        case .ef_chimto2:
            if stateCnt == 0 {
                context.world.playSound(
                    named: "hundred.wav",
                    atWorldPosition: EffectSpace.toWorldPosition(position),
                    delay: 0
                )
            }
            chimto(flag: 12, context: context)
        case .ef_windcutter:
            if stateCnt == 1 {
                context.world.playSound(
                    named: "effect\\wl_siennaexecrate.wav",
                    atWorldPosition: EffectSpace.toWorldPosition(position),
                    delay: 0
                )
            }
            texturedSkillAura(type: Int(8), context: context)
        case .ef_detect2:
            texturedSkillAura(type: Int(2), context: context)
        case .ef_frostmysty:
            if stateCnt == 10 {
                context.world.playSound(
                    named: K2L("effect\\t_에너지방출.wav"),
                    atWorldPosition: EffectSpace.toWorldPosition(position),
                    delay: 0
                )
            }
            saintWing(texturePath: "effect\\freeze_a.bmp", context: context)
            snowFall(kind: 1, context: context)
        case .ef_spr_mash:
            texturedClassChange(kind: 38, context: context)
        case .ef_spr_soule:
            texturedClassChange(kind: 39, context: context)
        case .ef_earthwall:
            stoneWall(context: context)
        case .ef_soulbreaker4:
            if stateCnt == 20 {
                context.world.playSound(
                    named: K2L("effect\\기공포.wav"),
                    atWorldPosition: EffectSpace.toWorldPosition(position),
                    delay: 0
                )
            }
            if stateCnt >= 0 && stateCnt <= 10, let targetID = targetObjectID ?? ownerObjectID {
                context.world.applyTargetModifier(
                    .tint(color: SIMD4<Float>(155.0 / 255.0, 155.0 / 255.0, 1.0, 1.0), durationTicks: 2),
                    to: targetID
                )
            }
            sonicWave(sonic: 1, context: context)
        case .ef_chookgi_fire:
            elementalOrbit(kind: 10, context: context)
        case .ef_chookgi_wind:
            elementalOrbit(kind: 11, context: context)
        case .ef_chookgi_water:
            elementalOrbit(kind: 12, context: context)
        case .ef_chookgi_ground:
            elementalOrbit(kind: 13, context: context)
        case .ef_magenta_trap:
            texturedClassChange(kind: 53, context: context)
        case .ef_cobalt_trap:
            texturedClassChange(kind: 52, context: context)
        case .ef_maize_trap:
            texturedClassChange(kind: 51, context: context)
        case .ef_verdure_trap:
            texturedClassChange(kind: 54, context: context)
        case .ef_normal_trap:
            texturedClassChange(kind: 50, context: context)
        case .ef_cloaking2:
            assassinCloaking(context: context)
        case .ef_concentration2:
            if stateCnt >= 10 && stateCnt <= 40, let targetID = targetObjectID ?? ownerObjectID {
                context.world.applyTargetModifier(
                    .tint(color: SIMD4<Float>(155.0 / 255.0, 155.0 / 255.0, 1.0, 1.0), durationTicks: 2),
                    to: targetID
                )
            }
            return concentration(context: context)
        case .ef_fireball2:
            shadedFireballVolley(context: context)
        case .ef_bunsinjyutsu2:
            spawnLightBlur(context: context)
        case .ef_cleartime:
            if stateCnt == 1 {
                context.world.playSound(
                    named: K2L("effect\\샤프슈팅.wav"),
                    atWorldPosition: EffectSpace.toWorldPosition(position),
                    delay: 0
                )
            }
            texturedRisingOrbs(texturePath: "effect\\white02.bmp", kind: 1, context: context)
            texturedMark(texturePath: "effect\\storm2.tga", kind: 8, context: context)
        case .ef_glasswall3:
            whiteRingWave(context: context)
            return texturedRisingRingStages(texturePath: "effect\\alpha_down.tga", level: 0, context: context)
        case .ef_oratio:
            texturedAura(texturePath: K2L("effect\\마법진1-3.bmp"), kind: 19, context: context)
        case .ef_potion_berserk2:
            return potionAwakening(context: context)
        case .ef_circlepower:
            empShockBurst(texturePath: "effect\\emp shock.tga", flag: 0, context: context)
        case .ef_rolling1:
            texturedSlam(texturePath: K2L("effect\\회전카운터1.tga"), kind: 0, context: context)
        case .ef_rolling2:
            texturedSlam(texturePath: K2L("effect\\회전카운터2.tga"), kind: 0, context: context)
        case .ef_rolling3:
            texturedSlam(texturePath: K2L("effect\\회전카운터3.tga"), kind: 0, context: context)
        case .ef_rolling4:
            texturedSlam(texturePath: K2L("effect\\회전카운터4.tga"), kind: 0, context: context)
        case .ef_rolling5:
            texturedSlam(texturePath: K2L("effect\\회전카운터5.tga"), kind: 0, context: context)
        case .ef_rolling6:
            texturedSlam(texturePath: K2L("effect\\회전카운터6.tga"), kind: 0, context: context)
        case .ef_rolling7:
            texturedSlam(texturePath: K2L("effect\\회전카운터7.tga"), kind: 0, context: context)
        case .ef_rolling8:
            texturedSlam(texturePath: K2L("effect\\회전카운터8.tga"), kind: 0, context: context)
        case .ef_rolling9:
            texturedSlam(texturePath: K2L("effect\\회전카운터9.tga"), kind: 0, context: context)
        case .ef_rolling10:
            texturedSlam(texturePath: K2L("effect\\회전카운터10.tga"), kind: 0, context: context)
        case .ef_purplebody:
            if stateCnt < 31, let targetID = targetObjectID ?? ownerObjectID {
                let color = stateCnt % 2 == 0
                    ? SIMD4<Float>(1.0, 0.0, 1.0, 1.0)
                    : SIMD4<Float>(1.0, 1.0, 1.0, 1.0)
                context.world.applyTargetModifier(.tint(color: color, durationTicks: 2), to: targetID)
            }
        case .ef_stin6:
            if stateCnt == 5 || stateCnt == 20 || stateCnt == 35 || stateCnt == 50 || stateCnt == 65 {
                context.world.playSound(
                    named: K2L("effect\\T_날라차기.wav"),
                    atWorldPosition: EffectSpace.toWorldPosition(position),
                    delay: 0
                )
            }
        case .ef_rg_coin4:
            if stateCnt == 1 || stateCnt == 11 || stateCnt == 21 || stateCnt == 31 {
                context.world.playSound(
                    named: K2L("effect\\복호격.wav"),
                    atWorldPosition: EffectSpace.toWorldPosition(position),
                    delay: 0
                )
            }
            texturedSprayKind(texturePath: K2L("유저인터페이스\\item\\루드라의활.bmp"), spin: 5.0, kind: 0, context: context)
            texturedSprayKind(texturePath: K2L("유저인터페이스\\item\\아트로스의흉기.bmp"), spin: 5.0, kind: 0, context: context)
            texturedSprayKind(texturePath: K2L("유저인터페이스\\item\\모닝스타.bmp"), spin: 5.0, kind: 0, context: context)
            texturedSprayKind(texturePath: K2L("유저인터페이스\\item\\바스타드소드.bmp"), spin: 5.0, kind: 0, context: context)
            texturedSprayKind(texturePath: K2L("유저인터페이스\\item\\글레이브.bmp"), spin: 5.0, kind: 0, context: context)
            texturedSprayKind(texturePath: K2L("유저인터페이스\\item\\블레이드휩.bmp"), spin: 5.0, kind: 0, context: context)
            texturedSprayKind(texturePath: K2L("유저인터페이스\\item\\드래곤슬레이어.bmp"), spin: 5.0, kind: 0, context: context)
            texturedSprayKind(texturePath: K2L("유저인터페이스\\item\\배틀액스.bmp"), spin: 5.0, kind: 0, context: context)
        case .ef_poisonwav:
            if stateCnt == 1 {
                context.world.playSound(
                    named: "effect\\assasin_enchantpoison.wav",
                    atWorldPosition: EffectSpace.toWorldPosition(position),
                    delay: 0
                )
                context.world.playSound(
                    named: "effect\\EF_PoisonAttack.wav",
                    atWorldPosition: EffectSpace.toWorldPosition(position),
                    delay: 0
                )
            }
        case .ef_poisonsmoke:
            poisonAttack(flag: 1, context: context)
        case .ef_gumgang4:
            texturedCrossKind(texturePath: "effect\\ring_purple.tga", level: 1, context: context)
        case .ef_shieldboomerang4:
            texturedShieldThrow(texturePath: K2L("유저인터페이스\\item\\배틀액스.bmp"), context: context)
        case .ef_castspin2:
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
        case .ef_vulcanwav:
            if stateCnt == 45 {
                context.world.playSound(
                    named: K2L("effect\\데스페라도.wav"),
                    atWorldPosition: EffectSpace.toWorldPosition(position),
                    delay: 0
                )
            }
        case .ef_agiup2:
            if stateCnt < 61, let targetID = targetObjectID ?? ownerObjectID {
                let color = stateCnt % 2 == 0
                    ? SIMD4<Float>(155.0 / 255.0, 155.0 / 255.0, 1.0, 1.0)
                    : SIMD4<Float>(1.0, 1.0, 1.0, 1.0)
                context.world.applyTargetModifier(.tint(color: color, durationTicks: 2), to: targetID)
            }
            incAgilityCenter(kind: 2, context: context)
        case .ef_detect3:
            texturedSkillAura(type: Int(3), context: context)
        case .ef_agiup3:
            if stateCnt < 61, let targetID = targetObjectID ?? ownerObjectID {
                let color = stateCnt % 2 == 0
                    ? SIMD4<Float>(155.0 / 255.0, 155.0 / 255.0, 1.0, 1.0)
                    : SIMD4<Float>(1.0, 1.0, 1.0, 1.0)
                context.world.applyTargetModifier(.tint(color: color, durationTicks: 2), to: targetID)
            }
            incAgilityCenter(kind: 3, context: context)
        case .ef_detect4:
            texturedSkillAura(type: Int(4), context: context)
        case .ef_electric3:
            if stateCnt == 5 {
                context.world.playSound(
                    named: "effect\\MAGNETICFIELD.wav",
                    atWorldPosition: EffectSpace.toWorldPosition(position),
                    delay: 0
                )
            }
            electricRingEarly(kind: 0, angle: 0, context: context)
            electricRingEarly(kind: 0, angle: 180, context: context)
        case .ef_guard4:
            blackMaximize(texturePath: K2L("effect\\성체강복.tga"), context: context)
            if stateCnt >= 10 && stateCnt <= 30, let targetID = targetObjectID ?? ownerObjectID {
                let color = stateCnt % 2 == 0
                    ? SIMD4<Float>(250.0 / 255.0, 250.0 / 255.0, 0.0, 1.0)
                    : SIMD4<Float>(1.0, 1.0, 1.0, 1.0)
                context.world.applyTargetModifier(.tint(color: color, durationTicks: 2), to: targetID)
            }
        case .ef_bottom_barrier:
            texturedGlow(texturePath: "effect\\slash01.tga", size: 8, context: context)
        case .ef_bottom_stealth:
            texturedGlow(texturePath: K2L("effect\\썬더스톰파티클.tga"), size: 8, context: context)
        case .ef_repairtime:
            texturedRisingOrbs(texturePath: K2L("유저인터페이스\\item\\스패너.bmp"), kind: 2, context: context)
        case .ef_nc_anal:
            if stateCnt >= 10 && stateCnt <= 90, let targetID = targetObjectID ?? ownerObjectID {
                let color = stateCnt % 2 == 0
                    ? SIMD4<Float>(250.0 / 255.0, 250.0 / 255.0, 250.0 / 255.0, 1.0)
                    : SIMD4<Float>(1.0, 1.0, 1.0, 1.0)
                context.world.applyTargetModifier(.tint(color: color, durationTicks: 2), to: targetID)
            }
            texturedSkillAura(type: Int(5), context: context)
            texturedAura(texturePath: "effect\\target3.bmp", kind: 21, context: context)
        case .ef_firethrow:
            torchRedRing(kind: 0, context: context)
        case .ef_venomimpress:
            texturedAura(texturePath: K2L("effect\\베놈_상태.bmp"), kind: 22, context: context)
        case .ef_frostmisty:
            texturedAura(texturePath: K2L("effect\\빙결_상태.bmp"), kind: 22, context: context)
        case .ef_burning:
            texturedAura(texturePath: K2L("effect\\발화_상태.bmp"), kind: 22, context: context)
        case .ef_coldthrow:
            if stateCnt == 0 {
                context.world.playSound(
                    named: "ice_titan_attack.wav",
                    atWorldPosition: EffectSpace.toWorldPosition(position),
                    delay: 0
                )
            }
            if stateCnt >= 6 && stateCnt <= 40, let targetID = targetObjectID ?? ownerObjectID {
                let color = stateCnt % 2 == 0
                    ? SIMD4<Float>(0.0, 0.0, 1.0, 1.0)
                    : SIMD4<Float>(1.0, 1.0, 1.0, 1.0)
                context.world.applyTargetModifier(.tint(color: color, durationTicks: 2), to: targetID)
            }
            for _ in 0..<3 {
                snowDrift(flag: 0, context: context)
            }
        case .ef_makehallu:
            let tintRGB = deltaPos2 == .zero ? SIMD3<Float>(250, 250, 250) : deltaPos2
            spawnTargetHallucination(tintRGB: tintRGB, context: context)
        case .ef_hallutime:
            texturedRisingOrbs(texturePath: "effect\\white02.bmp", kind: 3, context: context)
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
        case .ef_gthunder:
            texturedMark(texturePath: "effect\\storm2.tga", kind: 10, context: context)
            texturedRisingPillar(texturePath: "effect\\white01.bmp", context: context)
        case .ef_stonering:
            if stateCnt == 0 {
                context.world.playSound(
                    named: "effect\\wl_siennaexecrate.wav",
                    atWorldPosition: EffectSpace.toWorldPosition(position),
                    delay: 0
                )
            }
            texturedClassChange(kind: 60, context: context)
        case .ef_intimidate2:
            for _ in 0..<16 {
                whiteSpray(kind: 2, context: context)
            }
        case .ef_stasis:
            if stateCnt == 6 {
                context.world.playSound(
                    named: "effect\\wl_stasis.wav",
                    atWorldPosition: EffectSpace.toWorldPosition(position),
                    delay: 0
                )
            }
            if stateCnt >= 6 && stateCnt <= 40, let targetID = targetObjectID ?? ownerObjectID {
                let color = stateCnt % 2 == 0
                    ? SIMD4<Float>(0.0, 0.0, 1.0, 1.0)
                    : SIMD4<Float>(1.0, 1.0, 1.0, 1.0)
                context.world.applyTargetModifier(.tint(color: color, durationTicks: 2), to: targetID)
            }
            texturedLevelRing(texturePath: "effect\\thunder_ball_0001.bmp", process: -10, level: 3, context: context)
            texturedLevelRing(texturePath: "effect\\thunder_ball_0002.bmp", process: -14, level: 3, context: context)
            texturedLevelRing(texturePath: "effect\\thunder_ball_0003.bmp", process: -18, level: 3, context: context)
            texturedLevelRing(texturePath: "effect\\thunder_ball_0004.bmp", process: -22, level: 3, context: context)
            texturedLevelRing(texturePath: "effect\\thunder_ball_0005.bmp", process: -26, level: 3, context: context)
            texturedLevelRing(texturePath: "effect\\thunder_ball_0006.bmp", process: -30, level: 3, context: context)
        default:
            return false
        }
        return true
    }

    // MARK: - EF_CIRCLELIGHT (703)

    /// Spawns 3-layer bobbing light beams (`129`) for `EF_CIRCLELIGHT` (703).
    func texturedBeams(texturePath: String, flag: Int8, context: EffectTickContext) {
        guard stateCnt == 0 else {
            return
        }

        _ = context.assets?.texture(atPath: texturePath)

        let primitive = launchPrimitive(129)
        primitive.state.renderFlag = EffectPrimitiveState.RenderFlag.alpha | EffectPrimitiveState.RenderFlag.customBlend
        primitive.state.duration = duration
        primitive.state.totalTexture = 1
        primitive.state.texturePaths = [texturePath]

        for i in 0..<4 {
            primitive.state.slots[i].life = 0
        }

        for index in 0..<3 {
            primitive.state.slots[index].life = 1
            primitive.state.slots[index].process = 0
            primitive.state.slots[index].alphaB = 30
            primitive.state.slots[index].distance = 0
            primitive.state.slots[index].maxHeight = Float(index) * 0.5 + 3.0
            primitive.state.slots[index].height[0] = primitive.state.slots[index].maxHeight
            primitive.state.slots[index].rotStart = Int16(index * 25)
            primitive.state.slots[index].vecTNow = position
            deltaPos = SIMD3<Float>(position.x, position.y - 40.0, position.z)
            primitive.state.slots[index].vecTPre = deltaPos
            primitive.state.slots[index].flag1[0] = flag
        }
    }

    // MARK: - EF_YELLOWFLY1 (713)

    /// Spawns drifting golden firefly sparkles (`130`) for `EF_YELLOWFLY1` (713) and `EF_YELLOWFLY2` (714).
    func whiteLightSparkle(kind: Int8, context: EffectTickContext) {
        if stateCnt == 99_999_998 {
            stateCnt = 0
            duration = 99_999_999
        } else if stateCnt != 0 {
            return
        }

        let texturePath = "effect\\whitelight.tga"
        _ = context.assets?.texture(atPath: texturePath)

        let primitive = launchPrimitive(130)
        primitive.state.renderFlag = EffectPrimitiveState.RenderFlag.alpha | EffectPrimitiveState.RenderFlag.customBlend
        primitive.state.duration = duration
        primitive.state.totalTexture = 1
        primitive.state.texturePaths = [texturePath]
        primitive.state.size = 0

        for i in 0..<4 {
            primitive.state.slots[i].life = (kind == 1 && i >= 1) ? 0 : 1
            primitive.state.slots[i].maxHeight = 0.15
            primitive.state.slots[i].distance = 2.4

            if kind == 1 {
                primitive.state.slots[i].vecBPre = .zero
            } else {
                primitive.state.slots[i].vecBPre = SIMD3<Float>(
                    Float(Int.random(in: 0..<41) - 20),
                    0,
                    Float(Int.random(in: 0..<41) - 20)
                )
            }
            primitive.state.slots[i].vecBNow = SIMD3<Float>(
                Float(Int.random(in: 0..<41) - 20),
                0,
                Float(Int.random(in: 0..<41) - 20)
            )
            primitive.state.slots[i].vecTPre = SIMD3<Float>(
                Float(Int.random(in: 0..<41) - 20),
                0,
                Float(Int.random(in: 0..<41) - 20)
            )
            primitive.state.slots[i].vecTNow = SIMD3<Float>(
                Float(Int.random(in: 0..<41) - 20),
                0,
                Float(Int.random(in: 0..<41) - 20)
            )
            for h in 0..<16 {
                primitive.state.slots[i].height[h] = Float(Int.random(in: 0..<360))
            }
            for f in 0..<15 {
                primitive.state.slots[i].flag1[f] = 0
            }
            primitive.state.slots[i].flag1[0] = kind
            primitive.state.slots[i].flag1[5] = kind == 2 ? 10 : 8
        }
    }

    // MARK: - EF_FIREPILLARON2 (718)

    /// Spawns 4-slot radial height-ramp rings (`137`) for `EF_FIREPILLARON2` (718).
    func texturedSpreadFlat(texturePath: String, kind: Int8, context: EffectTickContext) {
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
        } else if kind == 12 {
            switch Int.random(in: 0..<3) {
            case 0: primitive.state.size = 4.0
            case 1: primitive.state.size = 40.0
            default: primitive.state.size = 41.0
            }
        }

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
            } else if kind == 12 {
                primitive.state.slots[index].alphaB = 130
                primitive.state.slots[index].maxHeight = Float(index * 30) + 30.0
                primitive.state.slots[index].process = Int.random(in: 0..<50) + 50
                radius = Float(Int.random(in: 0..<17))
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
            primitive.state.slots[index].vecTPre = .zero
        }
    }

    // MARK: - EF_FROSTMYSTY (726)

    /// Spawns expanding ground ripple fan (`131`) for `EF_FROSTMYSTY` (726).
    func saintWing(texturePath: String, context: EffectTickContext) {
        guard stateCnt == 0 else {
            return
        }

        _ = context.assets?.texture(atPath: texturePath)

        let primitive = launchPrimitive(131)
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
        primitive.state.slots[0].distance = 24.0
        primitive.state.slots[0].alphaB = 0
        primitive.state.slots[0].height = Array(repeating: 0, count: 21)
        primitive.state.slots[0].flag1[0] = 0
        primitive.state.slots[0].flag1[4] = 1
    }

    /// Emits falling snowflake bursts (`PP_PARTICLE_UP` (59)) every 8 ticks up to tick 100 for `EF_FROSTMYSTY` (726).
    func snowFall(kind: Int8, context: EffectTickContext) {
        guard stateCnt >= 0, stateCnt <= 100, stateCnt % 8 == 0 else {
            return
        }

        let textures = ["effect\\E9_snow03.tga", "effect\\E9_snow02.tga"]
        for path in textures {
            _ = context.assets?.texture(atPath: path)
        }

        let primitive = launchPrimitive(.pp_particle_up)
        primitive.state.renderFlag = EffectPrimitiveState.RenderFlag.alpha | EffectPrimitiveState.RenderFlag.customBlend
        primitive.state.duration = duration
        primitive.state.totalTexture = 2
        primitive.state.texturePaths = textures
        primitive.state.size = 0
        primitive.position = position

        let colorStyle: Int8 = switch kind {
        case 0: 11
        case 1, 2: 1
        case 3: 13
        default: 0
        }

        for index in 0..<4 {
            primitive.state.slots[index].life = 1
            primitive.state.slots[index].process = 0
            primitive.state.slots[index].distance = Float(Int.random(in: 0..<6)) * 0.1 + 1.5
            primitive.state.slots[index].height[8] = 0
            primitive.state.slots[index].alphaB = 0
            let radius = Float(Int.random(in: 0..<41))
            let angle = Int.random(in: 0..<360)
            primitive.state.slots[index].vecBNow = SIMD3<Float>(
                position.x + radius * EffectSpace.cosine(degrees: angle),
                position.y - 6.0 - Float(Int.random(in: 0..<31)),
                position.z + radius * EffectSpace.sine(degrees: angle)
            )
            primitive.state.slots[index].rotStart = 0
            primitive.state.slots[index].height[1] = 0
            primitive.state.slots[index].height[2] = Float(Int.random(in: 0..<20)) * 0.01 + 0.1
            primitive.state.slots[index].fullDisplayAngle = 0
            primitive.state.slots[index].flag1[0] = 0
            primitive.state.slots[index].flag1[1] = 1
            primitive.state.slots[index].flag1[2] = colorStyle
            primitive.state.slots[index].height[7] = 0
        }
    }

    // MARK: - EF_EARTHWALL (732)

    /// Spawns 3 erupting stone wall pyramids (`PP_3DQUADHORN` (9)) for `EF_EARTHWALL` (732).
    func stoneWall(context: EffectTickContext) {
        guard stateCnt == 0 else {
            return
        }

        context.world.playSound(
            named: "effect\\wizard_icewall.wav",
            atWorldPosition: EffectSpace.toWorldPosition(position),
            delay: 0
        )
        duration = 9999

        let texturePath = "effect\\stone.bmp"
        _ = context.assets?.texture(atPath: texturePath)

        for offset in stride(from: -2, to: 4, by: 2) {
            let primitive = launchPrimitive(.pp_3dquadhorn)
            primitive.state.duration = duration
            primitive.state.pattern |= 1
            let angle = Int.random(in: 0..<360)
            let cosine = EffectSpace.cosine(degrees: angle)
            primitive.state.deltaPos2 = SIMD3<Float>(0, 30.0, -Float(offset) * cosine)
            primitive.state.size = Float(Int.random(in: 0..<40) / 100) + 2.5
            primitive.state.heightSize = Float(Int.random(in: 0..<100) + 300) / 10.0
            primitive.state.longitude = Float(Int.random(in: 0..<360))
            primitive.state.latitude = Float(Int.random(in: 0..<6) + 87)
            primitive.state.chCnt = 20
            primitive.state.alpha = 200.0
            let rotX = EffectSpace.rotationX(radians: EffectSpace.radian(degrees: Int(primitive.state.latitude)))
            let rotY = EffectSpace.rotationY(radians: EffectSpace.radian(degrees: Int(primitive.state.longitude)))
            primitive.state.transform = rotY * rotX
            primitive.state.rotTransform = primitive.state.transform
            primitive.state.speed = 3.0
            let decay = -(primitive.state.speed / 40.0)
            primitive.state.accel = decay + decay
            primitive.state.fadeOutCnt = primitive.state.duration - 10
            primitive.state.texturePaths = [texturePath]
        }
    }

    // MARK: - EF_CONCENTRATION2 (750)

    /// Plays concentration audio on tick 0 and advances `Concentration.str` for `EF_CONCENTRATION2` (750).
    func concentration(context: EffectTickContext) -> Bool {
        if stateCnt == 0 {
            configureSTR(path: "Concentration.str")
            context.world.playSound(
                named: "effect\\ac_concentration.wav",
                atWorldPosition: EffectSpace.toWorldPosition(position),
                delay: 0
            )
        }
        return processEZ2STR(offset: SIMD3<Float>(0, -80.0, 0), context: context)
    }

    // MARK: - EF_FIREBALL2 (751)

    /// Emits 3 tinted directional fireball volleys (`PP_3DPARTICLE` (5)) for `EF_FIREBALL2` (751).
    func shadedFireballVolley(context: EffectTickContext) {
        if stateCnt == 5 {
            context.world.playSound(
                named: "effect\\EF_FireBall.wav",
                atWorldPosition: EffectSpace.toWorldPosition(position),
                delay: 0
            )
        }

        func launchVolley(turn: Float, red: Int, green: Int, blue: Int, fade: Int) {
            let spritePath = K2L("이팩트\\fireball.spr")
            let actionPath = K2L("이팩트\\fireball.act")
            _ = context.assets?.spriteAsset(spritePath: spritePath, actionPath: actionPath)

            let primitive = launchPrimitive(.pp_3dparticle)
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
            primitive.state.red = red
            primitive.state.green = green
            primitive.state.blue = blue
            primitive.state.alpha = Float((fade - stateCnt) * 40)
            primitive.state.spritePath = spritePath
            primitive.state.actionPath = actionPath
            primitive.initSegment()
        }

        if stateCnt >= 0 && stateCnt <= 3 {
            launchVolley(turn: 0, red: 155, green: 155, blue: 255, fade: 5)
        } else if stateCnt >= 6 && stateCnt <= 9 {
            launchVolley(turn: -5.0, red: 155, green: 255, blue: 155, fade: 11)
        } else if stateCnt >= 12 && stateCnt <= 15 {
            launchVolley(turn: 5.0, red: 255, green: 155, blue: 155, fade: 17)
        }
    }

    // MARK: - EF_GLASSWALL3 (754)

    /// Spawns periodic lime-green portal wave (`63`) every 100 ticks for `EF_GLASSWALL3` (754).
    func whiteRingWave(context: EffectTickContext) {
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
        primitive.state.size = 16.0

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
        primitive.state.slots[3].alphaT = 1
    }

    /// Spawns staged lime-green rising columns (`60`) on ticks 0, 30, and 60 for `EF_GLASSWALL3` (754).
    func texturedRisingRingStages(texturePath: String, level: Int8, context: EffectTickContext) -> Bool {
        func spawnStage(heights: [Float], distances: [Float], riseAngle: Int16) {
            _ = context.assets?.texture(atPath: texturePath)

            let primitive = launchPrimitive(60)
            primitive.state.renderFlag = EffectPrimitiveState.RenderFlag.alpha | EffectPrimitiveState.RenderFlag.customBlend
            primitive.state.duration = duration
            primitive.state.totalTexture = 1
            primitive.state.texturePaths = [texturePath]
            primitive.state.size = 16.0

            for index in 0..<3 {
                primitive.state.slots[index].life = 1
                primitive.state.slots[index].process = 0
                primitive.state.slots[index].fullDisplayAngle = 360
                primitive.state.slots[index].maxHeight = heights[index]
                primitive.state.slots[index].rotStart = Int16(Int.random(in: 0..<360))
                primitive.state.slots[index].alphaB = 0
                primitive.state.slots[index].distance = distances[index]
                primitive.state.slots[index].riseAngle = riseAngle
                primitive.state.slots[index].alphaT = 3080
                primitive.state.slots[index].vecBNow.y = 0
                primitive.state.slots[index].height = Array(repeating: 0, count: 21)
                primitive.state.slots[index].flag1 = Array(repeating: 0, count: 21)
            }
            primitive.state.slots[3].life = 0
        }

        if stateCnt == 0 {
            spawnStage(heights: [13.0, 14.0, 15.0], distances: [3.6, 3.3, 3.0], riseAngle: 25)
        }

        if level == 1 {
            if stateCnt == 30 {
                context.world.playSound(
                    named: "effect\\EF_GlassWall.wav",
                    atWorldPosition: EffectSpace.toWorldPosition(position),
                    delay: 0
                )
                spawnStage(heights: [24.0, 27.0, 30.0], distances: [3.6, 3.3, 3.0], riseAngle: 90)
            }
        } else {
            if stateCnt == 30 {
                context.world.playSound(
                    named: "effect\\EF_GlassWall.wav",
                    atWorldPosition: EffectSpace.toWorldPosition(position),
                    delay: 0
                )
                spawnStage(heights: [34.0, 37.0, 40.0], distances: [3.6, 3.3, 3.0], riseAngle: 90)
            }
            if stateCnt == 60 {
                spawnStage(heights: [74.0, 77.0, 80.0], distances: [1.3, 1.0, 0.7], riseAngle: 90)
            }
        }

        return stateCnt != duration
    }

    // MARK: - EF_POTION_BERSERK2 (756)

    /// Spawns potion pillar, golden streaks (`PP_3DCROSSTEXTURE` (16)), and `버서크.str` for `EF_POTION_BERSERK2` (756).
    func potionAwakening(context: EffectTickContext) -> Bool {
        if stateCnt == 0 {
            configureSTR(path: K2L("버서크.str"))
            potionPillar(heightSpeed: 1.0, pillarDuration: 50, context: context)
        }

        if stateCnt <= 150, let targetID = targetObjectID ?? ownerObjectID {
            context.world.applyTargetModifier(
                .tint(color: SIMD4<Float>(250.0 / 255.0, 250.0 / 255.0, 200.0 / 255.0, 1.0), durationTicks: 2),
                to: targetID
            )
        }

        if stateCnt == 18 {
            context.world.shakeCamera(amplitude: 0.6, duration: 0.25, frequency: 20.0)
        }

        if stateCnt >= 13 && stateCnt <= 109 && stateCnt % 4 == 0 {
            let texturePath = "effect\\ac_center2.tga"
            _ = context.assets?.texture(atPath: texturePath)

            let streak = launchPrimitive(.pp_3dcrosstexture)
            streak.state.duration = 40
            let yaw = EffectSpace.rotationY(radians: EffectSpace.radian(degrees: Int.random(in: 0..<360)))
            streak.state.deltaPos2 = EffectSpace.transformVector(SIMD3<Float>(0, 0, Float(Int.random(in: 0..<7) + 2)), by: yaw)
            streak.state.transform = EffectSpace.rotationX(radians: EffectSpace.radian(degrees: 90))
            streak.state.speed = Float(Int.random(in: 0..<50) + 20) / 60.0
            streak.state.widthSize = Float(Int.random(in: 0..<60) + 30) / 10.0
            streak.state.heightSize = 0.2
            streak.state.red = 240
            streak.state.green = 240
            streak.state.blue = 120
            streak.state.alpha = 0
            streak.state.maxAlpha = 180.0
            streak.state.alphaSpeed = streak.state.maxAlpha / 20.0
            streak.state.fadeOutCnt = streak.state.duration - 20
            streak.state.texturePaths = [texturePath]
            streak.state.slots[0].life = 0
        }

        _ = processEZ2STR(offset: SIMD3<Float>(0, -80.0, 0), context: context)
        return stateCnt <= 150
    }

    // MARK: - EF_CIRCLEPOWER (757)

    /// Spawns dual-wave expanding shockwave panels (`132`) on ticks 0 and 10 for `EF_CIRCLEPOWER` (757).
    func empShockBurst(texturePath: String, flag: Int8, context: EffectTickContext) {
        if stateCnt >= 99_999_998 {
            stateCnt = 0
            duration = 99_999_999
        }

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
            primitive.state.slots[i].alphaB = 200
            primitive.state.slots[i].height[4] = 10.0
            primitive.state.slots[i].height[3] = Float(i)
            primitive.state.slots[i].height[5] = Float(flag)
        }
    }

    // MARK: - EF_ROLLING1 (758)

    /// Spawns rotating counter emblem halo (`147`) for `EF_ROLLING1...10` (758...767).
    func texturedSlam(texturePath: String, kind: Int16, context: EffectTickContext) {
        guard stateCnt == 0 else {
            return
        }

        _ = context.assets?.texture(atPath: texturePath)

        let primitive = launchPrimitive(147)
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

        if kind == 1 {
            primitive.state.slots[0].distance = 21.0
            primitive.state.slots[0].flag1[4] = 6
        } else if kind == 2 {
            primitive.state.slots[0].distance = 21.0
            primitive.state.slots[0].flag1[4] = 7
        } else {
            primitive.state.slots[0].distance = 13.0
            primitive.state.slots[0].flag1[4] = 5
        }

        primitive.state.slots[0].alphaB = 0
        primitive.state.slots[0].flag1[0] = 0
        primitive.state.slots[0].height = Array(repeating: 0, count: 21)
    }

    // MARK: - EF_ELECTRIC3 (781)

    /// Spawns early radial lightning arcs (`PP_ELECTRIC` (101)) on ticks `0...3` for `EF_ELECTRIC3` (781).
    func electricRingEarly(kind: Int8, angle: Int16, context: EffectTickContext) {
        guard stateCnt >= 0, stateCnt <= 3 else {
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
            primitive.state.slots[index].vecBNow = SIMD3<Float>(position.x, position.y - 5.0, position.z)
            primitive.state.slots[index].vecTNow.y = 20.0
            for step in 1...20 {
                primitive.state.slots[index].height[step] = 0
                primitive.state.slots[index].flag1[step] = 0
            }
            primitive.state.slots[index].flag1[0] = 0
            primitive.state.slots[index].alphaT = Int16(kind)
            primitive.state.slots[index].fullDisplayAngle = 3
        }
    }

    // MARK: - EF_FIRETHROW (787)

    /// Spawns directional red flame trail (`133`) for `EF_FIRETHROW` (787).
    func torchRedRing(kind: Int8, context: EffectTickContext) {
        guard stateCnt == 0 else {
            return
        }

        let texturePaths = (1...13).map { String(format: "effect\\torch_red%02d.bmp", $0) }
        for path in texturePaths {
            _ = context.assets?.texture(atPath: path)
        }

        let primitive = launchPrimitive(133)
        primitive.state.renderFlag = EffectPrimitiveState.RenderFlag.alpha | EffectPrimitiveState.RenderFlag.customBlend
        primitive.state.duration = duration
        primitive.state.totalTexture = 13
        primitive.state.texturePaths = texturePaths
        primitive.state.size = 0
        primitive.state.deltaPos = deltaPos

        for i in 1..<4 {
            primitive.state.slots[i].life = 0
        }
        primitive.state.slots[0].life = 1
        primitive.state.slots[0].process = 0
        primitive.state.slots[0].distance = 12.0
        primitive.state.slots[0].vecBPre.y = position.y - 12.0
        primitive.state.slots[0].flag1[2] = 4
        primitive.state.slots[0].height[10] = 0
        primitive.state.slots[0].fullDisplayAngle = 135
        primitive.state.slots[0].height[8] = 0
        primitive.state.slots[0].alphaB = 0

        var rise = EffectPrimitive.angle(dx: position.x - deltaPos.x, dy: position.z - deltaPos.z) + 180
        if rise >= 360 {
            rise -= 360
        }
        primitive.state.slots[0].riseAngle = rise
        primitive.state.slots[0].vecBNow = SIMD3<Float>(deltaPos.x, primitive.state.slots[0].vecBPre.y, deltaPos.z)
        primitive.state.slots[0].rotStart = Int16(Int.random(in: 0..<360))
        primitive.state.slots[0].flag1[0] = 0
        primitive.state.slots[0].flag1[4] = kind
    }

    // MARK: - EF_COLDTHROW (791)

    /// Spawns directional snow flake bursts (`134`) for `EF_COLDTHROW` (791).
    func snowDrift(flag: Int8, context: EffectTickContext) {
        guard stateCnt == 0 else {
            return
        }

        let texturePaths = [
            "effect\\E9_snow.tga",
            "effect\\E9_snow01.tga",
            "effect\\E9_snow02.tga",
            "effect\\E9_snow03.tga",
        ]
        for path in texturePaths {
            _ = context.assets?.texture(atPath: path)
        }

        let primitive = launchPrimitive(134)
        primitive.state.renderFlag = EffectPrimitiveState.RenderFlag.alpha | EffectPrimitiveState.RenderFlag.customBlend
        primitive.state.duration = duration
        primitive.state.totalTexture = 4
        primitive.state.texturePaths = texturePaths
        primitive.state.size = 0
        primitive.state.deltaPos = deltaPos

        let baseRise = EffectPrimitive.angle(dx: position.x - deltaPos.x, dy: position.z - deltaPos.z)
        for index in 0..<4 {
            primitive.state.slots[index].life = 1
            primitive.state.slots[index].process = 0
            primitive.state.slots[index].distance = Float(Int.random(in: 0..<21)) * 0.08 + 2.5
            primitive.state.slots[index].vecBPre.y = position.y - 12.0
            primitive.state.slots[index].flag1[2] = Int8(Int.random(in: 0..<4))
            primitive.state.slots[index].height[10] = 0
            primitive.state.slots[index].fullDisplayAngle = Int16(Int.random(in: 0..<360))
            primitive.state.slots[index].height[8] = 0
            primitive.state.slots[index].alphaB = 0
            var rise = baseRise + Int16(Int.random(in: 0..<41) + 160)
            if rise >= 360 {
                rise -= 360
            }
            primitive.state.slots[index].riseAngle = rise
            primitive.state.slots[index].vecBNow = SIMD3<Float>(deltaPos.x, primitive.state.slots[index].vecBPre.y, deltaPos.z)
            primitive.state.slots[index].rotStart = Int16(Int.random(in: 0..<360))
            primitive.state.slots[index].flag1[0] = 3
            primitive.state.slots[index].flag1[4] = flag
            primitive.state.slots[index].flag1[5] = Int8(60 - Int.random(in: 0..<21))
        }
    }

    // MARK: - EF_INFRAREDSCAN (794)

    /// Spawns primitive `135` sweeping electric jitter arcs for `EF_INFRAREDSCAN` (794).
    func electricFan(fade: Int16, context: EffectTickContext) {
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

    // MARK: - EF_GTHUNDER (796)

    /// Spawns rising lightning pillar (`136`) for `EF_GTHUNDER` (796).
    func texturedRisingPillar(texturePath: String, context: EffectTickContext) {
        guard stateCnt == 0 else {
            return
        }

        _ = context.assets?.texture(atPath: texturePath)

        let primitive = launchPrimitive(136)
        primitive.state.renderFlag = EffectPrimitiveState.RenderFlag.alpha | EffectPrimitiveState.RenderFlag.customBlend
        primitive.state.duration = duration
        primitive.state.totalTexture = 1
        primitive.state.texturePaths = [texturePath]
        primitive.state.size = 0
        primitive.position = position

        for i in 1..<4 {
            primitive.state.slots[i].life = 0
        }
        primitive.state.slots[0].life = 1
        primitive.state.slots[0].process = 0
        primitive.state.slots[0].distance = 1.0
        primitive.state.slots[0].height[8] = 0
        primitive.state.slots[0].alphaB = 0
        primitive.state.slots[0].vecBNow = position
        primitive.state.slots[0].rotStart = 0
        primitive.state.slots[0].height[1] = 0
        primitive.state.slots[0].height[2] = Float(Int.random(in: 0..<20)) * 0.01 + 0.1
        primitive.state.slots[0].fullDisplayAngle = 45
        primitive.state.slots[0].flag1[0] = 0
        primitive.state.slots[0].flag1[1] = 1
        primitive.state.slots[0].flag1[2] = 1
        primitive.state.slots[0].height[7] = 0
    }
}
