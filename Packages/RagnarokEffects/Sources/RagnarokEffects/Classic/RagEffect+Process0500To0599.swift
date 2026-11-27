//
//  RagEffect+Process0500To0599.swift
//  RagnarokEffects
//
//  Created by Leon Li on 2026/11/26.
//

import Foundation
import RagnarokCore
import simd

extension RagEffect {
    nonisolated static let proceduralEffectIDs0500To0599: [EffectID] = [
        .ef_chemicalbody,
        .ef_castspin,
        .ef_piercebody,
        .ef_soullink,
        .ef_chookgi2,
        .ef_memorize,
        .ef_soullight,
        .ef_05val,
        .ef_beginasura11,
        .ef_chemical2dash,
        .ef_groundsample,
        .ef_gi_explosion,
        .ef_cloud4,
        .ef_cloud5,
        .ef_bottom_hermode,
        .ef_cartter,
        .ef_itemfast,
        .ef_shieldboomerang3,
        .ef_doublecastbody,
        .ef_gravitation,
        .ef_tarotcard1,
        .ef_tarotcard2,
        .ef_tarotcard3,
        .ef_tarotcard4,
        .ef_tarotcard5,
        .ef_tarotcard6,
        .ef_tarotcard7,
        .ef_tarotcard8,
        .ef_tarotcard9,
        .ef_tarotcard10,
        .ef_tarotcard11,
        .ef_tarotcard12,
        .ef_tarotcard13,
        .ef_tarotcard14,
        .ef_aciddemon,
        .ef_greenbody,
        .ef_throwitem4,
        .ef_babybody_back,
        .ef_throwitem5,
        .ef_bluebody,
        .ef_hated,
        .ef_redlightbody,
        .ef_ro2year,
        .ef_sma_ready,
        .ef_stin,
        .ef_red_hit,
        .ef_blue_hit,
        .ef_quakebody3,
        .ef_sma,
        .ef_sma2,
        .ef_stin2,
        .ef_hittexture,
        .ef_stin3,
        .ef_sma3,
        .ef_bluefall,
        .ef_bluefall_90,
        .ef_fastbluefall,
        .ef_fastbluefall_90,
        .ef_big_portal,
        .ef_big_portal2,
        .ef_screen_quake,
        .ef_homuncasting,
        .ef_hamicastle,
        .ef_hamiblood,
        .ef_hated2,
        .ef_twilight1,
        .ef_twilight2,
        .ef_twilight3,
        .ef_item_thunder,
        .ef_item_cloud,
        .ef_item_curse,
        .ef_item_zzz,
        .ef_item_rain,
        .ef_item_light,
        .ef_angel3,
        .ef_m01,
        .ef_m02,
        .ef_m03,
        .ef_m04,
        .ef_m05,
        .ef_m06,
        .ef_m07,
        .ef_kaizel,
        .ef_cloud6,
        .ef_shrink,
    ]

    func process0500To0599(context: EffectTickContext) -> Bool {
        switch effectID {
        case .ef_chemicalbody:
            if stateCnt < 31, let targetID = targetObjectID ?? ownerObjectID {
                let color = stateCnt % 2 == 0
                    ? SIMD4<Float>(0.0, 0.0, 1.0, 1.0)
                    : SIMD4<Float>(1.0, 1.0, 1.0, 1.0)
                context.world.applyTargetModifier(.tint(color: color, durationTicks: 2), to: targetID)
            }
        case .ef_castspin:
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
        case .ef_piercebody:
            if stateCnt == 0 {
                context.world.playSound(
                    named: "effect\\EF_BeginSpell.wav",
                    atWorldPosition: EffectSpace.toWorldPosition(position),
                    delay: 0
                )
            }
            if stateCnt <= 140, let targetID = targetObjectID ?? ownerObjectID {
                let color = stateCnt % 2 == 0
                    ? SIMD4<Float>(250.0 / 255.0, 250.0 / 255.0, 100.0 / 255.0, 1.0)
                    : SIMD4<Float>(1.0, 1.0, 1.0, 1.0)
                context.world.applyTargetModifier(.tint(color: color, durationTicks: 2), to: targetID)
            }
        case .ef_soullink:
            if stateCnt == 0 {
                context.world.playSound(
                    named: K2L("effect\\T_캐스팅.wav"),
                    atWorldPosition: EffectSpace.toWorldPosition(position),
                    delay: 0
                )
            }
            if stateCnt == 145 {
                context.world.playSound(
                    named: K2L("effect\\T_영혼.wav"),
                    atWorldPosition: EffectSpace.toWorldPosition(position),
                    delay: 0
                )
            }
            texturedOrbit(texturePath: "effect\\whitelight.tga", context: context)
            beginAsura2(context: context)
        case .ef_chookgi2:
            elementalOrbit(kind: 1, context: context)
        case .ef_memorize:
            if stateCnt == 0 {
                context.world.playSound(
                    named: "effect\\priest_suffragium.wav",
                    atWorldPosition: EffectSpace.toWorldPosition(position),
                    delay: 0
                )
            }
            if stateCnt >= 10 && stateCnt <= 35, let targetID = targetObjectID ?? ownerObjectID {
                let color = stateCnt % 2 == 0
                    ? SIMD4<Float>(250.0 / 255.0, 250.0 / 255.0, 100.0 / 255.0, 1.0)
                    : SIMD4<Float>(1.0, 1.0, 1.0, 1.0)
                context.world.applyTargetModifier(.tint(color: color, durationTicks: 2), to: targetID)
            }
        case .ef_soullight:
            texturedStorm2(texturePath: "effect\\whitelight.tga", kind: 0, context: context)
        case .ef_05val:
            vallentine(kind: 2, context: context)
        case .ef_beginasura11:
            beginAsura(kind: 1, context: context)
        case .ef_chemical2dash:
            for _ in 0..<4 {
                lineStreakLayered(kind: 10, context: context)
                lineStreakLayered(kind: 11, context: context)
            }
            if stateCnt == 44 {
                context.world.shakeCamera(amplitude: 1.0, duration: 0.35, frequency: 20.0)
                context.world.playSound(
                    named: K2L("effect\\연주붕격.wav"),
                    atWorldPosition: EffectSpace.toWorldPosition(position),
                    delay: 0
                )
            }
            if stateCnt >= 20 && stateCnt <= 100, let targetID = targetObjectID ?? ownerObjectID {
                context.world.applyTargetModifier(
                    .tint(color: SIMD4<Float>(1.0, 1.0, 150.0 / 255.0, 1.0), durationTicks: 2),
                    to: targetID
                )
            }
        case .ef_groundsample:
            groundSample(context: context)
        case .ef_gi_explosion:
            texturedCrossFade(texturePath: "effect\\ring_blue.tga", context: context)
        case .ef_cloud4:
            for _ in 0..<80 {
                skyCloud(kind: 3, context: context)
            }
        case .ef_cloud5:
            for _ in 0..<80 {
                skyCloud(kind: 4, context: context)
            }
        case .ef_bottom_hermode:
            texturedSpin(texturePath: "effect\\white02.bmp", context: context)
        case .ef_cartter:
            if stateCnt == 30 {
                context.world.playSound(
                    named: "effect\\wizard_fire_pillar_b.wav",
                    atWorldPosition: EffectSpace.toWorldPosition(position),
                    delay: 0
                )
            }
            for _ in 0..<4 {
                texturedTumble(texturePath: "effect\\whitelight.tga", kind: 0, context: context)
            }
        case .ef_itemfast:
            vallentine(kind: 3, context: context)
        case .ef_shieldboomerang3:
            shieldBoomerang3(texturePath: "effect\\shield_boomerang.bmp", context: context)
        case .ef_doublecastbody:
            if stateCnt >= 10 && stateCnt <= 50, let targetID = targetObjectID ?? ownerObjectID {
                let color = stateCnt % 2 == 0
                    ? SIMD4<Float>(1.0, 0.0, 0.0, 1.0)
                    : SIMD4<Float>(1.0, 1.0, 1.0, 1.0)
                context.world.applyTargetModifier(.tint(color: color, durationTicks: 2), to: targetID)
            }
        case .ef_gravitation:
            gravitation(context: context)
        case .ef_tarotcard1:
            texturedAura(texturePath: "effect\\Tarot01.tga", kind: 1, context: context)
        case .ef_tarotcard2:
            texturedAura(texturePath: "effect\\Tarot02.tga", kind: 1, context: context)
        case .ef_tarotcard3:
            texturedAura(texturePath: "effect\\Tarot03.tga", kind: 1, context: context)
        case .ef_tarotcard4:
            texturedAura(texturePath: "effect\\Tarot04.tga", kind: 1, context: context)
        case .ef_tarotcard5:
            texturedAura(texturePath: "effect\\Tarot05.tga", kind: 1, context: context)
        case .ef_tarotcard6:
            texturedAura(texturePath: "effect\\Tarot06.tga", kind: 1, context: context)
        case .ef_tarotcard7:
            texturedAura(texturePath: "effect\\Tarot07.tga", kind: 1, context: context)
        case .ef_tarotcard8:
            texturedAura(texturePath: "effect\\Tarot08.tga", kind: 1, context: context)
        case .ef_tarotcard9:
            texturedAura(texturePath: "effect\\Tarot09.tga", kind: 1, context: context)
        case .ef_tarotcard10:
            texturedAura(texturePath: "effect\\Tarot10.tga", kind: 1, context: context)
        case .ef_tarotcard11:
            texturedAura(texturePath: "effect\\Tarot11.tga", kind: 1, context: context)
        case .ef_tarotcard12:
            texturedAura(texturePath: "effect\\Tarot12.tga", kind: 1, context: context)
        case .ef_tarotcard13:
            texturedAura(texturePath: "effect\\Tarot13.tga", kind: 1, context: context)
        case .ef_tarotcard14:
            texturedAura(texturePath: "effect\\Tarot14.tga", kind: 1, context: context)
        case .ef_aciddemon:
            if stateCnt == 5 {
                context.world.shakeCamera(amplitude: 1.0, duration: 0.35, frequency: 20.0)
            }
            texturedFireWall(texturePath: "effect\\ring_black.tga", context: context)
        case .ef_greenbody:
            if stateCnt < 31, let targetID = targetObjectID ?? ownerObjectID {
                let color = stateCnt % 2 == 0
                    ? SIMD4<Float>(0.0, 1.0, 0.0, 1.0)
                    : SIMD4<Float>(1.0, 1.0, 1.0, 1.0)
                context.world.applyTargetModifier(.tint(color: color, durationTicks: 2), to: targetID)
            }
        case .ef_throwitem4:
            throwItem(texturePath: K2L("유저인터페이스\\item\\화염병.bmp"), kind: 10, context: context)
            throwItem(texturePath: K2L("유저인터페이스\\item\\염산병.bmp"), kind: 11, context: context)
        case .ef_babybody_back:
            if stateCnt <= 15, let targetID = targetObjectID ?? ownerObjectID {
                let scale = Self.shrinkPulseScale(phase: 45 - stateCnt * 3)
                context.world.applyTargetModifier(.scale(SIMD3<Float>(scale, scale, scale), durationTicks: 2), to: targetID)
            }
        case .ef_throwitem5:
            throwItem(texturePath: K2L("유저인터페이스\\item\\버서크포션.bmp"), kind: 1, context: context)
        case .ef_bluebody:
            if stateCnt <= 150, let targetID = targetObjectID ?? ownerObjectID,
               let alpha = Self.tintedOverlayAlpha(phase: stateCnt / 3) {
                context.world.applyTargetModifier(
                    .flash(color: SIMD4<Float>(5.0 / 255.0, 5.0 / 255.0, 1.0, alpha), durationTicks: 2),
                    to: targetID
                )
            }
        case .ef_hated:
            if stateCnt < 200, let targetID = targetObjectID ?? ownerObjectID {
                let phase: Int = if stateCnt <= 25 {
                    stateCnt
                } else if stateCnt <= 150 {
                    25
                } else if stateCnt <= 175 {
                    175 - stateCnt
                } else {
                    0
                }
                if let alpha = Self.tintedOverlayAlpha(phase: phase) {
                    context.world.applyTargetModifier(
                        .flash(color: SIMD4<Float>(5.0 / 255.0, 5.0 / 255.0, 1.0, alpha), durationTicks: 2),
                        to: targetID
                    )
                }
            }
            particleTime(texturePath: "effect\\white02.bmp", kind: 1, context: context)
        case .ef_redlightbody:
            if let targetID = targetObjectID ?? ownerObjectID {
                let phase = stateCnt <= 200 ? Int(Float(stateCnt) * 0.125) : 25
                if let alpha = Self.tintedOverlayAlpha(phase: phase) {
                    context.world.applyTargetModifier(
                        .flash(color: SIMD4<Float>(1.0, 5.0 / 255.0, 5.0 / 255.0, alpha), durationTicks: 2),
                        to: targetID
                    )
                }
            }
        case .ef_ro2year:
            vallentine(kind: 4, context: context)
        case .ef_sma_ready:
            particleTime(texturePath: "effect\\white02.bmp", kind: 2, context: context)
        case .ef_stin:
            if stateCnt == 10 {
                context.world.playSound(
                    named: K2L("effect\\T_바람마법.wav"),
                    atWorldPosition: EffectSpace.toWorldPosition(position),
                    delay: 0
                )
            }
            texturedSlashFan(texturePath: K2L("effect\\270바람.tga"), context: context)
        case .ef_red_hit:
            if stateCnt <= 16, let targetID = targetObjectID ?? ownerObjectID,
               let alpha = Self.tintedOverlayAlpha(phase: stateCnt * 3) {
                context.world.applyTargetModifier(
                    .flash(color: SIMD4<Float>(1.0, 5.0 / 255.0, 5.0 / 255.0, alpha), durationTicks: 2),
                    to: targetID
                )
            }
        case .ef_blue_hit:
            if stateCnt <= 16, let targetID = targetObjectID ?? ownerObjectID,
               let alpha = Self.tintedOverlayAlpha(phase: stateCnt * 3) {
                context.world.applyTargetModifier(
                    .flash(color: SIMD4<Float>(5.0 / 255.0, 5.0 / 255.0, 1.0, alpha), durationTicks: 2),
                    to: targetID
                )
            }
        case .ef_quakebody3:
            if stateCnt >= 31 && stateCnt <= 50, let targetID = targetObjectID ?? ownerObjectID {
                context.world.applyTargetModifier(.shake(amplitude: 2.0, durationTicks: 2), to: targetID)
            }
        case .ef_sma:
            sma(flag: 0, context: context)
        case .ef_sma2:
            texturedBlueRing(texturePath: "effect\\ring_blue.tga", context: context)
        case .ef_stin2:
            if stateCnt == 5 || stateCnt == 20 || stateCnt == 35 || stateCnt == 50 || stateCnt == 65 {
                context.world.playSound(
                    named: K2L("effect\\T_날라차기.wav"),
                    atWorldPosition: EffectSpace.toWorldPosition(position),
                    delay: 0
                )
            }
            texturedSlashLevel(texturePath: K2L("effect\\270바람.tga"), kind: 0, context: context)
            texturedSlashLevel(texturePath: K2L("effect\\270바람.tga"), kind: 1, context: context)
        case .ef_hittexture:
            texturedAura(texturePath: "effect\\freeze_a.bmp", kind: 2, context: context)
        case .ef_stin3:
            if stateCnt == 0 {
                context.world.playSound(
                    named: K2L("effect\\T_에너지방출.wav"),
                    atWorldPosition: EffectSpace.toWorldPosition(position),
                    delay: 0
                )
            }
            sma(flag: 1, context: context)
        case .ef_sma3:
            texturedComet(texturePath: "effect\\thunder_ball_0001.bmp", kind: 1, context: context)
        case .ef_bluefall:
            waterfallSheets(first: 0, second: 0, third: 0, context: context)
        case .ef_bluefall_90:
            waterfallSheets(first: 1, second: 0, third: 0, context: context)
        case .ef_fastbluefall:
            waterfallSheets(first: 0, second: 1, third: 0, context: context)
        case .ef_fastbluefall_90:
            waterfallSheets(first: 1, second: 1, third: 0, context: context)
        case .ef_big_portal:
            texturedMagicRing(type: 0, context: context)
        case .ef_big_portal2:
            texturedMagicRing(type: 1, context: context)
        case .ef_screen_quake:
            if stateCnt < 100 && stateCnt % 5 == 0 {
                context.world.shakeCamera(amplitude: 1.0, duration: 0.35, frequency: 20.0)
            }
        case .ef_homuncasting:
            texturedSpellRings(texturePath: "effect\\ring_red.tga", context: context)
        case .ef_hamicastle:
            texturedClassChange(kind: 0, context: context)
        case .ef_hamiblood:
            texturedClassChange(kind: 1, context: context)
        case .ef_hated2:
            if stateCnt == 10 {
                context.world.playSound(
                    named: K2L("effect\\T_따듯한마법.wav"),
                    atWorldPosition: EffectSpace.toWorldPosition(position),
                    delay: 0
                )
            }
            particleTime(texturePath: "effect\\white02.bmp", kind: 3, context: context)
        case .ef_twilight1:
            for _ in 0..<80 {
                scatterItemIcons(kind: 0, context: context)
            }
        case .ef_twilight2:
            for _ in 0..<80 {
                scatterItemIcons(kind: 1, context: context)
            }
        case .ef_twilight3:
            for _ in 0..<80 {
                scatterItemIcons(kind: 2, context: context)
            }
        case .ef_item_thunder:
            texturedClassChange(kind: 2, context: context)
        case .ef_item_cloud:
            texturedClassChange(kind: 3, context: context)
        case .ef_item_curse:
            texturedClassChange(kind: 4, context: context)
        case .ef_item_zzz:
            texturedClassChange(kind: 5, context: context)
        case .ef_item_rain:
            texturedClassChange(kind: 6, context: context)
        case .ef_item_light:
            forestLight(texturePath: "effect\\cloud11.tga", flag: 11, context: context)
        case .ef_angel3:
            superAngel(type: 11, context: context)
            superAngel(type: 10, context: context)
        case .ef_m01:
            texturedClassChange(kind: 7, context: context)
        case .ef_m02:
            if stateCnt == 5 {
                context.world.playSound(
                    named: K2L("effect\\풀버스터.wav"),
                    atWorldPosition: EffectSpace.toWorldPosition(position),
                    delay: 0
                )
            }
            texturedClassChange(kind: 8, context: context)
        case .ef_m03:
            texturedClassChange(kind: 9, context: context)
        case .ef_m04:
            texturedClassChange(kind: 10, context: context)
        case .ef_m05:
            texturedClassChange(kind: 11, context: context)
        case .ef_m06:
            texturedClassChange(kind: 12, context: context)
        case .ef_m07:
            texturedClassChange(kind: 13, context: context)
        case .ef_kaizel:
            if stateCnt == 15 {
                jobLvUp50Pair(angle: 0, context: context)
                jobLvUp50Pair(angle: 45, context: context)
            }
        case .ef_cloud6:
            for _ in 0..<80 {
                skyCloud(kind: 5, context: context)
            }
        case .ef_shrink:
            if stateCnt == 5 {
                context.world.playSound(
                    named: "effect\\EF_BeginSpell.wav",
                    atWorldPosition: EffectSpace.toWorldPosition(position),
                    delay: 0
                )
            }
            if stateCnt >= 5 && stateCnt <= 25, let targetID = targetObjectID ?? ownerObjectID {
                let color = stateCnt % 2 == 0
                    ? SIMD4<Float>(250.0 / 255.0, 250.0 / 255.0, 100.0 / 255.0, 1.0)
                    : SIMD4<Float>(1.0, 1.0, 1.0, 1.0)
                context.world.applyTargetModifier(.tint(color: color, durationTicks: 2), to: targetID)
            }
        default:
            return false
        }
        return true
    }

    // MARK: - EF_SOULLINK (503)

    /// Spawns `PP_SOULLINK` (109) orbiting soul arc that emits `EF_SOULLIGHT` child effects for `EF_SOULLINK` (503).
    func texturedOrbit(texturePath: String, context: EffectTickContext) {
        guard stateCnt == 0 else {
            return
        }

        _ = context.assets?.texture(atPath: texturePath)

        let primitive = launchPrimitive(.pp_soullink)
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
        primitive.state.slots[0].targetObjectID = targetObjectID ?? ownerObjectID
        primitive.state.slots[0].height[13] = 0
        primitive.state.slots[0].height[14] = 0
        primitive.state.slots[0].height[15] = 0
        for h in 0..<4 {
            primitive.state.slots[0].height[h] = Float(Int.random(in: 0..<360))
        }
        primitive.state.slots[0].vecTNow.x = 0
        primitive.state.slots[0].vecBPre = SIMD3<Float>(
            -EffectSpace.sine(degrees: 90) * 30.0,
            -(EffectSpace.sine(degrees: 0) * 20.0) - 40.0,
            0
        )
    }

    /// Spawns two 4-letter `PP_ASURACASTING` (68) banners (`SOUL` / `LINK`) on ticks 1 and 21 for `EF_SOULLINK` (503).
    func beginAsura2(context: EffectTickContext) {
        if stateCnt == 1 {
            let textures = [
                "effect\\soul_l.tga",
                "effect\\soul_u.tga",
                "effect\\soul_o.tga",
                "effect\\soul_s.tga",
            ]
            for path in textures {
                _ = context.assets?.texture(atPath: path)
            }

            let primitive = launchPrimitive(.pp_asuracasting)
            primitive.state.renderFlag = EffectPrimitiveState.RenderFlag.alpha | EffectPrimitiveState.RenderFlag.customBlend
            primitive.state.duration = duration
            primitive.state.totalTexture = 4
            primitive.state.texturePaths = textures
            primitive.state.size = 0

            for index in 0..<4 {
                primitive.state.slots[index].life = 1
                primitive.state.slots[index].process = index * 20 - 60
                primitive.state.slots[index].distance = 5.0
                primitive.state.slots[index].alphaB = 0
                primitive.state.slots[index].height[0] = Float(-4 - index * 6)
                primitive.state.slots[index].flag1[0] = Int8(index)
                primitive.state.slots[index].flag1[4] = 2
                for h in 1..<11 {
                    primitive.state.slots[index].height[h] = 0
                }
            }
        }

        if stateCnt == 21 {
            let textures = [
                "effect\\soul_k.tga",
                "effect\\soul_n.tga",
                "effect\\soul_i.tga",
                "effect\\soul_l.tga",
            ]
            for path in textures {
                _ = context.assets?.texture(atPath: path)
            }

            let primitive = launchPrimitive(.pp_asuracasting)
            primitive.state.renderFlag = EffectPrimitiveState.RenderFlag.alpha | EffectPrimitiveState.RenderFlag.customBlend
            primitive.state.duration = duration
            primitive.state.totalTexture = 4
            primitive.state.texturePaths = textures
            primitive.state.size = 0

            for index in 0..<4 {
                primitive.state.slots[index].life = 1
                primitive.state.slots[index].process = index * 20 - 120
                primitive.state.slots[index].distance = 5.0
                primitive.state.slots[index].alphaB = 0
                primitive.state.slots[index].height[0] = Float(22 - index * 6)
                primitive.state.slots[index].flag1[0] = Int8(index)
                primitive.state.slots[index].flag1[4] = 2
                for h in 1..<11 {
                    primitive.state.slots[index].height[h] = 0
                }
            }
        }
    }

    // MARK: - EF_SOULLIGHT (506)

    /// Spawns `PP_SOULPARTICLE` (111) drifting 3-point soul motes for `EF_SOULLIGHT` (506).
    func texturedStorm2(texturePath: String, kind: Int8, context: EffectTickContext) {
        guard stateCnt == 0 else {
            return
        }

        _ = context.assets?.texture(atPath: texturePath)

        let primitive = launchPrimitive(.pp_soulparticle)
        primitive.state.renderFlag = EffectPrimitiveState.RenderFlag.alpha | EffectPrimitiveState.RenderFlag.customBlend
        primitive.state.duration = duration
        primitive.state.totalTexture = 1
        primitive.state.texturePaths = [texturePath]
        primitive.state.size = 0

        for i in 0..<4 {
            primitive.state.slots[i].life = 0
        }

        for i in 0..<2 {
            primitive.state.slots[i].life = 1
            primitive.state.slots[i].maxHeight = 0.07
            primitive.state.slots[i].distance = Float(Int.random(in: 0..<11)) * 0.1 + 1.0
            primitive.state.slots[i].process = 0
            primitive.state.slots[i].vecBPre = deltaPos
            primitive.state.slots[i].vecBNow = deltaPos
            primitive.state.slots[i].vecTPre = deltaPos
            for h in 0..<12 {
                primitive.state.slots[i].height[h] = Float(Int.random(in: 0..<360))
            }
            primitive.state.slots[i].height[12] = 0
            primitive.state.slots[i].height[13] = 0
            primitive.state.slots[i].height[14] = 0
            if kind == 2 {
                primitive.state.slots[i].height[15] = 4.0
            } else if kind == 3 {
                primitive.state.slots[i].height[15] = Float(Int.random(in: 0..<3) + 1)
            } else {
                primitive.state.slots[i].height[15] = 0
            }
        }
    }

    // MARK: - EF_GROUNDSAMPLE (513)

    /// Spawns primitive `112` terrain-conformed magic target grid for `EF_GROUNDSAMPLE` (513).
    func groundSample(context: EffectTickContext) {
        guard stateCnt == 0 else {
            return
        }

        let texturePath = "effect\\magic_target.tga"
        _ = context.assets?.texture(atPath: texturePath)

        let primitive = launchPrimitive(112)
        primitive.state.renderFlag = EffectPrimitiveState.RenderFlag.alpha | EffectPrimitiveState.RenderFlag.customBlend
        primitive.state.duration = duration
        primitive.state.totalTexture = 1
        primitive.state.texturePaths = [texturePath]
        for i in 0..<4 {
            primitive.state.slots[i].life = 0
        }
        primitive.state.slots[0].life = 1
        primitive.state.slots[0].rotStart = 0
    }

    // MARK: - EF_GI_EXPLOSION (514)

    /// Spawns `113` (`PP_GI_EXPLOSION`) expanding blue casting rings for `EF_GI_EXPLOSION` (514).
    func texturedCrossFade(texturePath: String, context: EffectTickContext) {
        guard stateCnt == 0 else {
            return
        }

        _ = context.assets?.texture(atPath: texturePath)

        let primitive = launchPrimitive(113)
        primitive.state.renderFlag = EffectPrimitiveState.RenderFlag.alpha | EffectPrimitiveState.RenderFlag.customBlend
        primitive.state.duration = duration
        primitive.state.totalTexture = 1
        primitive.state.texturePaths = [texturePath]
        primitive.state.size = 4.0

        for index in 0..<4 {
            primitive.state.slots[index].life = 1
            primitive.state.slots[index].process = 0
            primitive.state.slots[index].fullDisplayAngle = 315
            primitive.state.slots[index].maxHeight = 15.0
            primitive.state.slots[index].rotStart = Int16(Int.random(in: 0..<360))
            primitive.state.slots[index].alphaB = 0
            primitive.state.slots[index].distance = 20.0 - Float(index) * 0.5
            primitive.state.slots[index].riseAngle = 50
            primitive.state.slots[index].vecBNow.y = 0
            primitive.state.slots[index].height = Array(repeating: 0, count: 21)
            primitive.state.slots[index].flag1 = Array(repeating: 0, count: 21)
        }
    }

    // MARK: - EF_BOTTOM_HERMODE (517)

    /// Spawns `PP_HERMODE` (114) rotating ground wand aura for `EF_BOTTOM_HERMODE` (517).
    func texturedSpin(texturePath: String, context: EffectTickContext) {
        guard stateCnt == 0 else {
            return
        }

        _ = context.assets?.texture(atPath: texturePath)

        let primitive = launchPrimitive(.pp_hermode)
        primitive.state.renderFlag = EffectPrimitiveState.RenderFlag.alpha | EffectPrimitiveState.RenderFlag.customBlend
        primitive.state.duration = duration
        primitive.state.totalTexture = 1
        primitive.state.texturePaths = [texturePath]
        primitive.state.size = 5.0
        for i in 1..<4 {
            primitive.state.slots[i].life = 0
        }
        primitive.state.slots[0].life = 1
        primitive.state.slots[0].distance = 1.6
        primitive.state.slots[0].riseAngle = Int16(Int.random(in: 0..<360))
        primitive.state.slots[0].rotStart = Int16(Int.random(in: 0..<360))
        primitive.state.slots[0].alphaB = 0
        primitive.state.slots[0].height[0] = -12.0
        primitive.state.slots[0].flag1[0] = Int8(Int.random(in: 0..<31))
    }

    // MARK: - EF_CARTTER (518)

    /// Spawns spherical particle spread (`115`) on tick 30 for `EF_CARTTER` (518).
    func texturedTumble(texturePath: String, kind: Int8, context: EffectTickContext) {
        guard stateCnt == 30 else {
            return
        }

        _ = context.assets?.texture(atPath: texturePath)

        let primitive = launchPrimitive(115)
        primitive.state.renderFlag = EffectPrimitiveState.RenderFlag.alpha | EffectPrimitiveState.RenderFlag.customBlend
        primitive.state.duration = duration
        primitive.state.totalTexture = 1
        primitive.state.texturePaths = [texturePath]
        primitive.state.size = 0

        for slot in 0..<4 {
            primitive.state.slots[slot].life = 1
            primitive.state.slots[slot].maxHeight = 1.0
            primitive.state.slots[slot].distance = Float(Int.random(in: 0..<6)) * 0.1 + 2.5
            primitive.state.slots[slot].process = 0
            primitive.state.slots[slot].vecBPre = .zero
            primitive.state.slots[slot].height[0] = Float(Int.random(in: 0..<360))
            primitive.state.slots[slot].height[2] = Float(Int.random(in: 0..<180))
            primitive.state.slots[slot].height[12] = 230.0
            primitive.state.slots[slot].vecBNow = .zero
            primitive.state.slots[slot].height[4] = Float(Int.random(in: 0..<360))
            primitive.state.slots[slot].height[6] = Float(Int.random(in: 0..<180))
            primitive.state.slots[slot].height[13] = 230.0
            primitive.state.slots[slot].vecTPre = .zero
            primitive.state.slots[slot].height[8] = Float(Int.random(in: 0..<360))
            primitive.state.slots[slot].height[10] = Float(Int.random(in: 0..<180))
            primitive.state.slots[slot].height[14] = 230.0
            primitive.state.slots[slot].height[15] = Float(Int.random(in: 0..<3) + 1)
        }
    }

    // MARK: - EF_SHIELDBOOMERANG3 (520)

    /// Spawns spinning shield projectiles (`PP_SHIELDBOOMERANG3` (116)) on ticks 0, 3, 6, 9, 12 for `EF_SHIELDBOOMERANG3` (520).
    func shieldBoomerang3(texturePath: String, context: EffectTickContext) {
        if stateCnt == 0 {
            context.world.playSound(
                named: "effect\\cru_shield boomerang.wav",
                atWorldPosition: EffectSpace.toWorldPosition(position),
                delay: 0
            )
        } else if stateCnt != 3 && stateCnt != 6 && stateCnt != 9 && stateCnt != 12 {
            return
        }

        _ = context.assets?.texture(atPath: texturePath)

        let primitive = launchPrimitive(.pp_shieldboomerang3)
        primitive.state.renderFlag = EffectPrimitiveState.RenderFlag.alpha | EffectPrimitiveState.RenderFlag.customBlend
        primitive.state.duration = duration
        primitive.state.totalTexture = 1
        primitive.state.texturePaths = [texturePath]
        primitive.state.size = 0

        let heading = Int16(Int.random(in: 0..<360))
        let speed: Float = 2.5
        primitive.state.slots[0].life = 1
        primitive.state.slots[0].process = 0
        primitive.state.slots[0].vecBNow = SIMD3<Float>(
            position.x - speed * 15.0 * EffectSpace.cosine(degrees: Int(heading)),
            position.y - 8.0,
            position.z - speed * 15.0 * EffectSpace.sine(degrees: Int(heading))
        )
        primitive.state.slots[0].distance = 5.0
        primitive.state.slots[0].height[8] = 0
        primitive.state.slots[0].alphaB = 25
        primitive.state.slots[0].rotStart = heading
        primitive.state.slots[0].height[1] = speed
        primitive.state.slots[0].fullDisplayAngle = 0
        primitive.state.slots[0].flag1[0] = 0
        primitive.state.slots[0].flag1[2] = 0

        for i in 1..<4 {
            primitive.state.slots[i].life = 1
            primitive.state.slots[i].alphaB = 0
        }
    }

    // MARK: - EF_GRAVITATION (522)

    /// Spawns a 5x5 grid of 4 stone/ice pyramids (`PP_3DQUADHORN2` (117)) and camera quake for `EF_GRAVITATION` (522).
    func gravitation(context: EffectTickContext) {
        guard stateCnt == 0 else {
            return
        }

        context.world.shakeCamera(amplitude: 1.0, duration: 0.35, frequency: 20.0)

        let stoneTex = "effect\\stone.bmp"
        let iceTex = "effect\\ice.tga"
        _ = context.assets?.texture(atPath: stoneTex)
        _ = context.assets?.texture(atPath: iceTex)

        for z in stride(from: -10, to: 15, by: 5) {
            for x in stride(from: -10, to: 15, by: 5) {
                for i in 0..<4 {
                    let spike = launchPrimitive(.pp_3dquadhorn2)
                    spike.state.pattern = 1
                    spike.state.deltaPos2 = SIMD3<Float>(Float(x), 10.0, Float(z))
                    spike.state.duration = 250
                    spike.state.size = Float(Int.random(in: 0..<50) + 300) / 100.0
                    spike.state.heightSize = 18.0
                    spike.state.longitude = Float(Int.random(in: 0..<360))
                    spike.state.latitude = Float(Int.random(in: 0..<40) + 60)
                    let rotX = EffectSpace.rotationX(radians: EffectSpace.radian(degrees: Int(spike.state.latitude)))
                    let rotY = EffectSpace.rotationY(radians: EffectSpace.radian(degrees: Int(spike.state.longitude)))
                    spike.state.transform = rotY * rotX
                    spike.state.rotTransform = spike.state.transform
                    spike.state.speed = 1.0
                    spike.state.accel = 0.01
                    spike.state.alpha = 20.0
                    spike.state.chCnt = 15
                    spike.state.changePoint = 12
                    spike.state.changeSpeed = -1.2
                    spike.state.changeAccel = 0
                    spike.state.fadeOutCnt = spike.state.duration - 10
                    spike.state.texturePaths = [i < 2 ? stoneTex : iceTex]
                }
            }
        }
    }

    // MARK: - EF_ACIDDEMON (537)

    /// Spawns 4-layer magenta acid demonstration cylinder (`PP_ACIDDEMON` (118)) for `EF_ACIDDEMON` (537).
    func texturedFireWall(texturePath: String, context: EffectTickContext) {
        guard stateCnt == 0 else {
            return
        }

        context.world.playSound(
            named: "effect\\EF_FireWall.wav",
            atWorldPosition: EffectSpace.toWorldPosition(position),
            delay: 0
        )

        _ = context.assets?.texture(atPath: texturePath)

        let primitive = launchPrimitive(.pp_aciddemon)
        primitive.state.renderFlag = EffectPrimitiveState.RenderFlag.alpha | EffectPrimitiveState.RenderFlag.customBlend
        primitive.state.duration = duration
        primitive.state.totalTexture = 1
        primitive.state.texturePaths = [texturePath]
        primitive.state.size = 13.0

        let configs: [(fullAngle: Int16, maxHeight: Float, rotStart: Int16, distance: Float, riseAngle: Int16)] = [
            (315, 25.0, 0, 2.4, 70),
            (315, 22.0, 90, 2.7, 57),
            (315, 19.0, 180, 3.0, 45),
            (360, 30.0, 0, 2.2, 90),
        ]

        for (index, config) in configs.enumerated() {
            primitive.state.slots[index].life = 1
            primitive.state.slots[index].process = 0
            primitive.state.slots[index].fullDisplayAngle = config.fullAngle
            primitive.state.slots[index].maxHeight = config.maxHeight
            primitive.state.slots[index].rotStart = config.rotStart
            primitive.state.slots[index].alphaB = 0
            primitive.state.slots[index].distance = config.distance
            primitive.state.slots[index].riseAngle = config.riseAngle
            primitive.state.slots[index].vecBNow.y = 0
            primitive.state.slots[index].height = Array(repeating: 0, count: 21)
            primitive.state.slots[index].flag1 = Array(repeating: 0, count: 21)
        }
    }

    // MARK: - EF_HATED (543)

    /// Emits rising spark motes (`PP_PARTICLE_UP` (59)) every 4 ticks for `EF_HATED` (543), `EF_SMA_READY` (546), and `EF_HATED2` (572).
    func particleTime(texturePath: String, kind: Int8, context: EffectTickContext) {
        let minCount = kind != 2 ? 0 : 40
        let maxCount = kind != 2 ? 80 : 120
        guard stateCnt >= minCount, stateCnt <= maxCount, stateCnt % 4 == 0 else {
            return
        }

        let textures = ["effect\\pok1.tga", "effect\\pok3.tga"]
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

        for i in 0..<4 {
            primitive.state.slots[i].life = 1
            primitive.state.slots[i].process = 0
            primitive.state.slots[i].distance = Float(Int.random(in: 0..<10)) * 0.1 + 2.0
            primitive.state.slots[i].height[8] = 0
            primitive.state.slots[i].alphaB = 0
            primitive.state.slots[i].vecBNow = SIMD3<Float>(
                Float(Int.random(in: 0..<11)) + position.x - 5.0,
                position.y - 6.0,
                Float(Int.random(in: 0..<11)) + position.z - 5.0
            )
            primitive.state.slots[i].rotStart = 0
            primitive.state.slots[i].height[1] = 0
            primitive.state.slots[i].height[2] = Float(Int.random(in: 0..<20)) * 0.01 + 0.1
            primitive.state.slots[i].fullDisplayAngle = 0
            primitive.state.slots[i].flag1[0] = 0
            primitive.state.slots[i].flag1[1] = 1
            primitive.state.slots[i].flag1[2] = colorStyle
            primitive.state.slots[i].height[7] = 0
        }
    }

    // MARK: - EF_STIN (547)

    /// Spawns 4-slot wind slash wave (`119`) for `EF_STIN` (547).
    func texturedSlashFan(texturePath: String, context: EffectTickContext) {
        guard stateCnt == 0 else {
            return
        }

        _ = context.assets?.texture(atPath: texturePath)

        let primitive = launchPrimitive(119)
        primitive.state.renderFlag = EffectPrimitiveState.RenderFlag.alpha | EffectPrimitiveState.RenderFlag.customBlend
        primitive.state.duration = duration
        primitive.state.totalTexture = 1
        primitive.state.texturePaths = [texturePath]
        primitive.state.size = 0
        primitive.state.deltaPos = deltaPos
        primitive.position = position

        for index in 0..<4 {
            primitive.state.slots[index].life = 1
            primitive.state.slots[index].process = index - 3
            primitive.state.slots[index].distance = 20.0
            primitive.state.slots[index].alphaB = 0
            primitive.state.slots[index].vecBNow = SIMD3<Float>(
                position.x,
                Float(Int.random(in: 0..<5)) + (position.y - 10.0),
                position.z
            )
            primitive.state.slots[index].rotStart = 0
            primitive.state.slots[index].riseAngle = Int16(index)
            primitive.state.slots[index].height[1] = 0.8
            primitive.state.slots[index].flag1[0] = 0
            primitive.state.slots[index].flag1[3] = 0
        }
    }

    // MARK: - EF_SMA (551)

    /// Spawns traveling child-effect emitter (`PP_SMA` (120)) for `EF_SMA` (551) and `EF_STIN3` (555).
    func sma(flag: Int8, context: EffectTickContext) {
        guard stateCnt == 0 else {
            return
        }

        let primitive = launchPrimitive(.pp_sma)
        primitive.state.duration = duration
        primitive.state.totalTexture = 0
        primitive.state.size = 0
        primitive.state.deltaPos = deltaPos
        primitive.position = position

        for i in 0..<4 {
            primitive.state.slots[i].life = 1
            primitive.state.slots[i].process = i - 3
            primitive.state.slots[i].alphaB = 0
            primitive.state.slots[i].vecBNow = SIMD3<Float>(
                position.x,
                (position.y - 10.0) + Float(Int.random(in: 0..<5)),
                position.z
            )
            primitive.state.slots[i].rotStart = 0
            primitive.state.slots[i].height[1] = 0.8
            primitive.state.slots[i].flag1[0] = flag
            primitive.state.slots[i].targetObjectID = targetObjectID ?? ownerObjectID
        }
    }

    // MARK: - EF_SMA2 (552)

    /// Spawns rising blue energy pillar cylinder (`PP_SMA2` (121)) for `EF_SMA2` (552).
    func texturedBlueRing(texturePath: String, context: EffectTickContext) {
        guard stateCnt == 0 else {
            return
        }

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
        let configs: [(maxHeight: Float, rotStart: Int16, distance: Float, riseAngle: Int16)] = [
            (13.0, 0, isWide ? 3.4 : 2.4, 55),
            (11.0, 90, isWide ? 3.6 : 2.6, 50),
            (9.0, 180, isWide ? 3.8 : 2.8, 45),
        ]

        for (index, config) in configs.enumerated() {
            primitive.state.slots[index].life = 1
            primitive.state.slots[index].process = 0
            primitive.state.slots[index].fullDisplayAngle = 315
            primitive.state.slots[index].maxHeight = config.maxHeight
            primitive.state.slots[index].rotStart = config.rotStart
            primitive.state.slots[index].alphaB = 0
            primitive.state.slots[index].distance = config.distance
            primitive.state.slots[index].riseAngle = config.riseAngle
            primitive.state.slots[index].vecBNow.y = 0
        }
        primitive.state.slots[3].life = 0

        for i in 0..<4 {
            primitive.state.slots[i].height = Array(repeating: 0, count: 21)
            primitive.state.slots[i].flag1 = Array(repeating: 0, count: 21)
        }
    }

    // MARK: - EF_STIN2 (553)

    /// Spawns multi-wave wind slash panels (`122`) for `EF_STIN2` (553).
    func texturedSlashLevel(texturePath: String, kind: Int8, context: EffectTickContext) {
        guard stateCnt == 0 else {
            return
        }

        _ = context.assets?.texture(atPath: texturePath)

        let primitive = launchPrimitive(122)
        primitive.state.renderFlag = EffectPrimitiveState.RenderFlag.alpha | EffectPrimitiveState.RenderFlag.customBlend
        primitive.state.duration = duration
        primitive.state.totalTexture = 1
        primitive.state.texturePaths = [texturePath]
        primitive.state.size = 0
        primitive.state.deltaPos = deltaPos
        primitive.position = position

        for index in 0..<4 {
            primitive.state.slots[index].life = 1
            primitive.state.slots[index].process = 0

            if kind == 4 || kind == 5 {
                primitive.state.slots[index].distance = 25.0
                primitive.state.slots[index].flag1[3] = 3
            } else if kind > 1 {
                primitive.state.slots[index].distance = 6.0
                primitive.state.slots[index].flag1[3] = 2
            } else {
                primitive.state.slots[index].distance = 25.0
                primitive.state.slots[index].flag1[3] = 0
            }

            primitive.state.slots[index].alphaB = 0
            primitive.state.slots[index].vecBNow = SIMD3<Float>(position.x, position.y - 10.0, position.z)
            primitive.state.slots[index].rotStart = 0
            primitive.state.slots[index].riseAngle = Int16(index)
            primitive.state.slots[index].height[1] = 2.0
            primitive.state.slots[index].flag1[0] = 0
            primitive.state.slots[index].flag1[1] = 0

            if kind == 0 || kind == 2 || kind == 4 {
                primitive.state.slots[index].flag1[2] = 0
            } else if kind == 1 || kind == 3 || kind == 5 {
                primitive.state.slots[index].flag1[2] = 1
            }

            primitive.state.slots[index].flag1[4] = (kind == 2 || kind == 3) ? 1 : 0
        }
    }

    // MARK: - EF_SMA3 (556)

    /// Spawns rising comet/spark motes (`PP_PARTICLE_UP` (59)) at `deltaPos` for `EF_SMA3` (556).
    func texturedComet(texturePath: String, kind: Int8, context: EffectTickContext) {
        guard stateCnt == 0 else {
            return
        }

        let textures: [String] = switch kind {
        case 1:
            ["effect\\thunder_ball_0002.bmp", "effect\\thunder_ball_0003.bmp"]
        case 2:
            ["effect\\meteo_comet_b.bmp", "effect\\meteo_comet_c.bmp"]
        default:
            ["effect\\pok1.tga", "effect\\pok3.tga"]
        }
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
        case 1: 1
        case 2: 7
        default: 0
        }

        for index in 0..<4 {
            primitive.state.slots[index].life = 1
            primitive.state.slots[index].process = 0
            primitive.state.slots[index].distance = Float(Int.random(in: 0..<10)) * 0.08 + 1.2
            primitive.state.slots[index].height[8] = 0
            primitive.state.slots[index].alphaB = 0
            primitive.state.slots[index].vecBNow = SIMD3<Float>(
                Float(Int.random(in: 0..<9)) + deltaPos.x - 4.0,
                deltaPos.y - 6.0,
                Float(Int.random(in: 0..<9)) + deltaPos.z - 4.0
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

    // MARK: - EF_BLUEFALL (557)

    /// Spawns 4-layer scrolling waterfall sheets (`79`) for `EF_BLUEFALL` (557) and orientation/speed variants.
    func waterfallSheets(first: Int8, second: Int8, third: Int8, context: EffectTickContext) {
        guard stateCnt == 0 else {
            return
        }

        let textures: [String] = switch third {
        case 0:
            ["effect\\waterfall11.tga", "effect\\waterfall12.tga", "effect\\waterfall13.tga"]
        case 1:
            ["effect\\waterfall31.tga", "effect\\waterfall32.tga", "effect\\waterfall33.tga"]
        case 10:
            ["effect\\alpha_down.tga", "effect\\alpha_down.tga", "effect\\alpha_down.tga"]
        default:
            ["effect\\waterfall11.tga", "effect\\waterfall12.tga", "effect\\waterfall13.tga"]
        }
        for path in textures {
            _ = context.assets?.texture(atPath: path)
        }

        let primitive = launchPrimitive(79)
        primitive.state.renderFlag = EffectPrimitiveState.RenderFlag.alpha | EffectPrimitiveState.RenderFlag.customBlend
        primitive.state.duration = duration
        primitive.state.totalTexture = 3
        primitive.state.texturePaths = textures

        for index in 0..<4 {
            primitive.state.slots[index].life = 1
            primitive.state.slots[index].process = 0
            primitive.state.slots[index].alphaB = 120
            primitive.state.slots[index].flag1[0] = first
            primitive.state.slots[index].distance = Float(36 + index)
            primitive.state.slots[index].flag1[2] = 10
            for h in 0..<20 {
                primitive.state.slots[index].height[h] = Float(h * 40)
            }
            primitive.state.slots[index].vecBNow.z = Float(index) * 0.25 - 1.0

            if second == 0 {
                primitive.state.slots[index].maxHeight = Float(80 - index * 13)
            } else if second == 1 {
                primitive.state.slots[index].maxHeight = Float(30 - index * 6)
            } else if second == 10 {
                primitive.state.slots[index].maxHeight = 0
                primitive.state.slots[index].alphaB = 70
            }

            primitive.state.slots[index].flag1[1] = second == 10 ? 10 : 1
        }
    }

    // MARK: - EF_BIG_PORTAL (561)

    /// Spawns large portal column (`60`) on tick 0 and wind vortex (`PP_WIND` (62)) on tick 2 for `EF_BIG_PORTAL` (561) and `EF_BIG_PORTAL2` (562).
    func texturedMagicRing(type: Int8, context: EffectTickContext) {
        if stateCnt == 0 {
            let texturePath = type == 3 ? "effect\\ring_red.tga" : "effect\\magic_violet.tga"
            _ = context.assets?.texture(atPath: texturePath)

            let primitive = launchPrimitive(60)
            primitive.state.renderFlag = EffectPrimitiveState.RenderFlag.alpha | EffectPrimitiveState.RenderFlag.customBlend
            primitive.state.duration = duration
            primitive.state.totalTexture = 1
            primitive.state.texturePaths = [texturePath]
            primitive.state.size = type == 3 ? 10.0 : 4.0

            let distances: [Float] = [7.0, 5.5, 4.0]
            let alphaT: Int16 = type == 1 ? -1 : 1400
            for (index, distance) in distances.enumerated() {
                primitive.state.slots[index].life = 1
                primitive.state.slots[index].process = 0
                primitive.state.slots[index].fullDisplayAngle = 360
                primitive.state.slots[index].maxHeight = 80.0
                primitive.state.slots[index].rotStart = Int16(Int.random(in: 0..<360))
                primitive.state.slots[index].alphaB = 0
                primitive.state.slots[index].distance = distance
                primitive.state.slots[index].riseAngle = 90
                primitive.state.slots[index].alphaT = alphaT
                primitive.state.slots[index].vecBNow.y = 0
                primitive.state.slots[index].height = Array(repeating: 0, count: 21)
                primitive.state.slots[index].flag1 = Array(repeating: 3, count: 21)
            }
            primitive.state.slots[3].life = 0
        }

        if stateCnt == 2 {
            let texturePath = "effect\\cloud11.tga"
            _ = context.assets?.texture(atPath: texturePath)

            let primitive = launchPrimitive(.pp_wind)
            primitive.state.renderFlag = EffectPrimitiveState.RenderFlag.alpha | EffectPrimitiveState.RenderFlag.customBlend
            primitive.state.duration = duration
            primitive.state.totalTexture = 1
            primitive.state.texturePaths = [texturePath]
            primitive.state.size = type == 3 ? 10.0 : 4.0

            let configs: [(maxHeight: Float, rotStart: Int16, distance: Float)] = [
                (2.5, 0, 13.0),
                (5.0, 90, 11.0),
                (7.5, 180, 9.0),
                (10.0, 270, 8.0),
            ]
            for (index, config) in configs.enumerated() {
                primitive.state.slots[index].life = 1
                primitive.state.slots[index].process = 0
                primitive.state.slots[index].fullDisplayAngle = 30
                primitive.state.slots[index].maxHeight = config.maxHeight
                primitive.state.slots[index].rotStart = config.rotStart
                primitive.state.slots[index].alphaB = 0
                primitive.state.slots[index].distance = config.distance
                primitive.state.slots[index].riseAngle = 90
                primitive.state.slots[index].alphaT = 3
                primitive.state.slots[index].height = Array(repeating: 1.5, count: 21)
                primitive.state.slots[index].flag1 = Array(repeating: 0, count: 21)
            }
        }
    }

    // MARK: - EF_HAMICASTLE (570)

    /// Spawns a single ACT/SPR particle (`PP_3DPARTICLE` (5)) for class-change, item, trap, elemental, and magic-circle variants.
    func texturedClassChange(kind: Int8, context: EffectTickContext) {
        let stage = kind != 30 ? 0 : 30
        if stateCnt == 99_999_998 {
            stateCnt = 0
        }
        guard stateCnt == stage else {
            return
        }

        let primitive = launchPrimitive(.pp_3dparticle)
        primitive.state.duration = duration
        primitive.state.deltaPos2.y = 0
        primitive.state.renderFlag |= EffectPrimitiveState.RenderFlag.noDepth
        primitive.state.pattern |= 0x200
        primitive.state.animSpeed = 2
        primitive.state.repeatAnim = false
        primitive.state.alphaSpeed = 0

        func assignSprite(_ spriteBase: String, folder: String = "이팩트") {
            let spritePath = K2L("\(folder)\\\(spriteBase).spr")
            let actionPath = K2L("\(folder)\\\(spriteBase).act")
            _ = context.assets?.spriteAsset(spritePath: spritePath, actionPath: actionPath)
            primitive.state.spritePath = spritePath
            primitive.state.actionPath = actionPath
        }

        func setAction(_ action: Int) {
            primitive.previousAnimation = action
            primitive.currentMotion = 0
        }

        func cameraRelativeAngle() -> Int {
            let raw = Int(EffectPrimitive.angle(dx: position.x - deltaPos.x, dy: position.z - deltaPos.z))
            var angle = (Int(context.world.cameraYawDegrees) + raw) % 360
            if angle < 0 {
                angle += 360
            }
            return angle
        }

        let alphaCustom = EffectPrimitiveState.RenderFlag.alpha | EffectPrimitiveState.RenderFlag.customBlend
        let topmostFlags = alphaCustom | EffectPrimitiveState.RenderFlag.topmost

        switch kind {
        case 0:
            assignSprite("캐슬링")
        case 1:
            context.world.playSound(named: "effect\\h_blood_lust.wav", atWorldPosition: EffectSpace.toWorldPosition(position), delay: 0)
            assignSprite("블러드러스트")
        case 2:
            assignSprite("item_thunder")
        case 3:
            assignSprite("item_cloud")
        case 4:
            assignSprite("item_curse")
        case 5:
            assignSprite("item_zzz")
        case 6:
            assignSprite("item_rain")
        case 7:
            context.world.playSound(named: "effect\\ef_firehit.wav", atWorldPosition: EffectSpace.toWorldPosition(position), delay: 0)
            primitive.state.animSpeed = 3
            primitive.state.pattern = 0
            primitive.state.alpha = 220.0
            assignSprite("m_ef01")
        case 8:
            primitive.state.animSpeed = 4
            assignSprite("m_ef02")
            let angle = cameraRelativeAngle()
            if angle >= 180 && angle < 270 {
                setAction(2)
            } else if angle >= 90 && angle < 180 {
                setAction(3)
            } else if angle >= 0 && angle < 90 {
                setAction(0)
            } else {
                setAction(1)
            }
        case 9:
            primitive.state.animSpeed = 4
            assignSprite("m_ef03")
        case 10:
            primitive.state.animSpeed = 4
            assignSprite("m_ef04")
            primitive.state.repeatAnim = true
        case 11:
            primitive.state.animSpeed = 4
            assignSprite("m_ef05")
        case 12:
            primitive.state.animSpeed = 4
            assignSprite("m_ef06")
        case 13:
            primitive.state.animSpeed = 4
            assignSprite("m_ef07")
        case 14:
            assignSprite("합격_")
        case 15:
            primitive.state.animSpeed = 4
            assignSprite("그림자베기")
            setAction(Int.random(in: 0..<2) == 0 ? 4 : 0)
        case 16:
            primitive.state.deltaPos2.y = -6.0
            primitive.state.renderFlag = EffectPrimitiveState.RenderFlag.alpha
            primitive.state.animSpeed = 6
            assignSprite("다다미")
            setAction(0)
        case 17:
            primitive.state.animSpeed = 4
            assignSprite("안개베기")
            setAction(Int.random(in: 0..<2) == 0 ? 2 : 0)
        case 18:
            primitive.state.deltaPos2.y = -6.0
            primitive.state.animSpeed = 2
            assignSprite("일섬")
            setAction(0)
        case 19:
            primitive.state.deltaPos2.y = -1.0
            primitive.state.renderFlag = EffectPrimitiveState.RenderFlag.alpha
            primitive.state.animSpeed = Int.random(in: 0..<5) + 3
            primitive.state.repeatAnim = true
            assignSprite("화염진")
            setAction(0)
        case 20:
            primitive.state.animSpeed = 4
            assignSprite("데스페라도")
            setAction(0)
        case 21:
            primitive.state.deltaPos2.y = -1.0
            primitive.state.renderFlag = EffectPrimitiveState.RenderFlag.alpha
            primitive.state.repeatAnim = true
            assignSprite("라이트닝스피어")
            setAction(0)
        case 22:
            primitive.state.deltaPos2.y = -1.0
            primitive.state.renderFlag = EffectPrimitiveState.RenderFlag.alpha
            primitive.state.repeatAnim = true
            assignSprite("블라인드스피어")
            setAction(0)
        case 23:
            primitive.state.deltaPos2.y = -1.0
            primitive.state.renderFlag = EffectPrimitiveState.RenderFlag.alpha
            primitive.state.repeatAnim = true
            assignSprite("포이즌스피어")
            setAction(0)
        case 24:
            primitive.state.deltaPos2.y = -1.0
            primitive.state.renderFlag = EffectPrimitiveState.RenderFlag.alpha
            primitive.state.repeatAnim = true
            assignSprite("프리징스피어")
            setAction(0)
        case 25:
            primitive.state.deltaPos2.y = -1.0
            primitive.state.renderFlag = EffectPrimitiveState.RenderFlag.alpha
            primitive.state.repeatAnim = true
            assignSprite("플레어스피어")
            setAction(0)
        case 26:
            primitive.state.animSpeed = 4
            assignSprite("래피드샤워")
            setAction(0)
        case 27:
            primitive.state.animSpeed = 2
            assignSprite("매지컬불릿")
            setAction(0)
        case 28:
            primitive.state.animSpeed = 4
            assignSprite("스프레드")
            let angle = cameraRelativeAngle()
            if angle >= 180 && angle < 270 {
                setAction(4)
            } else if angle >= 90 && angle < 180 {
                setAction(6)
            } else if angle >= 0 && angle < 90 {
                setAction(0)
            } else {
                setAction(2)
            }
        case 29:
            primitive.state.animSpeed = 2
            assignSprite("트래킹")
            setAction(0)
        case 30:
            primitive.state.animSpeed = 2
            assignSprite("트리플액션")
            setAction(0)
        case 31:
            primitive.state.animSpeed = 4
            assignSprite("어스퀘이크")
            setAction(0)
        case 32:
            primitive.state.animSpeed = 4
            assignSprite("폭죽_러브")
            setAction(0)
            context.world.playSound(named: "effect\\itempokjuk.wav", atWorldPosition: EffectSpace.toWorldPosition(position), delay: 0)
        case 33:
            primitive.state.animSpeed = 4
            assignSprite("폭죽_화이트데이")
            setAction(0)
            context.world.playSound(named: "effect\\itempokjuk.wav", atWorldPosition: EffectSpace.toWorldPosition(position), delay: 0)
        case 34:
            primitive.state.animSpeed = 4
            assignSprite("폭죽_발렌타인")
            setAction(0)
            context.world.playSound(named: "effect\\itempokjuk.wav", atWorldPosition: EffectSpace.toWorldPosition(position), delay: 0)
        case 35:
            primitive.state.animSpeed = 4
            assignSprite("폭죽_생일")
            setAction(0)
            context.world.playSound(named: "effect\\itempokjuk.wav", atWorldPosition: EffectSpace.toWorldPosition(position), delay: 0)
        case 36:
            primitive.state.animSpeed = 4
            assignSprite("폭죽_크리스마스")
            setAction(0)
            context.world.playSound(named: "effect\\itempokjuk.wav", atWorldPosition: EffectSpace.toWorldPosition(position), delay: 0)
        case 37:
            primitive.state.animSpeed = 4
            assignSprite("mobile_ef04")
            setAction(0)
        case 38:
            primitive.state.animSpeed = 4
            assignSprite("mashofa")
            setAction(0)
            context.world.playSound(named: K2L("effect\\t_에너지방출.wav"), atWorldPosition: EffectSpace.toWorldPosition(position), delay: 0)
        case 39:
            primitive.state.animSpeed = 4
            assignSprite("soule")
            setAction(0)
            context.world.playSound(named: K2L("effect\\매직 크래쉬.wav"), atWorldPosition: EffectSpace.toWorldPosition(position), delay: 0)
        case 50:
            primitive.state.deltaPos2.y = -1.0
            primitive.state.renderFlag = EffectPrimitiveState.RenderFlag.alpha
            primitive.state.repeatAnim = true
            assignSprite("기본트랩")
            setAction(0)
        case 51:
            primitive.state.deltaPos2.y = -1.0
            primitive.state.renderFlag = EffectPrimitiveState.RenderFlag.alpha
            primitive.state.repeatAnim = true
            assignSprite("담황색트랩")
            setAction(0)
        case 52:
            primitive.state.deltaPos2.y = -1.0
            primitive.state.renderFlag = EffectPrimitiveState.RenderFlag.alpha
            primitive.state.repeatAnim = true
            assignSprite("암청색트랩")
            setAction(0)
        case 53:
            primitive.state.deltaPos2.y = -1.0
            primitive.state.renderFlag = EffectPrimitiveState.RenderFlag.alpha
            primitive.state.repeatAnim = true
            assignSprite("자홍색트랩")
            setAction(0)
        case 54:
            primitive.state.deltaPos2.y = -1.0
            primitive.state.renderFlag = EffectPrimitiveState.RenderFlag.alpha
            primitive.state.repeatAnim = true
            assignSprite("청록색트랩")
            setAction(0)
        case 60:
            primitive.state.animSpeed = 4
            assignSprite("stapo", folder: "몬스터")
            primitive.state.deltaPos2.y = -8.0
            setAction(Int.random(in: 0..<2) == 0 ? 0 : 7)
        case 61:
            primitive.state.deltaPos2.y = -1.0
            primitive.state.renderFlag = alphaCustom
            primitive.state.repeatAnim = true
            primitive.state.animSpeed = Int.random(in: 0..<3) + 8
            primitive.state.pattern = 0
            primitive.state.alpha = Float(Int.random(in: 0..<71) + 70)
            primitive.state.size = Float(Int.random(in: 0..<11)) * 0.04 + 0.4
            primitive.state.red = 85
            primitive.state.green = 255
            primitive.state.blue = 85
            assignSprite("Ancient_tree", folder: "몬스터")
            setAction(Int.random(in: 0..<8))
        case 62:
            primitive.state.deltaPos2.y = -1.0
            primitive.state.renderFlag = alphaCustom
            primitive.state.repeatAnim = true
            primitive.state.animSpeed = Int.random(in: 0..<3) + 8
            primitive.state.pattern = 0
            primitive.state.alpha = Float(Int.random(in: 0..<71) + 70)
            primitive.state.size = Float(Int.random(in: 0..<11)) * 0.04 + 0.4
            primitive.state.red = 85
            primitive.state.green = 255
            primitive.state.blue = 85
            assignSprite("ifrit", folder: "몬스터")
            setAction(Int.random(in: 0..<8) + 0x20)
        case 63:
            primitive.state.deltaPos2.y = -12.0
            primitive.state.renderFlag = alphaCustom
            primitive.state.repeatAnim = true
            primitive.state.animSpeed = 6
            primitive.state.pattern = 0
            primitive.state.alpha = 255.0
            primitive.state.size = 0.7
            primitive.state.red = 155
            primitive.state.green = 255
            primitive.state.blue = 155
            assignSprite("mavka_bullet", folder: "몬스터")
            setAction(Int.random(in: 0..<8))
        case 64:
            primitive.state.deltaPos2.y = -1.0
            primitive.state.renderFlag = alphaCustom
            primitive.state.repeatAnim = true
            primitive.state.animSpeed = 3
            primitive.state.pattern = 0
            primitive.state.alpha = 205.0
            primitive.state.size = 2.5
            primitive.state.red = 155
            primitive.state.green = 155
            primitive.state.blue = 155
            assignSprite("breeze", folder: "몬스터")
            setAction(0)
        case 65:
            primitive.state.deltaPos2.y = -1.0
            primitive.state.renderFlag = alphaCustom
            primitive.state.repeatAnim = true
            primitive.state.animSpeed = 2
            primitive.state.pattern = 0
            primitive.state.alpha = 205.0
            primitive.state.size = 2.5
            primitive.state.red = 155
            primitive.state.green = 155
            primitive.state.blue = 155
            assignSprite("breeze", folder: "몬스터")
            setAction(4)
        case 70:
            primitive.state.repeatAnim = true
            assignSprite("거스트")
        case 71:
            primitive.state.repeatAnim = true
            assignSprite("블래스트")
        case 72:
            primitive.state.repeatAnim = true
            assignSprite("아쿠아플레이")
        case 73:
            primitive.state.repeatAnim = true
            assignSprite("업히벌")
        case 74:
            primitive.state.repeatAnim = true
            assignSprite("와일드스톰")
        case 75:
            primitive.state.repeatAnim = true
            assignSprite("칠리에어")
        case 76:
            primitive.state.repeatAnim = true
            assignSprite("커즈드소일")
        case 77:
            primitive.state.repeatAnim = true
            assignSprite("쿨러")
        case 78:
            primitive.state.repeatAnim = true
            assignSprite("트로픽")
        case 79:
            primitive.state.repeatAnim = true
            assignSprite("파이로테크닉")
        case 80:
            primitive.state.repeatAnim = true
            assignSprite("페트롤로지")
        case 81:
            primitive.state.repeatAnim = true
            assignSprite("히터")
        case 82:
            primitive.state.animSpeed = 4
            primitive.state.repeatAnim = true
            assignSprite("silent_brz")
        case 83:
            primitive.state.animSpeed = 4
            primitive.state.repeatAnim = false
            assignSprite("magma_flow")
        case 84:
            primitive.state.deltaPos2.y = -1.0
            primitive.state.renderFlag = EffectPrimitiveState.RenderFlag.alpha
            primitive.state.animSpeed = 10
            primitive.state.repeatAnim = true
            assignSprite("icemine")
        case 85:
            primitive.state.deltaPos2.y = -1.0
            primitive.state.renderFlag = EffectPrimitiveState.RenderFlag.alpha
            primitive.state.animSpeed = 10
            primitive.state.repeatAnim = false
            assignSprite("icemine_")
            setAction(0)
        case 86:
            primitive.state.animSpeed = 4
            assignSprite("RK_DRAGONBREATH_WATER")
        case 87:
            primitive.state.animSpeed = 4
            assignSprite("wideweb")
        case 88:
            primitive.state.animSpeed = 4
            primitive.state.repeatAnim = true
            assignSprite("burnt")
        case 90:
            primitive.state.deltaPos2.y = -1.0
            primitive.state.renderFlag = EffectPrimitiveState.RenderFlag.alpha
            primitive.state.repeatAnim = true
            assignSprite("그라운드드리프트")
            setAction(0)
        case 91:
            primitive.state.repeatAnim = true
            primitive.state.animSpeed = 4
            primitive.state.deltaPos2.y = -4.0
            assignSprite("나뭇잎_완성")
        case 94:
            primitive.state.repeatAnim = true
            primitive.state.animSpeed = 4
            primitive.state.deltaPos2.y = -4.0
            assignSprite("Black_Thunder\\Black_Thunder")
        case 95:
            primitive.state.repeatAnim = true
            primitive.state.animSpeed = 4
            primitive.state.deltaPos2.y = -4.0
            assignSprite("Black_Thunder\\Black_Thunder_Dark")
        case 96:
            primitive.state.repeatAnim = true
            primitive.state.renderFlag = topmostFlags
            primitive.state.animSpeed = 4
            assignSprite("Barmund_Magic_Circle\\Angel_Magic_Circle")
        case 97:
            primitive.state.repeatAnim = true
            primitive.state.renderFlag = topmostFlags
            primitive.state.animSpeed = 4
            assignSprite("Barmund_Magic_Circle\\Animal_Magic_Circle")
        case 98:
            primitive.state.repeatAnim = true
            primitive.state.renderFlag = topmostFlags
            primitive.state.animSpeed = 4
            assignSprite("Barmund_Magic_Circle\\Devil_Magic_Circle")
        case 99:
            primitive.state.repeatAnim = true
            primitive.state.renderFlag = topmostFlags
            primitive.state.animSpeed = 4
            assignSprite("Barmund_Magic_Circle\\Dragon_Magic_Circle")
        case 100:
            primitive.state.repeatAnim = true
            primitive.state.renderFlag = topmostFlags
            primitive.state.animSpeed = 4
            assignSprite("Barmund_Magic_Circle\\Fish_Magic_Circle")
        case 101:
            primitive.state.repeatAnim = true
            primitive.state.renderFlag = topmostFlags
            primitive.state.animSpeed = 4
            assignSprite("Barmund_Magic_Circle\\Human_Magic_Circle")
        case 102:
            primitive.state.repeatAnim = true
            primitive.state.renderFlag = topmostFlags
            primitive.state.animSpeed = 4
            assignSprite("Barmund_Magic_Circle\\Insect_Magic_Circle")
        case 103:
            primitive.state.repeatAnim = true
            primitive.state.renderFlag = topmostFlags
            primitive.state.animSpeed = 4
            assignSprite("Barmund_Magic_Circle\\Nothing_Magic_Circle")
        case 104:
            primitive.state.repeatAnim = true
            primitive.state.renderFlag = topmostFlags
            primitive.state.animSpeed = 4
            assignSprite("Barmund_Magic_Circle\\Plant_Magic_Circle")
        case 105:
            primitive.state.repeatAnim = true
            primitive.state.renderFlag = topmostFlags
            primitive.state.animSpeed = 4
            assignSprite("Barmund_Magic_Circle\\Undead_Magic_Circle")
        default:
            break
        }

        primitive.initSegment()
    }

    // MARK: - EF_TWILIGHT1 (573)

    /// Spawns 4-slot drifting item icon billboards (`PP_TWILIGHT` (123)) around the player for `EF_TWILIGHT1...3` (573...575).
    func scatterItemIcons(kind: Int8, context: EffectTickContext) {
        guard stateCnt == 0 else {
            return
        }

        let texturePath: String? = switch kind {
        case 0:
            K2L("유저인터페이스\\item\\하얀허브.bmp")
        case 1:
            K2L("유저인터페이스\\item\\화이트슬림포션.bmp")
        case 2:
            switch Int.random(in: 0..<3) {
            case 0:
                K2L("유저인터페이스\\item\\화염병.bmp")
            case 1:
                K2L("유저인터페이스\\item\\염산병.bmp")
            default:
                K2L("유저인터페이스\\item\\알코올.bmp")
            }
        default:
            nil
        }

        let primitive = launchPrimitive(.pp_twilight)
        primitive.state.renderFlag = EffectPrimitiveState.RenderFlag.alpha | EffectPrimitiveState.RenderFlag.customBlend
        primitive.state.duration = duration
        if let texturePath {
            _ = context.assets?.texture(atPath: texturePath)
            primitive.state.totalTexture = 1
            primitive.state.texturePaths = [texturePath]
        }

        let fadeStart = Int16(clamping: duration - 50)
        for i in 0..<4 {
            primitive.state.slots[i].life = 1
            primitive.state.slots[i].process = 0
            primitive.state.slots[i].height[7] = 3.0
            primitive.state.slots[i].fullDisplayAngle = Int16(Int.random(in: 0..<360))
            primitive.state.slots[i].alphaB = 0
            primitive.state.slots[i].flag1[0] = 0
            primitive.state.slots[i].rotStart = fadeStart
            let offsetX = Float(Int.random(in: 0..<160) - 80)
            let offsetZ = Float(Int.random(in: 0..<160) - 80)
            let worldX = position.x + offsetX
            let worldZ = position.z + offsetZ
            let drop = Float(Int.random(in: 0..<66))
            let terrainY = context.world.terrainHeight(atEffectX: worldX, effectZ: worldZ)
            primitive.state.slots[i].vecBNow = SIMD3<Float>(worldX, terrainY - 5.0 - drop, worldZ)
            for h in 0..<4 {
                primitive.state.slots[i].height[h] = Float(Int.random(in: 0..<360))
            }
            primitive.state.slots[i].distance = Float(Int.random(in: 0..<11)) * 0.1 + 3.0
            primitive.state.slots[i].height[8] = Float(Int.random(in: 0..<360))
            primitive.state.slots[i].flag1[2] = 7
        }
    }

    // MARK: - EF_KAIZEL (590)

    /// Spawns `PP_SLASH1` (75) four-way fan quads for `EF_KAIZEL` (590).
    func jobLvUp50Pair(angle: Int16, context: EffectTickContext) {
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
}
