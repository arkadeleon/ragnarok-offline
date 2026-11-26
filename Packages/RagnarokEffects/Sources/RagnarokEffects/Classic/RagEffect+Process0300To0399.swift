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
        .ef_chemicalprotection,
        .ef_pokjuk_sound,
        .ef_demonstration,
        .ef_chemical2,
        .ef_teleportation2,
        .ef_forestlight,
        .ef_throwitem3,
        .ef_firstaid,
        .ef_sprinklesand,
        .ef_heal,
        .ef_heal2,
        .ef_exit2,
        .ef_glasswall2,
        .ef_readyportal2,
        .ef_portal2,
        .ef_bottom_mag,
        .ef_bottom_sanc,
        .ef_heal3,
        .ef_warpzone2,
        .ef_forestlight2,
        .ef_forestlight3,
        .ef_forestlight4,
        .ef_heal4,
        .ef_foot,
        .ef_foot2,
        .ef_beginasura,
        .ef_tripleattack,
        .ef_hitline,
        .ef_hptime,
        .ef_sptime,
        .ef_maple,
        .ef_blind,
        .ef_poison,
        .ef_guard,
        .ef_joblvup50,
        .ef_angel2,
        .ef_magnum2,
        .ef_callzone,
        .ef_portal3,
        .ef_couplecasting,
        .ef_heartcasting,
        .ef_entry2,
        .ef_saintwing,
        .ef_spherewind,
        .ef_colorpaper,
        .ef_lightsphere,
        .ef_waterfall,
        .ef_waterfall_90,
        .ef_waterfall_small,
        .ef_waterfall_small_90,
        .ef_waterfall_t2,
        .ef_waterfall_t2_90,
        .ef_waterfall_small_t2,
        .ef_waterfall_small_t2_90,
        .ef_ghost,
        .ef_bat,
        .ef_bat2,
        .ef_soulbreaker,
        .ef_level99_4,
        .ef_vallentine,
        .ef_vallentine2,
        .ef_pressure,
        .ef_bash3d,
        .ef_aurablade,
        .ef_redbody,
        .ef_bottom_gospel,
        .ef_dragonsmoke,
        .ef_bottom_basilica,
        .ef_assumptio,
        .ef_hitline2,
        .ef_bash3d2,
        .ef_energydrain2,
        .ef_transbluebody,
        .ef_magiccrasher,
        .ef_lightsphere2,
        .ef_lightblade,
        .ef_energydrain3,
        .ef_linelink2,
        .ef_linklight,
        .ef_truesight,
        .ef_falconassault,
        .ef_tripleattack2,
        .ef_portal4,
        .ef_tripleattack3,
        .ef_spherewind2,
        .ef_linelink3,
        .ef_pinkbody,
        .ef_level99_5,
        .ef_level99_6,
        .ef_bash3d3,
    ]

    func process0300To0399(context: EffectTickContext) -> Bool {
        switch effectID {
        case .ef_chemicalprotection:
            if stateCnt == 0 {
                context.world.playSound(
                    named: "apocalips_attack.wav",
                    atWorldPosition: EffectSpace.toWorldPosition(position),
                    delay: 0
                )
            }
            shockwaveRing(angle: 30, context: context)
            shockwaveRing(angle: 60, context: context)
        case .ef_pokjuk_sound:
            fireworks(context: context)
        case .ef_demonstration:
            demonstration(context: context)
        case .ef_chemical2:
            slashFan(reverse: 0, context: context)
            slashFan(reverse: 1, context: context)
            if stateCnt == 44 {
                context.world.shakeCamera(amplitude: 1.0, duration: 0.35, frequency: 20.0)
                context.world.playSound(
                    named: K2L("effect\\연주붕격.wav"),
                    atWorldPosition: EffectSpace.toWorldPosition(position),
                    delay: 0
                )
            }
            if stateCnt >= 20 && stateCnt <= 120, let targetID = targetObjectID ?? ownerObjectID {
                context.world.applyTargetModifier(
                    .flash(color: SIMD4<Float>(1.0, 1.0, 150.0 / 255.0, 1.0), durationTicks: 2),
                    to: targetID
                )
            }
        case .ef_teleportation2:
            teleportRings(texturePath: "effect\\Magic_Violet.tga", level: 0, context: context)
        case .ef_forestlight:
            forestLight(texturePath: "effect\\cloud11.tga", flag: 0, context: context)
        case .ef_throwitem3:
            throwItem(texturePath: K2L("유저인터페이스\\item\\돌.bmp"), kind: 2, context: context)
        case .ef_firstaid:
            firstAid(context: context)
        case .ef_sprinklesand:
            for _ in 0..<20 {
                thunderSparks(context: context)
            }
        case .ef_heal:
            healBurst(texturePath: "effect\\alpha_down.tga", flag: 0, context: context)
        case .ef_heal2:
            healRingSparkle(texturePath: "effect\\ring_white.tga", type: 0, context: context)
        case .ef_exit2:
            teleportSpiral(texturePath: "effect\\ring_purple.tga", context: context)
        case .ef_glasswall2:
            return glassWallRising(texturePath: "effect\\alpha_down.tga", context: context)
        case .ef_readyportal2:
            blueRingWave(context: context)
        case .ef_portal2:
            violetRingCloud(type: 0, context: context)
        case .ef_bottom_mag:
            texturedPulseKind(texturePath: "effect\\ring_red.tga", kind: 0, context: context)
        case .ef_bottom_sanc:
            texturedPulseKind(texturePath: "effect\\alpha_down.tga", kind: 1, context: context)
        case .ef_heal3:
            healBurst(texturePath: "effect\\alpha_down.tga", flag: 1, context: context)
        case .ef_warpzone2:
            alphaDownRipples(texturePath: "effect\\ring_blue.tga", kind: 0, context: context)
        case .ef_forestlight2:
            forestLight(texturePath: "effect\\cloud11.tga", flag: 1, context: context)
        case .ef_forestlight3:
            forestLight(texturePath: "effect\\cloud11.tga", flag: 2, context: context)
        case .ef_forestlight4:
            forestLight(texturePath: "effect\\cloud11.tga", flag: 10, context: context)
        case .ef_heal4:
            healRingSparkle(texturePath: "effect\\ring_white.tga", type: 1, context: context)
        case .ef_foot:
            texturedRise(texturePath: "effect\\foot_l_b.tga", large: 0, context: context)
        case .ef_foot2:
            texturedRise(texturePath: "effect\\foot_r_b.tga", large: 0, context: context)
        case .ef_beginasura:
            beginAsura(kind: 0, context: context)
        case .ef_tripleattack:
            cloudDrift(context: context)
        case .ef_hitline:
            whiteSparks(kind: 0, context: context)
        case .ef_hptime:
            texturedRisingOrbs(texturePath: "effect\\white02.bmp", kind: 0, context: context)
        case .ef_sptime:
            texturedRisingOrbs(texturePath: "effect\\white02.bmp", kind: 1, context: context)
        case .ef_maple:
            maple(context: context)
        case .ef_blind:
            blind(flag: 0, context: context)
        case .ef_poison:
            poison(flag: 0, context: context)
        case .ef_guard:
            kyrieGuard(texturePath: "effect\\guardK.tga", kind: 0, context: context)
        case .ef_joblvup50:
            let keepRunning = jobLvUp50(angle: 0, context: context)
            _ = jobLvUp50(angle: 45, context: context)
            return keepRunning
        case .ef_angel2:
            superAngel(type: 0, context: context)
            superAngel(type: 1, context: context)
            superAngel(type: 2, context: context)
            superAngel(type: 3, context: context)
        case .ef_magnum2:
            magnum2(texturePath: "effect\\ring_yellow.tga", context: context)
        case .ef_callzone:
            callZone(texturePath: "effect\\white02.bmp", context: context)
        case .ef_portal3:
            violetRingCloud(type: 3, context: context)
        case .ef_couplecasting:
            texturedSpellRings(texturePath: "effect\\ring_red.tga", context: context)
        case .ef_heartcasting:
            processHeartCasting(context: context)
        case .ef_entry2:
            portalRings(context: context)
        case .ef_saintwing:
            saintWing(texturePath: "effect\\wing003.bmp", context: context)
        case .ef_spherewind:
            for angle in stride(from: 0, to: 45, by: 9) {
                featherRing(texturePath: "effect\\blue_ivy.bmp", angle: Int16(angle), large: 0, context: context)
            }
        case .ef_colorpaper:
            for _ in 0..<50 {
                weddingBurst(texturePath: "effect\\white02.bmp", silent: 0, context: context)
            }
        case .ef_lightsphere:
            texturedAura(texturePath: "effect\\thunder_center.bmp", kind: 0, context: context)
            for _ in 0..<80 {
                texturedSparkle(texturePath: "effect\\white02.bmp", context: context)
            }
        case .ef_waterfall:
            waterfall(flag: 0, tall: 0, variant: 0, context: context)
            for _ in 0..<40 {
                frostScatter(swapAxes: 0, narrow: 0, context: context)
            }
        case .ef_waterfall_90:
            waterfall(flag: 1, tall: 0, variant: 0, context: context)
            for _ in 0..<40 {
                frostScatter(swapAxes: 1, narrow: 0, context: context)
            }
        case .ef_waterfall_small:
            waterfall(flag: 0, tall: 1, variant: 0, context: context)
            for _ in 0..<20 {
                frostScatter(swapAxes: 0, narrow: 1, context: context)
            }
        case .ef_waterfall_small_90:
            waterfall(flag: 1, tall: 1, variant: 0, context: context)
            for _ in 0..<20 {
                frostScatter(swapAxes: 1, narrow: 1, context: context)
            }
        case .ef_waterfall_t2:
            waterfall(flag: 0, tall: 0, variant: 1, context: context)
            for _ in 0..<40 {
                frostScatter(swapAxes: 0, narrow: 0, context: context)
            }
        case .ef_waterfall_t2_90:
            waterfall(flag: 1, tall: 0, variant: 1, context: context)
            for _ in 0..<40 {
                frostScatter(swapAxes: 1, narrow: 0, context: context)
            }
        case .ef_waterfall_small_t2:
            waterfall(flag: 0, tall: 1, variant: 1, context: context)
            for _ in 0..<20 {
                frostScatter(swapAxes: 0, narrow: 1, context: context)
            }
        case .ef_waterfall_small_t2_90:
            waterfall(flag: 1, tall: 1, variant: 1, context: context)
            for _ in 0..<20 {
                frostScatter(swapAxes: 1, narrow: 1, context: context)
            }
        case .ef_ghost:
            ghost(type: 0, context: context)
        case .ef_bat:
            ghost(type: 1, context: context)
        case .ef_bat2:
            ghost(type: 2, context: context)
        case .ef_soulbreaker:
            if stateCnt == 20 {
                context.world.playSound(
                    named: K2L("effect\\기공포.wav"),
                    atWorldPosition: EffectSpace.toWorldPosition(position),
                    delay: 0
                )
            }
            if stateCnt <= 10, let targetID = targetObjectID ?? ownerObjectID {
                context.world.applyTargetModifier(
                    .tint(color: SIMD4<Float>(1.0, 0.0, 1.0, 1.0), durationTicks: 2),
                    to: targetID
                )
            }
            sonicWave(sonic: 0, context: context)
        case .ef_level99_4:
            freezingCircle(kind: 1, context: context)
        case .ef_vallentine:
            vallentine(kind: 0, context: context)
        case .ef_vallentine2:
            vallentine(kind: 1, context: context)
        case .ef_pressure:
            if stateCnt == 3 {
                context.world.playSound(
                    named: K2L("effect\\프레셔.wav"),
                    atWorldPosition: EffectSpace.toWorldPosition(position),
                    delay: 0
                )
            }
            texturedRain(texturePath: "effect\\cross_old.bmp", kind: 0, context: context)
            texturedLevelRing(texturePath: "effect\\explosive_1_128.bmp", process: -28, level: 0, context: context)
        case .ef_bash3d:
            if stateCnt == 22 {
                context.world.playSound(
                    named: K2L("effect\\세크리파이스.wav"),
                    atWorldPosition: EffectSpace.toWorldPosition(position),
                    delay: 0
                )
            }
            for phase in 0..<5 {
                texturedQuadSpin(texturePath: "effect\\alpha_center.tga", phase: Int8(phase), kind: 0, context: context)
            }
            if stateCnt >= 20 && stateCnt <= 40, let targetID = targetObjectID ?? ownerObjectID {
                context.world.applyTargetModifier(
                    .flash(color: SIMD4<Float>(1.0, 200.0 / 255.0, 200.0 / 255.0, 1.0), durationTicks: 2),
                    to: targetID
                )
            }
        case .ef_aurablade:
            whiteYellowRings(context: context)
        case .ef_redbody:
            if let targetID = targetObjectID ?? ownerObjectID {
                context.world.applyTargetModifier(
                    .tint(color: SIMD4<Float>(1.0, 100.0 / 255.0, 100.0 / 255.0, 1.0), durationTicks: 2),
                    to: targetID
                )
            }
        case .ef_bottom_gospel:
            bottomMusic(texturePath: "effect\\cross_old.bmp", kind: 9, context: context)
        case .ef_dragonsmoke:
            processDragonSmoke(context: context)
        case .ef_bottom_basilica:
            texturedFourRing(texturePath: "effect\\alpha_down.tga", kind: 0, context: context)
            texturedFourRing(texturePath: "effect\\alpha_down.tga", kind: 1, context: context)
        case .ef_assumptio:
            if let targetID = targetObjectID ?? ownerObjectID {
                context.world.applyTargetModifier(
                    .flash(color: SIMD4<Float>(1.0, 1.0, 1.0, 1.0), durationTicks: 2),
                    to: targetID
                )
            }
        case .ef_hitline2:
            whiteSparks(kind: 2, context: context)
            if stateCnt >= 10 && stateCnt <= 20, let targetID = targetObjectID ?? ownerObjectID {
                context.world.applyTargetModifier(
                    .flash(color: SIMD4<Float>(1.0, 120.0 / 255.0, 50.0 / 255.0, 1.0), durationTicks: 2),
                    to: targetID
                )
            }
        case .ef_bash3d2:
            if stateCnt == 5 {
                context.world.playSound(
                    named: K2L("effect\\mon_맹룡과강.wav"),
                    atWorldPosition: EffectSpace.toWorldPosition(position),
                    delay: 0
                )
            }
            for phase in 0..<8 {
                texturedQuadSpin(texturePath: "effect\\alpha_center.tga", phase: Int8(phase), kind: 2, context: context)
            }
            if stateCnt >= 5 && stateCnt <= 35, let targetID = targetObjectID ?? ownerObjectID {
                context.world.applyTargetModifier(
                    .tint(color: SIMD4<Float>(1.0, 1.0, 1.0, 1.0), durationTicks: 2),
                    to: targetID
                )
            }
        case .ef_energydrain2:
            energyDrain2(context: context)
            if stateCnt >= 55 && stateCnt <= 65, let targetID = targetObjectID ?? ownerObjectID {
                context.world.applyTargetModifier(
                    .tint(color: SIMD4<Float>(100.0 / 255.0, 100.0 / 255.0, 1.0, 1.0), durationTicks: 2),
                    to: targetID
                )
            }
        case .ef_transbluebody:
            if stateCnt <= 200, let targetID = targetObjectID ?? ownerObjectID {
                let channel = Float(max(0, 205 - stateCnt)) / 255.0
                context.world.applyTargetModifier(
                    .tint(color: SIMD4<Float>(channel, channel, 1.0, 1.0), durationTicks: 2),
                    to: targetID
                )
            }
        case .ef_magiccrasher:
            if stateCnt == 25 {
                context.world.playSound(
                    named: K2L("effect\\매직 크래쉬.wav"),
                    atWorldPosition: EffectSpace.toWorldPosition(position),
                    delay: 0
                )
            }
            if stateCnt == 30 {
                context.world.shakeCamera(amplitude: 1.0, duration: 0.35, frequency: 20.0)
            }
            if stateCnt >= 30 && stateCnt <= 60, let targetID = targetObjectID ?? ownerObjectID {
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
        case .ef_lightsphere2:
            texturedAura(texturePath: "effect\\thunder_center.bmp", kind: 0, context: context)
            for _ in 0..<80 {
                texturedSparkle(texturePath: "effect\\white02.bmp", context: context)
            }
        case .ef_lightblade:
            if let targetID = targetObjectID ?? ownerObjectID {
                context.world.applyTargetModifier(
                    .flash(color: SIMD4<Float>(1.0, 1.0, 1.0, 1.0), durationTicks: 2),
                    to: targetID
                )
            }
        case .ef_energydrain3:
            sonicSlashFan(kind: 0, context: context)
            if stateCnt >= 50 && stateCnt <= 80, let targetID = targetObjectID ?? ownerObjectID {
                let channel = Float(max(0, (125 - stateCnt) * 2)) / 255.0
                context.world.applyTargetModifier(
                    .flash(color: SIMD4<Float>(channel, channel, 250.0 / 255.0, 1.0), durationTicks: 2),
                    to: targetID
                )
            }
        case .ef_linelink2:
            if stateCnt == 0 {
                context.world.playSound(
                    named: K2L("effect\\소울 체인지.wav"),
                    atWorldPosition: EffectSpace.toWorldPosition(position),
                    delay: 0
                )
            }
            trackTarget(context: context)
        case .ef_linklight:
            if stateCnt >= 40 && stateCnt <= 70, let targetID = targetObjectID ?? ownerObjectID {
                context.world.applyTargetModifier(
                    .tint(color: SIMD4<Float>(200.0 / 255.0, 150.0 / 255.0, 50.0 / 255.0, 1.0), durationTicks: 2),
                    to: targetID
                )
            }
        case .ef_truesight:
            if stateCnt == 0 {
                context.world.playSound(
                    named: "effect\\hunter_detecting.wav",
                    atWorldPosition: EffectSpace.toWorldPosition(position),
                    delay: 0
                )
            }
            for phase in 0..<12 {
                texturedQuadSpin(texturePath: "effect\\alpha_center.tga", phase: Int8(phase), kind: 3, context: context)
            }
        case .ef_falconassault:
            if stateCnt == 30 {
                context.world.shakeCamera(amplitude: 1.0, duration: 0.35, frequency: 20.0)
            }
            if let targetID = targetObjectID ?? ownerObjectID {
                if stateCnt >= 30 && stateCnt <= 54 {
                    let spinYaw = Float((stateCnt - 29) * 30).truncatingRemainder(dividingBy: 360.0)
                    context.world.applyTargetModifier(.rotation(SIMD3<Float>(0, spinYaw, 0), durationTicks: 2), to: targetID)
                }
                if stateCnt >= 30 && stateCnt <= 50 && stateCnt % 10 < 5 {
                    context.world.applyTargetModifier(.tint(color: SIMD4<Float>(1.0, 1.0, 1.0, 1.0), durationTicks: 2), to: targetID)
                }
            }
        case .ef_tripleattack2:
            if stateCnt == 30 {
                context.world.playSound(
                    named: K2L("effect\\샤프슈팅.wav"),
                    atWorldPosition: EffectSpace.toWorldPosition(position),
                    delay: 0
                )
            }
            alphaCenterTrail(context: context)
        case .ef_portal4:
            cloud11Burst(kind: 0, context: context)
            if stateCnt == 0 {
                context.world.playSound(
                    named: K2L("effect\\윈드워크.wav"),
                    atWorldPosition: EffectSpace.toWorldPosition(position),
                    delay: 0
                )
            }
            if stateCnt >= 5 && stateCnt <= 25, let targetID = targetObjectID ?? ownerObjectID {
                context.world.applyTargetModifier(
                    .tint(color: SIMD4<Float>(220.0 / 255.0, 250.0 / 255.0, 220.0 / 255.0, 1.0), durationTicks: 2),
                    to: targetID
                )
            }
        case .ef_tripleattack3:
            if stateCnt == 30 {
                context.world.playSound(
                    named: K2L("effect\\애로우 발칸.wav"),
                    atWorldPosition: EffectSpace.toWorldPosition(position),
                    delay: 0
                )
            }
            alphaCenterStream(context: context)
        case .ef_spherewind2:
            for angle in stride(from: 0, to: 45, by: 9) {
                featherRing(texturePath: "effect\\fire_ivy.bmp", angle: Int16(angle), large: 1, context: context)
            }
        case .ef_linelink3:
            if stateCnt == 0 {
                context.world.playSound(
                    named: K2L("effect\\소울 체인지.wav"),
                    atWorldPosition: EffectSpace.toWorldPosition(position),
                    delay: 0
                )
            }
            trackTargetWide(context: context)
        case .ef_pinkbody:
            if let targetID = targetObjectID ?? ownerObjectID {
                context.world.applyTargetModifier(
                    .flash(color: SIMD4<Float>(1.0, 89.0 / 255.0, 182.0 / 255.0, 1.0), durationTicks: 2),
                    to: targetID
                )
            }
        case .ef_level99_5:
            tripleRingStack(texturePath: "effect\\ring_blue.tga", large: 0, context: context)
        case .ef_level99_6:
            texturedDoubleRing(texturePath: "effect\\pikapika2.bmp", level: 0, context: context)
        case .ef_bash3d3:
            if stateCnt == 0 {
                context.world.playSound(
                    named: K2L("effect\\헤드 크러쉬.wav"),
                    atWorldPosition: EffectSpace.toWorldPosition(position),
                    delay: 0
                )
            }
            for phase in 0..<6 {
                texturedQuadSpin(texturePath: "effect\\alpha_center.tga", phase: Int8(phase), kind: 4, context: context)
            }
            if stateCnt >= 20 && stateCnt <= 50, let targetID = targetObjectID ?? ownerObjectID {
                context.world.applyTargetModifier(
                    .flash(color: SIMD4<Float>(1.0, 1.0, 200.0 / 255.0, 1.0), durationTicks: 2),
                    to: targetID
                )
            }
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

    // MARK: - EF_CHEMICALPROTECTION (300)

    /// Spawns 4-slot shockwave rings (`PP_CHEMICALPROTECTION` (54)) for `EF_CHEMICALPROTECTION` (300).
    func shockwaveRing(angle: Int16, context: EffectTickContext) {
        guard stateCnt == 0 else {
            return
        }

        let texturePath = "effect\\shockwave_c.bmp"
        _ = context.assets?.texture(atPath: texturePath)

        let primitive = launchPrimitive(.pp_chemicalprotection)
        primitive.state.renderFlag = EffectPrimitiveState.RenderFlag.alpha | EffectPrimitiveState.RenderFlag.customBlend
        primitive.state.duration = duration
        primitive.state.texturePaths = [texturePath]
        position.y -= 9.0

        for index in 0..<4 {
            primitive.state.slots[index].life = 1
            primitive.state.slots[index].process = 0
            primitive.state.slots[index].distance = 100.0
            primitive.state.slots[index].riseAngle = Int16(index * 90) + angle
            primitive.state.slots[index].alphaB = 0
        }
    }

    // MARK: - EF_POKJUK_SOUND (301)

    /// Plays periodic firework audio on tick 300 and loops after tick 2300 for `EF_POKJUK_SOUND` (301).
    func fireworks(context: EffectTickContext) {
        if stateCnt == 300 {
            context.world.playSound(
                named: K2L("effect\\폭죽.wav"),
                atWorldPosition: EffectSpace.toWorldPosition(position),
                delay: 0
            )
        }

        if stateCnt > 2300 {
            stateCnt = 299
        }
    }

    // MARK: - EF_DEMONSTRATION (302)

    /// Spawns Demonstration flame sprite (`51`) for `EF_DEMONSTRATION` (302).
    func demonstration(context: EffectTickContext) {
        guard stateCnt == 0 else {
            return
        }

        let spritePath = K2L("이팩트\\데몬스트레이션.spr")
        let actionPath = K2L("이팩트\\데몬스트레이션.act")
        _ = context.assets?.spriteAsset(spritePath: spritePath, actionPath: actionPath)

        let primitive = launchPrimitive(51)
        primitive.state.duration = duration
        primitive.state.slots[0].life = 1
        primitive.state.slots[0].process = 0
        primitive.state.slots[0].maxHeight = 0
        primitive.state.size = 1.2
        primitive.state.slots[0].vecBPre = SIMD3<Float>(position.x, position.y - 1.0, position.z)
        primitive.state.slots[0].flag1[4] = 0
        primitive.state.alpha = 200.0
        primitive.state.spritePath = spritePath
        primitive.state.actionPath = actionPath
        primitive.state.animSpeed = 4
        primitive.currentMotion = 0
        primitive.initSegment()
        for i in 1..<4 {
            primitive.state.slots[i].life = 0
        }
    }

    // MARK: - EF_CHEMICAL2 (303)

    /// Spawns 4-slot sweeping slash fan (`PP_CHEMICAL2` (55)) at tick 40 for `EF_CHEMICAL2` (303).
    func slashFan(reverse: Int16, context: EffectTickContext) {
        guard stateCnt == 40 else {
            return
        }

        let texturePath = "effect\\slash01.tga"
        _ = context.assets?.texture(atPath: texturePath)

        let primitive = launchPrimitive(.pp_chemical2)
        primitive.state.renderFlag |= EffectPrimitiveState.RenderFlag.noDepth
        primitive.state.duration = duration
        primitive.state.texturePaths = [texturePath]
        position.y -= 9.0

        let angle = EffectPrimitive.angle(dx: deltaPos.x - position.x, dy: deltaPos.z - position.z)
        let normalizedAngle: Int16 = angle >= 360 ? angle - 360 : angle

        for index in 0..<4 {
            primitive.state.slots[index].life = 1
            primitive.state.slots[index].process = 0
            primitive.state.slots[index].distance = 100.0
            primitive.state.slots[index].maxHeight = 1.0
            primitive.state.slots[index].height[0] = reverse == 0
                ? -15.0 - Float(index) * 2.5
                : Float(index) * 2.5 + 15.0
            primitive.state.slots[index].riseAngle = normalizedAngle
            primitive.state.slots[index].alphaB = 0
        }
    }

    // MARK: - EF_TELEPORTATION2 (304)

    /// Spawns 4-layer rising teleport rings (`57`) for `EF_TELEPORTATION2` (304).
    func teleportRings(texturePath: String, level: Int16, context: EffectTickContext) {
        guard stateCnt == 0 else {
            return
        }

        context.world.playSound(
            named: "effect\\EF_Teleportation.wav",
            atWorldPosition: EffectSpace.toWorldPosition(position),
            delay: 0
        )

        _ = context.assets?.texture(atPath: texturePath)

        let primitive = launchPrimitive(57)
        primitive.state.renderFlag = EffectPrimitiveState.RenderFlag.alpha | EffectPrimitiveState.RenderFlag.customBlend
        primitive.state.duration = duration
        primitive.state.texturePaths = [texturePath]
        primitive.state.size = 4.0

        let configs: [(maxHeight: Float, rotStart: Int16, alphaB: Int16, distance: Float, riseAngle: Int16)] = [
            (Float(level * 60) + 100.0, 180, 100, 1.5 - Float(level * 2), 90),
            (Float(level * 60) + 70.0, 270, 80, 3.0 - Float(level * 2), 89),
            (Float(level * 60) + 40.0, 0, 60, 4.0 - Float(level * 2), 88),
            (Float(level * 60) + 15.0, 90, 40, 5.0 - Float(level * 2), 87),
        ]

        for (index, config) in configs.enumerated() {
            primitive.state.slots[index].life = 1
            primitive.state.slots[index].process = 0
            primitive.state.slots[index].fullDisplayAngle = 360
            primitive.state.slots[index].maxHeight = config.maxHeight
            primitive.state.slots[index].rotStart = config.rotStart
            primitive.state.slots[index].alphaB = config.alphaB
            primitive.state.slots[index].distance = config.distance
            primitive.state.slots[index].riseAngle = config.riseAngle
            primitive.state.slots[index].vecBNow.y = 0
            primitive.state.slots[index].height = Array(repeating: 0, count: 21)
            primitive.state.slots[index].flag1[0] = 0
            primitive.state.slots[index].flag1[1] = Int8(truncatingIfNeeded: Int(config.maxHeight))
        }
    }

    // MARK: - EF_SPRINKLESAND (310)

    /// Spawns 4-slot rising sand/spark flecks (`PP_PARTICLE_UP` (59)) for `EF_SPRINKLESAND` (310).
    func thunderSparks(context: EffectTickContext) {
        guard stateCnt == 0 else {
            return
        }

        let texturePath = "effect\\thunder_center.bmp"
        _ = context.assets?.texture(atPath: texturePath)

        let primitive = launchPrimitive(.pp_particle_up)
        primitive.state.renderFlag = EffectPrimitiveState.RenderFlag.alpha | EffectPrimitiveState.RenderFlag.customBlend
        primitive.state.duration = duration
        primitive.state.texturePaths = [texturePath]
        primitive.state.size = 0
        primitive.position = position

        for index in 0..<4 {
            primitive.state.slots[index].life = 1
            primitive.state.slots[index].process = Int.random(in: 0..<10) - 10
            primitive.state.slots[index].distance = Float(Int.random(in: 0..<16)) * 0.03 + 0.1
            primitive.state.slots[index].height[8] = 0
            primitive.state.slots[index].alphaB = 0
            primitive.state.slots[index].vecBNow = SIMD3<Float>(
                Float(Int.random(in: 0..<9)) + position.x - 4.0,
                position.y,
                Float(Int.random(in: 0..<9)) + position.z - 4.0
            )
            primitive.state.slots[index].rotStart = 0
            primitive.state.slots[index].height[1] = Float(Int.random(in: 0..<10)) * 0.01
            primitive.state.slots[index].height[2] = Float(Int.random(in: 0..<40)) * 0.01 + 0.2
            primitive.state.slots[index].fullDisplayAngle = 0
            primitive.state.slots[index].flag1[0] = 0
            primitive.state.slots[index].flag1[1] = 0
            primitive.state.slots[index].flag1[2] = 10
            primitive.state.slots[index].height[7] = 0
        }
    }

    // MARK: - EF_EXIT2 (314)

    /// Spawns 4-layer rising spiral columns (`60`) for `EF_EXIT2` (314).
    func teleportSpiral(texturePath: String, context: EffectTickContext) {
        guard stateCnt == 0 else {
            return
        }

        context.world.playSound(
            named: "effect\\EF_Teleportation.wav",
            atWorldPosition: EffectSpace.toWorldPosition(position),
            delay: 0
        )

        _ = context.assets?.texture(atPath: texturePath)

        let primitive = launchPrimitive(60)
        primitive.state.renderFlag = EffectPrimitiveState.RenderFlag.alpha | EffectPrimitiveState.RenderFlag.customBlend
        primitive.state.duration = duration
        primitive.state.texturePaths = [texturePath]
        primitive.state.size = 4.0

        let configs: [(maxHeight: Float, rotStart: Int16, distance: Float, riseAngle: Int16, alphaT: Int16)] = [
            (180.0, 270, 1.8, 90, 58),
            (70.0, 180, 2.0, 88, 60),
            (45.0, 90, 2.2, 86, 60),
            (20.0, 0, 2.4, 84, 60),
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

    // MARK: - EF_GLASSWALL2 (315)

    /// Spawns 3-layer rose-pink safety wall columns (`60`) and advances `SafetyWall.str` for `EF_GLASSWALL2` (315).
    func glassWallRising(texturePath: String, context: EffectTickContext) -> Bool {
        if stateCnt == 0 {
            configureSTR(path: "SafetyWall.str")
            context.world.playSound(
                named: "effect\\EF_GlassWall.wav",
                atWorldPosition: EffectSpace.toWorldPosition(position),
                delay: 0
            )

            _ = context.assets?.texture(atPath: texturePath)

            let primitive = launchPrimitive(60)
            primitive.state.renderFlag = EffectPrimitiveState.RenderFlag.alpha | EffectPrimitiveState.RenderFlag.customBlend
            primitive.state.duration = duration
            primitive.state.texturePaths = [texturePath]
            primitive.state.size = 10.0

            let configs: [(maxHeight: Float, distance: Float, alphaT: Int16)] = [
                (34.0, 3.6, 5500),
                (37.0, 3.3, 3080),
                (40.0, 3.0, 3080),
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
                primitive.state.slots[index].alphaT = config.alphaT
                primitive.state.slots[index].vecBNow.y = 0
                primitive.state.slots[index].height = Array(repeating: 0, count: 21)
                primitive.state.slots[index].flag1 = Array(repeating: 0, count: 21)
            }
            primitive.state.slots[3].life = 0
        }

        _ = processEZ2STRRaised(context: context)
        return stateCnt != duration
    }

    // MARK: - EF_READYPORTAL2 (316)

    /// Spawns 3 staggered expanding blue ripple rings (`63`) for `EF_READYPORTAL2` (316).
    func blueRingWave(context: EffectTickContext) {
        if stateCnt % 14 == 0 {
            context.world.playSound(
                named: "effect\\EF_ReadyPortal.wav",
                atWorldPosition: EffectSpace.toWorldPosition(position),
                delay: 0
            )
        }

        guard stateCnt == 0 else {
            return
        }

        let texturePath = "effect\\ring_blue.tga"
        _ = context.assets?.texture(atPath: texturePath)

        let primitive = launchPrimitive(63)
        primitive.state.renderFlag = EffectPrimitiveState.RenderFlag.alpha | EffectPrimitiveState.RenderFlag.customBlend
        primitive.state.duration = duration
        primitive.state.texturePaths = [texturePath]
        primitive.state.size = 5.0

        for index in 0..<3 {
            primitive.state.slots[index].life = 1
            primitive.state.slots[index].process = index * -10
            primitive.state.slots[index].fullDisplayAngle = 360
            primitive.state.slots[index].maxHeight = 6.001
            primitive.state.slots[index].rotStart = Int16(index * 25)
            primitive.state.slots[index].alphaB = 0
            primitive.state.slots[index].distance = 0
            primitive.state.slots[index].riseAngle = Int16(index + 2)
            primitive.state.slots[index].alphaT = 100
            primitive.state.slots[index].vecBNow.y = 0
            primitive.state.slots[index].height = Array(repeating: 0, count: 21)
            primitive.state.slots[index].flag1 = Array(repeating: 1, count: 21)
        }
        primitive.state.slots[3].life = 0
        primitive.state.slots[3].process = 0
        primitive.state.slots[3].alphaT = 1
    }

    // MARK: - EF_PORTAL2 (317)

    /// Spawns staged portal columns (`60`), ripple rings (`63`), and wind arcs (`PP_WIND` (62)) for `EF_PORTAL2` (317) and `EF_PORTAL3` (341).
    func violetRingCloud(type: Int8, context: EffectTickContext) {
        if stateCnt == 0 {
            let texturePath = type == 3 ? "effect\\ring_red.tga" : "effect\\magic_violet.tga"
            _ = context.assets?.texture(atPath: texturePath)

            let primitive = launchPrimitive(60)
            primitive.state.renderFlag = EffectPrimitiveState.RenderFlag.alpha | EffectPrimitiveState.RenderFlag.customBlend
            primitive.state.duration = duration
            primitive.state.texturePaths = [texturePath]
            primitive.state.size = type == 3 ? 10.0 : 4.0

            let distances: [Float] = [4.0, 3.0, 2.0]
            for (index, distance) in distances.enumerated() {
                primitive.state.slots[index].life = 1
                primitive.state.slots[index].process = 0
                primitive.state.slots[index].fullDisplayAngle = 360
                primitive.state.slots[index].maxHeight = 50.0
                primitive.state.slots[index].rotStart = Int16(Int.random(in: 0..<360))
                primitive.state.slots[index].alphaB = 0
                primitive.state.slots[index].distance = distance
                primitive.state.slots[index].riseAngle = 90
                primitive.state.slots[index].alphaT = 1400
                primitive.state.slots[index].vecBNow.y = 0
                primitive.state.slots[index].height = Array(repeating: 0, count: 21)
                primitive.state.slots[index].flag1 = Array(repeating: 1, count: 21)
            }
            primitive.state.slots[3].life = 0
        }

        if stateCnt == 1 {
            let texturePath = type == 3 ? "effect\\ring_red.tga" : "effect\\ring_blue.tga"
            _ = context.assets?.texture(atPath: texturePath)

            let primitive = launchPrimitive(63)
            primitive.state.renderFlag = EffectPrimitiveState.RenderFlag.alpha | EffectPrimitiveState.RenderFlag.customBlend
            primitive.state.duration = duration
            primitive.state.texturePaths = [texturePath]
            primitive.state.size = type == 3 ? 10.0 : 4.0

            let step = type == 3 ? -20 : -10
            for index in 0..<3 {
                primitive.state.slots[index].life = 1
                primitive.state.slots[index].process = index * step
                primitive.state.slots[index].fullDisplayAngle = 360
                primitive.state.slots[index].maxHeight = 6.001
                primitive.state.slots[index].rotStart = Int16(index * 25)
                primitive.state.slots[index].alphaB = 0
                primitive.state.slots[index].distance = 0
                primitive.state.slots[index].riseAngle = Int16(index + 2)
                primitive.state.slots[index].alphaT = 3111
                primitive.state.slots[index].vecBNow.y = 0
                primitive.state.slots[index].height = Array(repeating: 0, count: 21)
                primitive.state.slots[index].flag1 = Array(repeating: 1, count: 21)
            }
            primitive.state.slots[3].life = 0
            primitive.state.slots[3].process = 0
            primitive.state.slots[3].alphaT = Int16(type)
        }

        if stateCnt == 2 {
            let texturePath = "effect\\cloud11.tga"
            _ = context.assets?.texture(atPath: texturePath)

            let primitive = launchPrimitive(.pp_wind)
            primitive.state.renderFlag = EffectPrimitiveState.RenderFlag.alpha | EffectPrimitiveState.RenderFlag.customBlend
            primitive.state.duration = duration
            primitive.state.texturePaths = [texturePath]
            primitive.state.size = type == 3 ? 10.0 : 4.0

            for index in 0..<4 {
                primitive.state.slots[index].life = 1
                primitive.state.slots[index].process = 0
                primitive.state.slots[index].fullDisplayAngle = 30
                primitive.state.slots[index].maxHeight = 1.5 + Float(index) * 2.0
                primitive.state.slots[index].rotStart = Int16(index * 90)
                primitive.state.slots[index].alphaB = 0
                primitive.state.slots[index].distance = 9.0 - Float(index) * 1.5
                primitive.state.slots[index].riseAngle = 90
                primitive.state.slots[index].alphaT = 0
                primitive.state.slots[index].height = Array(repeating: 1.5, count: 21)
                primitive.state.slots[index].flag1 = Array(repeating: 0, count: 21)
            }
        }
    }

    // MARK: - EF_WARPZONE2 (321)

    /// Spawns persistent warp ripples (`PP_3DCIRCLE` (12), `PP_3DCASTING_4` (65)) and orbiting sparks (`PP_3DPARTICLEORBIT` (7)) for `EF_WARPZONE2` (321).
    func alphaDownRipples(texturePath: String, kind: Int8, context: EffectTickContext) {
        if stateCnt == 99_999_998 {
            stateCnt = 0
        } else {
            if stateCnt == 1 {
                launchRippleRings(texturePath: texturePath, kind: kind, smallSize: 11.0, turn: 0, growth: 0, context: context)
            }
            if stateCnt == 2 {
                launchRippleRings(texturePath: texturePath, kind: kind, smallSize: 4.0, turn: 1, growth: 0.2, context: context)
            }
        }

        if stateCnt == 0 {
            let auraTex = "effect\\alpha_down.tga"
            _ = context.assets?.texture(atPath: auraTex)

            let circle = launchPrimitive(.pp_3dcircle)
            circle.state.duration = 99_999_999
            circle.state.pattern |= 1
            circle.state.radius = 15.0
            circle.state.deltaPos2.y -= 1.5
            circle.state.latitude = 90.0
            circle.state.alpha = 0
            circle.state.maxAlpha = 128.0
            circle.state.alphaSpeed = circle.state.maxAlpha / 10.0
            circle.state.fadeOutCnt = circle.state.duration - 10
            circle.initSegment()
            circle.state.texturePaths = [auraTex]
        }

        guard stateCnt % 10 == 0 else {
            return
        }

        let spritePath = K2L("이팩트\\particle1.spr")
        let actionPath = K2L("이팩트\\particle1.act")
        _ = context.assets?.spriteAsset(spritePath: spritePath, actionPath: actionPath)

        let orbit = launchPrimitive(.pp_3dparticleorbit)
        orbit.state.radius = Float(Int.random(in: 0..<200) / 100) * 0.75 + 4.5
        orbit.state.radiusSpeed = 0.0005
        orbit.state.duration = 70
        orbit.state.longitude = Float(Int.random(in: 0..<360))
        if Int.random(in: 0..<2) == 0 {
            orbit.state.longSpeed = 2.5 - Float(Int.random(in: 0..<11)) * 0.1
        } else {
            orbit.state.longSpeed = Float(Int.random(in: 0..<11)) * 0.1 - 2.5
        }
        orbit.state.gravSpeed = -0.3
        orbit.state.gravAccel = -(orbit.state.gravSpeed / Float(orbit.state.duration)) / 1.5
        let rotY = EffectSpace.rotationY(radians: EffectSpace.radian(degrees: Int(orbit.state.longitude)))
        orbit.state.transform = rotY
        orbit.state.deltaPos2 = EffectSpace.transformVector(SIMD3<Float>(0, 0, orbit.state.radius), by: rotY)
        orbit.state.size = Float(Int.random(in: 0..<10) / 10) + 0.7
        orbit.state.fadeOutCnt = orbit.state.duration - orbit.state.duration / 3
        orbit.state.spritePath = spritePath
        orbit.state.actionPath = actionPath
        orbit.initSegment()
    }

    private func launchRippleRings(
        texturePath: String,
        kind: Int8,
        smallSize: Float,
        turn: Int,
        growth: Float,
        context: EffectTickContext
    ) {
        _ = context.assets?.texture(atPath: texturePath)

        let primitive = launchPrimitive(.pp_3dcasting_4)
        primitive.state.renderFlag = EffectPrimitiveState.RenderFlag.alpha | EffectPrimitiveState.RenderFlag.customBlend
        primitive.state.duration = duration
        primitive.state.texturePaths = [texturePath]
        if kind == 0 {
            primitive.state.size = smallSize
        } else if kind == 1 {
            primitive.state.size = 18.0
        }

        let slots: [(rotStart: Int16, distance: Float, riseAngle: Int16)] = [
            (Int16(270 + turn), 2.5 + growth, Int16(53 - turn)),
            (Int16(0 + turn), 5.0 + growth, Int16(60 - turn)),
            (Int16(90 + turn), 7.5 + growth, Int16(55 - turn)),
            (Int16(180 + turn), 10.0 + growth, Int16(50 - turn)),
        ]
        for (index, slot) in slots.enumerated() {
            primitive.state.slots[index].life = 1
            primitive.state.slots[index].process = 0
            primitive.state.slots[index].fullDisplayAngle = 360
            primitive.state.slots[index].rotStart = slot.rotStart
            primitive.state.slots[index].alphaB = 0
            primitive.state.slots[index].distance = slot.distance
            primitive.state.slots[index].maxHeight = slot.distance
            primitive.state.slots[index].riseAngle = slot.riseAngle
            primitive.state.slots[index].vecBNow.y = 0
            primitive.state.slots[index].height = Array(repeating: 0, count: 21)
            primitive.state.slots[index].flag1 = Array(repeating: 0, count: 21)
        }
    }

    // MARK: - EF_FOOT (326)

    /// Spawns fading footprint decal (`67`) for `EF_FOOT` (326) and `EF_FOOT2` (327).
    func texturedRise(texturePath: String, large: Int8, context: EffectTickContext) {
        guard stateCnt == 0 else {
            return
        }

        _ = context.assets?.texture(atPath: texturePath)

        let primitive = launchPrimitive(67)
        primitive.state.renderFlag = EffectPrimitiveState.RenderFlag.alpha
        primitive.state.duration = duration
        primitive.state.texturePaths = [texturePath]
        primitive.state.size = large == 1 ? 100.0 : 0
        primitive.state.slots[0].life = 1
        for i in 1..<4 {
            primitive.state.slots[i].life = 0
        }
        primitive.state.slots[0].process = 0
        primitive.state.slots[0].distance = large == 1 ? 6.0 : 5.0
        primitive.state.slots[0].riseAngle = 0
        primitive.state.slots[0].rotStart = Int16(truncatingIfNeeded: Int(deltaPos.x))
        primitive.state.slots[0].alphaB = 150
        primitive.state.slots[0].height[0] = -0.2
    }

    // MARK: - EF_BEGINASURA (328)

    /// Spawns casting rings and 6 Asura calligraphic halo layers (`PP_ASURACASTING` (68)) for `EF_BEGINASURA` (328).
    func beginAsura(kind: Int8, context: EffectTickContext) {
        if stateCnt == 0 {
            if duration < 350 {
                duration = 350
            }
            context.world.playSound(
                named: "effect\\EF_BeginSpell.wav",
                atWorldPosition: EffectSpace.toWorldPosition(position),
                delay: 0
            )
            texturedQuadRingSized(baseAlpha: 45, texturePath: "effect\\ring_white.tga", kind: 2, context: context)
            texturedQuadRingSized(baseAlpha: 25, texturePath: "effect\\ring_white.tga", kind: 2, context: context)
        }

        if stateCnt == 1 || stateCnt == 21 {
            let isSecondWave = stateCnt == 21
            let textures: [String] = if !isSecondWave {
                kind == 0
                    ? ["effect\\asura3.tga", "effect\\asura2.tga", "effect\\asura1.tga"]
                    : ["effect\\asura13.tga", "effect\\asura12.tga", "effect\\asura11.tga"]
            } else {
                kind == 0
                    ? ["effect\\asura4.tga", "effect\\asura5.tga", "effect\\asura6.tga"]
                    : ["effect\\asura14.tga", "effect\\asura15.tga", "effect\\asura16.tga"]
            }
            for path in textures {
                _ = context.assets?.texture(atPath: path)
            }

            let primitive = launchPrimitive(.pp_asuracasting)
            primitive.state.renderFlag = EffectPrimitiveState.RenderFlag.alpha | EffectPrimitiveState.RenderFlag.customBlend
            primitive.state.duration = duration
            primitive.state.totalTexture = 3
            primitive.state.texturePaths = textures
            primitive.state.size = 0
            primitive.state.slots[3].life = 0

            for index in 0..<3 {
                primitive.state.slots[index].life = 1
                primitive.state.slots[index].process = isSecondWave ? (-40 - index * 20) : (index * 20 - 40)
                primitive.state.slots[index].alphaB = 0
                primitive.state.slots[index].flag1[0] = Int8(index)
                let sign: Float = isSecondWave ? 1.0 : -1.0
                if kind == 0 {
                    primitive.state.slots[index].distance = 18.0
                    primitive.state.slots[index].height[0] = sign * Float(6 + index * 12)
                    primitive.state.slots[index].flag1[4] = 0
                } else {
                    primitive.state.slots[index].distance = 24.0
                    primitive.state.slots[index].height[0] = sign * Float(8 + index * 16)
                    primitive.state.slots[index].flag1[4] = 3
                }
                for h in 1..<11 {
                    primitive.state.slots[index].height[h] = 0
                }
            }
        }
    }

    // MARK: - EF_TRIPLEATTACK (329)

    /// Spawns directional cloud rush streaks (`69`) and triple hit sounds for `EF_TRIPLEATTACK` (329).
    func cloudDrift(context: EffectTickContext) {
        if stateCnt <= 1 {
            let texturePath = "effect\\cloud11.tga"
            _ = context.assets?.texture(atPath: texturePath)

            let primitive = launchPrimitive(69)
            primitive.state.renderFlag = EffectPrimitiveState.RenderFlag.alpha | EffectPrimitiveState.RenderFlag.customBlend
            primitive.state.duration = duration
            primitive.state.texturePaths = [texturePath]
            primitive.state.size = 0
            primitive.state.deltaPos = deltaPos

            let dx = deltaPos.x - position.x
            let dz = deltaPos.z - position.z
            let rotStart = EffectPrimitive.angle(dx: dx, dy: dz)
            let cosVal = EffectSpace.cosine(degrees: Int(rotStart))
            let sinVal = EffectSpace.sine(degrees: Int(rotStart))

            for index in 0..<4 {
                primitive.state.slots[index].life = 1
                primitive.state.slots[index].process = -Int.random(in: 0..<20)
                primitive.state.slots[index].rotStart = rotStart
                primitive.state.slots[index].alphaB = 0
                let offset = Float(Int.random(in: 0..<100)) * 0.15
                let baseX = Float(Int.random(in: 0..<100)) * 0.06 - 3.0 + position.x - cosVal * offset
                let baseZ = Float(Int.random(in: 0..<100)) * 0.06 - 3.0 + position.z - sinVal * offset
                primitive.state.slots[index].height[1] = offset
                primitive.state.slots[index].vecBNow = SIMD3<Float>(baseX, position.y, baseZ)
                primitive.state.slots[index].vecTNow = SIMD3<Float>(baseX, position.y, baseZ)
                primitive.state.slots[index].maxHeight = 0.25
                primitive.state.slots[index].height[0] = Float(Int.random(in: 0..<100)) * 0.04 + 8.0
                primitive.state.slots[index].distance = Float(Int.random(in: 0..<100)) * 0.2 + 20.0
                primitive.state.slots[index].height[4] = 0
            }
        }

        if stateCnt == 10 || stateCnt == 30 {
            context.world.playSound(
                named: "effect\\EF_hit2.wav",
                atWorldPosition: EffectSpace.toWorldPosition(position),
                delay: 0
            )
        } else if stateCnt == 20 {
            context.world.playSound(
                named: "effect\\EF_hit4.wav",
                atWorldPosition: EffectSpace.toWorldPosition(position),
                delay: 0
            )
        }
    }

    // MARK: - EF_HPTIME (331)

    /// Spawns rising HP/SP recovery sparkles (`PP_PARTICLE_UP` (59)) for `EF_HPTIME` (331) and `EF_SPTIME` (332).
    func texturedRisingOrbs(texturePath: String, kind: Int8, context: EffectTickContext) {
        if stateCnt == 0 {
            if kind == 0 {
                context.world.playSound(
                    named: "_heal_effect.wav",
                    atWorldPosition: EffectSpace.toWorldPosition(position),
                    delay: 0
                )
            } else if kind == 1 {
                context.world.playSound(
                    named: K2L("effect\\흡기.wav"),
                    atWorldPosition: EffectSpace.toWorldPosition(position),
                    delay: 0
                )
            }
        }

        guard stateCnt <= 20, stateCnt % 4 == 0 else {
            return
        }

        let tex0 = kind == 2 ? texturePath : "effect\\pok1.tga"
        let tex1 = kind == 2 ? texturePath : "effect\\pok3.tga"
        _ = context.assets?.texture(atPath: tex0)
        _ = context.assets?.texture(atPath: tex1)

        let primitive = launchPrimitive(.pp_particle_up)
        primitive.state.renderFlag = EffectPrimitiveState.RenderFlag.alpha | EffectPrimitiveState.RenderFlag.customBlend
        primitive.state.duration = duration
        primitive.state.totalTexture = 2
        primitive.state.texturePaths = [tex0, tex1]
        primitive.state.size = 0
        primitive.position = position

        for index in 0..<4 {
            primitive.state.slots[index].life = 1
            primitive.state.slots[index].process = 0
            if kind == 2 {
                if index >= 2 {
                    primitive.state.slots[index].life = 0
                } else {
                    primitive.state.slots[index].distance = Float(Int.random(in: 0..<11)) * 0.1 + 2.0
                }
                primitive.state.slots[index].vecBNow.x = Float(Int.random(in: 0..<19)) + position.x - 9.0
                primitive.state.slots[index].vecBNow.z = Float(Int.random(in: 0..<19)) + position.z - 9.0
            } else {
                primitive.state.slots[index].distance = Float(Int.random(in: 0..<10)) * 0.1 + 1.5
                primitive.state.slots[index].vecBNow.x = Float(Int.random(in: 0..<7)) + position.x - 3.0
                primitive.state.slots[index].vecBNow.z = Float(Int.random(in: 0..<7)) + position.z - 3.0
            }
            primitive.state.slots[index].height[8] = 0
            primitive.state.slots[index].alphaB = 0
            primitive.state.slots[index].vecBNow.y = position.y - 6.0
            primitive.state.slots[index].rotStart = 0
            primitive.state.slots[index].height[1] = 0
            primitive.state.slots[index].height[2] = Float(Int.random(in: 0..<20)) * 0.01 + 0.2
            primitive.state.slots[index].fullDisplayAngle = 0
            primitive.state.slots[index].flag1[0] = 0
            primitive.state.slots[index].flag1[1] = 1
            if kind == 0 || kind == 2 {
                primitive.state.slots[index].flag1[2] = 11
            } else if kind == 3 {
                primitive.state.slots[index].flag1[2] = 18
            } else {
                primitive.state.slots[index].flag1[2] = 1
            }
            primitive.state.slots[index].height[7] = 0
        }
    }

    // MARK: - EF_MAPLE (333)

    /// Spawns falling autumn maple leaves (`PP_SAKURA` (40)) for `EF_MAPLE` (333).
    func maple(context: EffectTickContext) {
        if stateCnt == 99_999_998 {
            duration = 99_999_999
            stateCnt = 0
        } else if (stateCnt & 1) != 0 || stateCnt >= 200 {
            return
        }

        let spritePath = K2L("이팩트\\단풍.spr")
        let actionPath = K2L("이팩트\\단풍.act")
        _ = context.assets?.spriteAsset(spritePath: spritePath, actionPath: actionPath)

        let leaf = launchPrimitive(.pp_sakura)
        leaf.state.duration = duration
        leaf.state.slots[0].life = 1
        leaf.state.slots[0].maxHeight = Float(Int.random(in: 0..<4) + 2) * 0.03
        leaf.state.size = Float(Int.random(in: 0..<6) + 35) / 100.0
        for h in 0..<4 {
            leaf.state.slots[0].height[h] = Float(Int.random(in: 0..<360))
        }
        leaf.state.slots[0].vecBPre = SIMD3<Float>(
            Float(Int.random(in: 0..<300)) + position.x - 150.0,
            position.y - 200.0,
            Float(Int.random(in: 0..<300)) + position.z - 150.0
        )
        leaf.state.slots[0].flag1[0] = 1
        leaf.state.alpha = 200.0
        leaf.state.spritePath = spritePath
        leaf.state.actionPath = actionPath
        leaf.currentMotion = 0
        leaf.initSegment()
        for i in 1..<4 {
            leaf.state.slots[i].life = 0
        }
    }

    // MARK: - EF_BLIND (334)

    /// Spawns darkness vignette overlay (`PP_BLIND` (71)) for `EF_BLIND` (334).
    func blind(flag: Int8, context: EffectTickContext) {
        guard stateCnt == 0 else {
            return
        }

        let textures = ["effect\\fullb.tga", "effect\\white02.bmp"]
        for path in textures {
            _ = context.assets?.texture(atPath: path)
        }

        let primitive = launchPrimitive(.pp_blind)
        primitive.state.renderFlag |= 0x200
        primitive.state.duration = duration
        primitive.state.totalTexture = 2
        primitive.state.texturePaths = textures
        position.y -= 9.0
        for i in 1..<4 {
            primitive.state.slots[i].life = 0
        }
        primitive.state.slots[0].life = 1
        primitive.state.slots[0].process = 0
        if flag == 0 {
            primitive.state.slots[0].distance = 65.0
            primitive.state.slots[0].flag1[0] = 0
        } else {
            primitive.state.slots[0].distance = 140.0 - Float(flag) * 10.0
            primitive.state.slots[0].flag1[0] = 1
        }
        primitive.state.slots[0].alphaB = 0
    }

    // MARK: - EF_JOBLVUP50 (337)

    /// Spawns Job Level 50 celebration rays (`PP_SLASH1` (75)) and advances `JobLvUP.str` for `EF_JOBLVUP50` (337).
    func jobLvUp50(angle: Int, context: EffectTickContext) -> Bool {
        if stateCnt == 0 && angle == 0 {
            configureSTR(path: "JobLvUP.str")
        }

        if stateCnt == 5 {
            let texturePath = "effect\\magic_green.tga"
            _ = context.assets?.texture(atPath: texturePath)

            let primitive = launchPrimitive(.pp_slash1)
            primitive.state.renderFlag = EffectPrimitiveState.RenderFlag.alpha | EffectPrimitiveState.RenderFlag.customBlend
            primitive.state.duration = duration
            primitive.state.texturePaths = [texturePath]
            primitive.state.size = 9.0

            for index in 0..<4 {
                primitive.state.slots[index].life = 1
                primitive.state.slots[index].process = 0
                primitive.state.slots[index].maxHeight = 2.0
                primitive.state.slots[index].rotStart = Int16(index * 90 + angle)
                primitive.state.slots[index].alphaB = 0
                primitive.state.slots[index].distance = 2.0
                primitive.state.slots[index].height[0] = 1.0
                primitive.state.slots[index].flag1[0] = 0
            }
        }

        if angle == 0 {
            return processEZ2STRRaised(context: context)
        }
        return true
    }

    // MARK: - EF_ANGEL2 (338)

    /// Spawns Super Novice guardian angel and feather sprites (`PP_SUPERANGEL` (85)) plus celebration rays (`PP_SLASH1` (75)) for `EF_ANGEL2` (338).
    func superAngel(type: Int8, context: EffectTickContext) {
        if stateCnt == 0 || (stateCnt <= 18 && (type == 1 || type == 11) && stateCnt % 3 == 0) {
            let primitive = launchPrimitive(.pp_superangel)
            primitive.state.duration = duration
            primitive.state.slots[0].process = 0
            primitive.state.slots[0].life = 1
            primitive.state.size = 1.0
            primitive.state.slots[0].vecBNow = SIMD3<Float>(position.x, position.y - 40.0, position.z)
            primitive.state.slots[0].flag1[0] = type
            primitive.state.slots[0].flag1[1] = Int8(truncatingIfNeeded: stateCnt)
            primitive.state.alpha = 0

            let spritePath: String
            let actionPath: String
            switch type {
            case 0:
                spritePath = K2L("이팩트\\천사.spr")
                actionPath = K2L("이팩트\\천사.act")
                primitive.state.renderFlag = EffectPrimitiveState.RenderFlag.alpha | EffectPrimitiveState.RenderFlag.customBlend
            case 1:
                spritePath = K2L("이팩트\\천사날개.spr")
                actionPath = K2L("이팩트\\천사날개.act")
                primitive.state.renderFlag = EffectPrimitiveState.RenderFlag.alpha | EffectPrimitiveState.RenderFlag.customBlend
            case 2:
                spritePath = K2L("이팩트\\깃털1.spr")
                actionPath = K2L("이팩트\\깃털1.act")
                primitive.state.renderFlag = EffectPrimitiveState.RenderFlag.alpha | EffectPrimitiveState.RenderFlag.customBlend
            case 3:
                spritePath = K2L("이팩트\\깃털2.spr")
                actionPath = K2L("이팩트\\깃털2.act")
                primitive.state.renderFlag = EffectPrimitiveState.RenderFlag.alpha | EffectPrimitiveState.RenderFlag.customBlend
            case 4:
                spritePath = K2L("이팩트\\깃털3.spr")
                actionPath = K2L("이팩트\\깃털3.act")
                primitive.state.renderFlag = EffectPrimitiveState.RenderFlag.alpha | EffectPrimitiveState.RenderFlag.customBlend
            case 10:
                spritePath = K2L("이팩트\\한복천사.spr")
                actionPath = K2L("이팩트\\한복천사.act")
                primitive.state.renderFlag = EffectPrimitiveState.RenderFlag.alpha | EffectPrimitiveState.RenderFlag.noDepth
                primitive.state.slots[0].vecBNow.y = position.y - 30.0
            case 11:
                spritePath = K2L("이팩트\\한복천사(날개).spr")
                actionPath = K2L("이팩트\\한복천사(날개).act")
                primitive.state.renderFlag = EffectPrimitiveState.RenderFlag.alpha | EffectPrimitiveState.RenderFlag.customBlend
                primitive.state.slots[0].vecBNow.y = position.y - 30.0
            default:
                spritePath = ""
                actionPath = ""
            }

            if !spritePath.isEmpty {
                _ = context.assets?.spriteAsset(spritePath: spritePath, actionPath: actionPath)
                primitive.state.spritePath = spritePath
                primitive.state.actionPath = actionPath
            }
            primitive.currentMotion = 0
            primitive.state.repeatAnim = true
            primitive.previousAnimation = 0
            primitive.initSegment()
            for i in 1..<4 {
                primitive.state.slots[i].life = 0
            }
        }

        guard type == 0 || type == 10 else {
            return
        }

        if stateCnt == 65 || stateCnt == 66 {
            let texturePath = "effect\\ring_blue.tga"
            _ = context.assets?.texture(atPath: texturePath)
            let angleOffset = stateCnt == 66 ? 45 : 0

            let primitive = launchPrimitive(.pp_slash1)
            primitive.state.renderFlag = EffectPrimitiveState.RenderFlag.alpha | EffectPrimitiveState.RenderFlag.customBlend
            primitive.state.duration = duration
            primitive.state.texturePaths = [texturePath]
            primitive.state.size = 4.0

            for index in 0..<4 {
                primitive.state.slots[index].life = 1
                primitive.state.slots[index].process = 0
                primitive.state.slots[index].maxHeight = 2.0
                primitive.state.slots[index].rotStart = Int16(angleOffset + index * 90)
                primitive.state.slots[index].alphaB = 0
                primitive.state.slots[index].distance = 2.0
                primitive.state.slots[index].height[0] = 1.0
                primitive.state.slots[index].flag1[0] = 0
            }
        }
    }

    // MARK: - EF_CALLZONE (340)

    /// Spawns expanding half-sphere recall zone (`74`) at tick 100 for `EF_CALLZONE` (340).
    func callZone(texturePath: String, context: EffectTickContext) {
        guard stateCnt == 100 else {
            return
        }

        _ = context.assets?.texture(atPath: texturePath)

        let primitive = launchPrimitive(74)
        primitive.state.renderFlag = EffectPrimitiveState.RenderFlag.alpha | EffectPrimitiveState.RenderFlag.customBlend
        primitive.state.duration = duration
        primitive.state.totalTexture = 1
        primitive.state.texturePaths = [texturePath]
        position.y -= 10.0
        for i in 1..<4 {
            primitive.state.slots[i].life = 0
        }
        primitive.state.slots[0].life = 1
        primitive.state.slots[0].process = 0
        primitive.state.slots[0].distance = 8.0
        primitive.state.slots[0].alphaB = 0
        primitive.state.slots[0].fullDisplayAngle = 360
    }

    // MARK: - EF_COUPLECASTING (342)

    /// Spawns dual spell-casting rings and plays begin-spell audio for `EF_COUPLECASTING` (342).
    func texturedSpellRings(texturePath: String, context: EffectTickContext) {
        guard stateCnt == 0 else {
            return
        }

        context.world.playSound(
            named: "effect\\EF_BeginSpell.wav",
            atWorldPosition: EffectSpace.toWorldPosition(position),
            delay: 0
        )
        texturedQuadRingSized(baseAlpha: 45, texturePath: texturePath, kind: 3, context: context)
        texturedQuadRingSized(baseAlpha: 25, texturePath: texturePath, kind: 3, context: context)
    }

    // MARK: - EF_HEARTCASTING (343)

    private func processHeartCasting(context: EffectTickContext) {
        guard stateCnt == 0 else {
            return
        }

        context.world.playSound(
            named: "effect\\EF_BeginSpell.wav",
            atWorldPosition: EffectSpace.toWorldPosition(position),
            delay: 0
        )

        let cell: Float = 0.27
        let heartPoints: [(Float, Float)] = [
            (0, 37), (-13, 44), (-29, 48), (-46, 42), (-56, 26),
            (-57, 6), (-51, -12), (-40, -26), (-25, -38), (-10, -47),
            (0, -60), (11, -47), (26, -38), (41, -26), (52, -12),
            (58, 6), (57, 26), (47, 42), (30, 48), (14, 44),
        ]
        for (dx, dz) in heartPoints {
            ringRedPulse(texturePath: "effect\\ring_red.tga", x: dx * cell, z: dz * cell, context: context)
        }
    }

    /// Spawns a two-layer pulsing red heart ring (`110`) at offset `(x, z)` for `EF_HEARTCASTING` (343).
    func ringRedPulse(texturePath: String, x: Float, z: Float, context: EffectTickContext) {
        guard stateCnt == 0 else {
            return
        }

        _ = context.assets?.texture(atPath: texturePath)

        let primitive = launchPrimitive(110)
        primitive.state.renderFlag = EffectPrimitiveState.RenderFlag.alpha | EffectPrimitiveState.RenderFlag.customBlend
        primitive.state.duration = duration
        primitive.state.texturePaths = [texturePath]
        primitive.state.size = 10.0

        let alphaT = Int16(clamping: duration - 25)
        let configs: [(maxHeight: Float, distance: Float, riseAngle: Int16)] = [
            (12.0, 2.3, 86),
            (25.0, 2.0, 90),
        ]
        for (index, config) in configs.enumerated() {
            primitive.state.slots[index].life = 1
            primitive.state.slots[index].process = 0
            primitive.state.slots[index].fullDisplayAngle = 360
            primitive.state.slots[index].maxHeight = config.maxHeight
            primitive.state.slots[index].rotStart = Int16(Int.random(in: 0..<360))
            primitive.state.slots[index].alphaB = 0
            primitive.state.slots[index].distance = config.distance
            primitive.state.slots[index].riseAngle = config.riseAngle
            primitive.state.slots[index].alphaT = alphaT
            primitive.state.slots[index].vecBNow = SIMD3<Float>(x, 1234.5, z)
            primitive.state.slots[index].height = Array(repeating: 0, count: 21)
            primitive.state.slots[index].flag1 = Array(repeating: 33, count: 21)
        }
        primitive.state.slots[2].life = 0
        primitive.state.slots[3].life = 0
    }

    // MARK: - EF_ENTRY2 (344)

    /// Spawns 4-layer blue portal entry rings (`60`) and plays portal audio for `EF_ENTRY2` (344).
    func portalRings(context: EffectTickContext) {
        guard stateCnt == 0 else {
            return
        }

        context.world.playSound(
            named: "effect\\EF_Portal.wav",
            atWorldPosition: EffectSpace.toWorldPosition(position),
            delay: 0
        )

        let texturePath = "effect\\ring_blue.tga"
        _ = context.assets?.texture(atPath: texturePath)

        let primitive = launchPrimitive(60)
        primitive.state.renderFlag = EffectPrimitiveState.RenderFlag.alpha | EffectPrimitiveState.RenderFlag.customBlend
        primitive.state.duration = duration
        primitive.state.texturePaths = [texturePath]
        primitive.state.size = 4.0

        let configs: [(maxHeight: Float, distance: Float, riseAngle: Int16)] = [
            (30.0, 3.7, 90),
            (30.0, 3.4, 90),
            (4.0, 3.6, 10),
            (4.0, 3.7, 5),
        ]
        for (index, config) in configs.enumerated() {
            primitive.state.slots[index].life = 1
            primitive.state.slots[index].process = 0
            primitive.state.slots[index].fullDisplayAngle = 360
            primitive.state.slots[index].maxHeight = config.maxHeight
            primitive.state.slots[index].rotStart = Int16(Int.random(in: 0..<360))
            primitive.state.slots[index].alphaB = 0
            primitive.state.slots[index].distance = config.distance
            primitive.state.slots[index].riseAngle = config.riseAngle
            primitive.state.slots[index].alphaT = 1400
            primitive.state.slots[index].vecBNow.y = 0
            primitive.state.slots[index].height = Array(repeating: 0, count: 21)
            primitive.state.slots[index].flag1 = Array(repeating: 2, count: 21)
        }
    }

    // MARK: - EF_SPHEREWIND (346)

    /// Spawns 4-slot orbiting wind ivy ribbons (`PP_SPHEREWIND` (77)) for `EF_SPHEREWIND` (346) and `EF_SPHEREWIND2` (394).
    func featherRing(texturePath: String, angle: Int16, large: Int8, context: EffectTickContext) {
        guard stateCnt == 0 else {
            return
        }

        _ = context.assets?.texture(atPath: texturePath)

        let primitive = launchPrimitive(.pp_spherewind)
        primitive.state.renderFlag = EffectPrimitiveState.RenderFlag.alpha | EffectPrimitiveState.RenderFlag.customBlend
        primitive.state.duration = duration
        primitive.state.totalTexture = 1
        primitive.state.texturePaths = [texturePath]
        primitive.state.size = large == 1 ? 10.0 : 4.0

        for index in 0..<4 {
            primitive.state.slots[index].life = 1
            primitive.state.slots[index].process = 0
            primitive.state.slots[index].maxHeight = Float(Int.random(in: 0..<11)) * 0.2 + 4.0
            primitive.state.slots[index].distance = 14.0
            primitive.state.slots[index].height[0] = -14.0
            primitive.state.slots[index].rotStart = Int16(Int.random(in: 0..<360))
            primitive.state.slots[index].riseAngle = Int16(index * 45) + angle
            primitive.state.slots[index].alphaB = 100
            primitive.state.slots[index].fullDisplayAngle = Int16(Int.random(in: 0..<91) + 180)
            primitive.state.slots[index].height[1] = Float(Int.random(in: 0..<4) + 3)
        }
    }

    // MARK: - EF_COLORPAPER (347)

    /// Spawns fluttering confetti quads (`PP_COLORPAPER` (78)) for `EF_COLORPAPER` (347).
    func weddingBurst(texturePath: String, silent: Int8, context: EffectTickContext) {
        guard stateCnt == 0 else {
            return
        }

        if silent == 0 {
            context.world.playSound(
                named: "effect\\wedding.wav",
                atWorldPosition: EffectSpace.toWorldPosition(position),
                delay: 0
            )
        }

        _ = context.assets?.texture(atPath: texturePath)

        let primitive = launchPrimitive(.pp_colorpaper)
        primitive.state.renderFlag = EffectPrimitiveState.RenderFlag.alpha | EffectPrimitiveState.RenderFlag.customBlend
        primitive.state.duration = duration
        primitive.state.totalTexture = 1
        primitive.state.texturePaths = [texturePath]

        for index in 0..<4 {
            primitive.state.slots[index].life = 1
            primitive.state.slots[index].process = 0
            primitive.state.slots[index].maxHeight = Float(Int.random(in: 0..<31)) * 0.01 + 0.3
            primitive.state.slots[index].rotStart = Int16(Int.random(in: 0..<360))
            primitive.state.slots[index].riseAngle = Int16(index * 45)
            primitive.state.slots[index].alphaB = 0
            primitive.state.slots[index].height[0] = Float(Int.random(in: 0..<360))
            primitive.state.slots[index].height[1] = Float(Int.random(in: 0..<360))
            primitive.state.slots[index].height[2] = Float(Int.random(in: 0..<360))
            primitive.state.slots[index].vecBNow = SIMD3<Float>(
                Float(Int.random(in: 0..<101) - 50),
                Float(-110 - Int.random(in: 0..<50)),
                Float(Int.random(in: 0..<101) - 50)
            )
            primitive.state.slots[index].distance = Float(Int.random(in: 0..<26)) * 0.01 + 0.25
            primitive.state.slots[index].fullDisplayAngle = 0
        }
    }

    // MARK: - EF_LIGHTSPHERE (348)

    /// Spawns a facing aura panel (`82`) with `kind`-configured radius, lift, and tint for `EF_LIGHTSPHERE` (348).
    func texturedAura(texturePath: String, kind: Int8, context: EffectTickContext) {
        guard stateCnt == 0 else {
            return
        }

        _ = context.assets?.texture(atPath: texturePath)

        let primitive = launchPrimitive(82)
        primitive.state.renderFlag = EffectPrimitiveState.RenderFlag.alpha | EffectPrimitiveState.RenderFlag.customBlend
        primitive.state.duration = duration
        primitive.state.texturePaths = [texturePath]
        primitive.state.size = 0

        for index in 1..<4 {
            primitive.state.slots[index].life = 0
        }

        primitive.state.slots[0].life = 1
        primitive.state.slots[0].process = 0

        switch kind {
        case 1:
            primitive.state.slots[0].distance = 8.0
            primitive.state.slots[0].vecBPre.y = position.y - 30.0
            primitive.state.slots[0].flag1[2] = 0
            primitive.state.slots[0].height[10] = 1.0
            primitive.state.slots[0].fullDisplayAngle = 120
        case 2:
            primitive.state.slots[0].distance = 10.0
            primitive.state.slots[0].vecBPre.y = position.y - 10.0
            primitive.state.slots[0].flag1[2] = 2
            primitive.state.slots[0].height[10] = 0
            primitive.state.slots[0].fullDisplayAngle = 135
        case 3:
            primitive.state.slots[0].distance = 8.0
            primitive.state.slots[0].vecBPre.y = position.y - 30.0
            primitive.state.slots[0].flag1[2] = 3
            primitive.state.slots[0].height[10] = 2.0
            primitive.state.slots[0].fullDisplayAngle = 155
        case 4:
            primitive.state.slots[0].distance = 6.0
            primitive.state.slots[0].vecBPre.y = position.y - 30.0
            primitive.state.slots[0].flag1[2] = 0
            primitive.state.slots[0].height[10] = 0
            primitive.state.slots[0].fullDisplayAngle = 135
        case 10...11:
            let p0 = param[0]
            primitive.state.slots[0].distance = p0 <= 0 ? 70.0 : p0 * 0.7
            primitive.state.slots[0].vecBPre.y = position.y
            primitive.state.slots[0].flag1[2] = 10
            primitive.state.slots[0].height[10] = 0
            primitive.state.slots[0].fullDisplayAngle = Int16(Int.random(in: 0..<360))
        case 12:
            let p0 = param[0]
            primitive.state.slots[0].distance = p0 <= 0 ? 120.0 : p0 * 1.2
            primitive.state.slots[0].vecBPre.y = position.y
            primitive.state.slots[0].flag1[2] = 12
            primitive.state.slots[0].height[10] = 0
            primitive.state.slots[0].fullDisplayAngle = Int16(Int.random(in: 0..<360))
        case 13:
            let p0 = param[0]
            primitive.state.slots[0].distance = p0 <= 0 ? 300.0 : p0 * 3.0
            primitive.state.slots[0].vecBPre.y = position.y
            primitive.state.slots[0].flag1[2] = 12
            primitive.state.slots[0].height[10] = 0
            primitive.state.slots[0].fullDisplayAngle = Int16(Int.random(in: 0..<360))
        case 14:
            let p0 = param[0]
            primitive.state.slots[0].distance = p0 <= 0 ? 30.0 : p0
            primitive.state.slots[0].vecBPre.y = position.y
            primitive.state.slots[0].flag1[2] = 4
            primitive.state.slots[0].height[10] = 0
            primitive.state.slots[0].fullDisplayAngle = Int16(Int.random(in: 0..<360))
        case 15:
            let p0 = param[0]
            primitive.state.slots[0].distance = p0 <= 0 ? 30.0 : p0
            primitive.state.slots[0].vecBPre.y = position.y
            primitive.state.slots[0].flag1[2] = 15
            primitive.state.slots[0].height[10] = 0
            primitive.state.slots[0].fullDisplayAngle = Int16(Int.random(in: 0..<360))
        case 16...17:
            let p0 = param[0]
            var distance = p0 <= 0 ? 9.5 : p0 * 0.9
            if kind == 17 {
                distance *= 0.85
            }
            primitive.state.slots[0].distance = distance
            primitive.state.slots[0].vecBPre.y = position.y
            primitive.state.slots[0].flag1[2] = 5
            primitive.state.slots[0].height[10] = 0
            primitive.state.slots[0].fullDisplayAngle = Int16(Int.random(in: 0..<360))
        case 18:
            let p0 = param[0]
            primitive.state.slots[0].distance = p0 <= 0 ? 9.0 : p0 * 0.9
            primitive.state.slots[0].vecBPre.y = position.y
            primitive.state.slots[0].flag1[2] = 5
            primitive.state.slots[0].height[10] = 0
            primitive.state.slots[0].fullDisplayAngle = Int16(Int.random(in: 0..<360))
        case 19:
            primitive.state.slots[0].distance = 8.0
            primitive.state.slots[0].vecBPre.y = position.y - 30.0
            primitive.state.slots[0].flag1[2] = 15
            primitive.state.slots[0].height[10] = 0
            primitive.state.slots[0].fullDisplayAngle = Int16(Int.random(in: 0..<360))
        case 20:
            primitive.state.slots[0].distance = 2.4
            primitive.state.slots[0].vecBPre.y = position.y - 27.0
            primitive.state.slots[0].flag1[2] = 0
            primitive.state.slots[0].height[10] = 0
            primitive.state.slots[0].fullDisplayAngle = 135
        case 21:
            primitive.state.slots[0].distance = 24.0
            primitive.state.slots[0].vecBPre.y = position.y - 10.0
            primitive.state.slots[0].flag1[2] = 4
            primitive.state.slots[0].height[10] = 0
            primitive.state.slots[0].fullDisplayAngle = 90
        case 22:
            primitive.state.slots[0].distance = 4.0
            let lift: Float
            if let headHeight = (targetObjectID ?? ownerObjectID).flatMap({ context.world.targetState(for: $0)?.headHeight }),
               headHeight != 0 {
                lift = -headHeight * EffectSpace.worldToEffectScale - 4.0
            } else {
                lift = -30.0
            }
            primitive.state.slots[0].vecBPre.y = position.y + lift
            primitive.state.slots[0].flag1[2] = 16
            primitive.state.slots[0].height[10] = 0
            primitive.state.slots[0].fullDisplayAngle = 135
        case 30:
            primitive.state.slots[0].distance = 24.0
            primitive.state.slots[0].vecBPre.y = position.y - 30.0
            primitive.state.slots[0].flag1[2] = 19
            primitive.state.slots[0].height[10] = 0
            primitive.state.slots[0].fullDisplayAngle = 135
        case 31:
            primitive.state.slots[0].distance = 2.0
            primitive.state.slots[0].vecBPre.y = position.y - 30.0
            primitive.state.slots[0].flag1[2] = 0
            primitive.state.slots[0].height[10] = 0
            primitive.state.slots[0].fullDisplayAngle = 135
        case 32:
            primitive.state.slots[0].distance = 8.0
            primitive.state.slots[0].vecBPre.y = position.y - 30.0
            primitive.state.slots[0].flag1[2] = 32
            primitive.state.slots[0].height[10] = 0
            primitive.state.slots[0].fullDisplayAngle = Int16(Int.random(in: 0..<360))
        default:
            primitive.state.slots[0].distance = 5.0
            primitive.state.slots[0].vecBPre.y = position.y - 10.0
            primitive.state.slots[0].flag1[2] = 2
            primitive.state.slots[0].height[10] = 0
            primitive.state.slots[0].fullDisplayAngle = 135
        }

        primitive.state.slots[0].height[8] = 0
        primitive.state.slots[0].alphaB = 0
        primitive.state.slots[0].vecBNow.x = position.x
        primitive.state.slots[0].vecBNow.z = position.z
        primitive.state.slots[0].rotStart = Int16(Int.random(in: 0..<360))
        primitive.state.slots[0].flag1[0] = 0
        primitive.state.slots[0].flag1[4] = kind == 4 ? 1 : kind
        primitive.state.slots[0].height[15] = position.y - primitive.state.slots[0].vecBPre.y
    }

    /// Spawns 4-slot orbiting blue-white light sparkles (`81`) for `EF_LIGHTSPHERE` (348) and `EF_LIGHTSPHERE2` (381).
    func texturedSparkle(texturePath: String, context: EffectTickContext) {
        guard stateCnt == 0 else {
            return
        }

        _ = context.assets?.texture(atPath: texturePath)

        let primitive = launchPrimitive(81)
        primitive.state.renderFlag = EffectPrimitiveState.RenderFlag.alpha | EffectPrimitiveState.RenderFlag.customBlend
        primitive.state.duration = duration
        primitive.state.totalTexture = 2
        primitive.state.texturePaths = [texturePath]

        for index in 0..<4 {
            primitive.state.slots[index].life = 1
            primitive.state.slots[index].process = 0
            primitive.state.slots[index].alphaB = 40
            primitive.state.slots[index].distance = 1.0
            primitive.state.slots[index].height[3] = 10.0
            primitive.state.slots[index].riseAngle = Int16(Int.random(in: 0..<360))
            primitive.state.slots[index].rotStart = Int16(Int.random(in: 0..<360))
            primitive.state.slots[index].fullDisplayAngle = Int16(Int.random(in: 0..<360))
            primitive.state.slots[index].maxHeight = Float(Int.random(in: 0..<2) + 1)

            if Int.random(in: 0..<2) == 0 {
                primitive.state.slots[index].height[0] = 105.0
                primitive.state.slots[index].height[1] = 105.0
                primitive.state.slots[index].height[2] = 255.0
            } else {
                primitive.state.slots[index].height[0] = 55.0
                primitive.state.slots[index].height[1] = 55.0
                primitive.state.slots[index].height[2] = 225.0
            }
        }
    }

    // MARK: - EF_WATERFALL (349)

    /// Spawns 4-layer animated waterfall sheets (`79`) for `EF_WATERFALL*` (349...356).
    func waterfall(flag: Int8, tall: Int8, variant: Int8, context: EffectTickContext) {
        guard stateCnt == 0 else {
            return
        }

        let textures: [String] = if variant == 1 {
            ["effect\\waterfall31.tga", "effect\\waterfall32.tga", "effect\\waterfall33.tga"]
        } else {
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

        let heightParam = Int8(truncatingIfNeeded: Int(param[0]))
        for index in 0..<4 {
            primitive.state.slots[index].life = 1
            primitive.state.slots[index].process = 0
            primitive.state.slots[index].alphaB = 80
            primitive.state.slots[index].flag1[0] = flag
            if tall == 0 {
                primitive.state.slots[index].distance = Float(36 + index)
            } else if tall == 1 {
                primitive.state.slots[index].distance = Float(18 + index)
            }
            primitive.state.slots[index].flag1[2] = heightParam
            for h in 0..<20 {
                primitive.state.slots[index].height[h] = Float(h * 40)
            }
            primitive.state.slots[index].vecBNow.z = Float(index) - 1.0
            primitive.state.slots[index].maxHeight = Float(80 - index * 13)
            primitive.state.slots[index].flag1[1] = 0
        }
    }

    /// Spawns 4-slot mist/spray scatter quads (`80`) at waterfall bases for `EF_WATERFALL*` (349...356).
    func frostScatter(swapAxes: Int8, narrow: Int8, context: EffectTickContext) {
        guard stateCnt == 0 else {
            return
        }

        let isDroplet = Int.random(in: 0..<10) == 0
        let texturePath = isDroplet ? "effect\\waterp1.tga" : "effect\\freeze_a_small.bmp"
        _ = context.assets?.texture(atPath: texturePath)

        let primitive = launchPrimitive(80)
        primitive.state.renderFlag = EffectPrimitiveState.RenderFlag.alpha | EffectPrimitiveState.RenderFlag.customBlend
        primitive.state.duration = duration
        primitive.state.totalTexture = 1
        primitive.state.texturePaths = [texturePath]
        primitive.state.size = 4.0

        func randomAnchor() -> SIMD3<Float> {
            var x: Float = narrow == 0
                ? Float(Int.random(in: 0..<45) - 22)
                : Float(Int.random(in: 0..<23) - 11)
            let y = Float(Int.random(in: 0..<30))
            var z = Float(Int.random(in: 0..<11) - 5)
            if swapAxes == 1 {
                let temp = Float(Int(x))
                x = z
                z = temp
            }
            return SIMD3<Float>(x, y, z)
        }

        for index in 0..<4 {
            primitive.state.slots[index].life = 1
            primitive.state.slots[index].maxHeight = 0.05
            primitive.state.slots[index].flag1[11] = swapAxes
            primitive.state.slots[index].flag1[12] = narrow
            primitive.state.slots[index].distance = isDroplet ? 7.0 : 4.5
            primitive.state.slots[index].vecBPre = randomAnchor()
            primitive.state.slots[index].vecBNow = randomAnchor()
            primitive.state.slots[index].vecTPre = randomAnchor()
            primitive.state.slots[index].vecTNow = randomAnchor()
            for h in 0..<16 {
                primitive.state.slots[index].height[h] = Float(Int.random(in: 0..<360))
            }
            primitive.state.slots[index].flag1[0] = 2
        }
    }

    // MARK: - EF_GHOST (358)

    /// Spawns orbiting ghost or bat sprites (`PP_GHOST` (84)) for `EF_GHOST` (358), `EF_BAT` (359), and `EF_BAT2` (360).
    func ghost(type: Int8, context: EffectTickContext) {
        guard stateCnt < 10 else {
            return
        }

        let spritePath = type == 0 ? K2L("이팩트\\유령.spr") : K2L("이팩트\\박쥐.spr")
        let actionPath = type == 0 ? K2L("이팩트\\유령.act") : K2L("이팩트\\박쥐.act")
        _ = context.assets?.spriteAsset(spritePath: spritePath, actionPath: actionPath)

        let primitive = launchPrimitive(.pp_ghost)
        primitive.state.duration = duration
        primitive.state.slots[0].process = 0
        primitive.state.slots[0].life = 1
        primitive.state.size = 1.5
        primitive.state.slots[0].vecBNow = position
        primitive.state.slots[0].rotStart = 0
        primitive.state.slots[0].riseAngle = 0

        if type == 2 {
            primitive.state.slots[0].flag1[0] = 2
            primitive.state.slots[0].height[1] = stateCnt == 0 ? 250.0 : Float((10 - stateCnt) * 3)
        } else {
            primitive.state.slots[0].flag1[0] = 1
            primitive.state.slots[0].height[1] = Float((10 - stateCnt) * 3)
        }

        primitive.state.slots[0].flag1[2] = type
        primitive.state.slots[0].distance = 16.0
        primitive.state.slots[0].maxHeight = 4.0
        primitive.state.alpha = 0
        primitive.state.spritePath = spritePath
        primitive.state.actionPath = actionPath
        primitive.state.animSpeed = 2
        primitive.state.renderFlag |= EffectPrimitiveState.RenderFlag.noDepth
        primitive.currentMotion = 0
        primitive.initSegment()
        for i in 1..<4 {
            primitive.state.slots[i].life = 0
        }
    }

    // MARK: - EF_SOULBREAKER (361)

    /// Spawns 4-slot slash wave bursts (`86`) for `EF_SOULBREAKER` (361).
    func sonicWave(sonic: Int8, context: EffectTickContext) {
        guard stateCnt == 0 else {
            return
        }

        let textures: [String] = if sonic == 1 {
            [
                "effect\\sonic_wave1.tga",
                "effect\\sonic_wave2.tga",
                "effect\\sonic_wave3.tga",
                "effect\\sonic_wave4.tga",
            ]
        } else {
            ["effect\\purpleslash.tga"]
        }
        for path in textures {
            _ = context.assets?.texture(atPath: path)
        }

        let primitive = launchPrimitive(86)
        primitive.state.renderFlag = EffectPrimitiveState.RenderFlag.alpha | EffectPrimitiveState.RenderFlag.customBlend
        primitive.state.duration = duration
        primitive.state.totalTexture = textures.count
        primitive.state.texturePaths = textures
        primitive.state.size = 0
        primitive.state.deltaPos = deltaPos
        primitive.position = position

        for index in 0..<4 {
            primitive.state.slots[index].life = 1
            primitive.state.slots[index].alphaB = 0
            primitive.state.slots[index].process = index - 28
            primitive.state.slots[index].distance = 20.0
            primitive.state.slots[index].vecBNow = SIMD3<Float>(
                position.x,
                Float(Int.random(in: 0..<5)) + (position.y - 10.0),
                position.z
            )
            primitive.state.slots[index].rotStart = 0
            primitive.state.slots[index].height[1] = 0.8
            primitive.state.slots[index].flag1[0] = 0
            primitive.state.slots[index].flag1[1] = sonic
        }
    }

    // MARK: - EF_VALLENTINE (363)

    /// Spawns Valentine/event animated sprite (`PP_3DPARTICLE` (5)) for `EF_VALLENTINE` (363) and `EF_VALLENTINE2` (364).
    func vallentine(kind: Int8, context: EffectTickContext) {
        guard stateCnt == 0 else {
            return
        }

        context.world.playSound(
            named: "effect\\vallentine.wav",
            atWorldPosition: EffectSpace.toWorldPosition(position),
            delay: 0
        )

        let primitive = launchPrimitive(.pp_3dparticle)
        primitive.state.pattern |= 0x200
        primitive.state.duration = duration
        primitive.state.deltaPos2.y = 0
        primitive.state.animSpeed = 2
        primitive.state.repeatAnim = false

        let spritePath: String
        let actionPath: String
        switch kind {
        case 2:
            spritePath = K2L("이팩트\\05vallentine.spr")
            actionPath = K2L("이팩트\\05vallentine.act")
            primitive.currentMotion = 0
        case 3:
            spritePath = K2L("이팩트\\fast.spr")
            actionPath = K2L("이팩트\\fast.act")
            primitive.state.animSpeed = 4
            primitive.currentMotion = 0
        case 4:
            primitive.state.renderFlag |= 0x200
            spritePath = K2L("이팩트\\ro2effect.spr")
            actionPath = K2L("이팩트\\ro2effect.act")
            primitive.state.animSpeed = 4
            primitive.currentMotion = 0
        default:
            spritePath = K2L("이팩트\\vallentine.spr")
            actionPath = K2L("이팩트\\vallentine.act")
            primitive.currentMotion = Int(kind)
        }

        _ = context.assets?.spriteAsset(spritePath: spritePath, actionPath: actionPath)
        primitive.state.spritePath = spritePath
        primitive.state.actionPath = actionPath
        primitive.initSegment()
    }

    // MARK: - EF_PRESSURE (365)

    /// Spawns descending textured panel (`87`) for `EF_PRESSURE` (365).
    func texturedRain(texturePath: String, kind: Int8, context: EffectTickContext) {
        guard stateCnt == 0 else {
            return
        }

        _ = context.assets?.texture(atPath: texturePath)

        let primitive = launchPrimitive(87)
        primitive.state.renderFlag = EffectPrimitiveState.RenderFlag.alpha | EffectPrimitiveState.RenderFlag.customBlend
        primitive.state.duration = duration
        primitive.state.texturePaths = [texturePath]
        primitive.state.size = 0

        primitive.state.slots[0].life = 1
        primitive.state.slots[0].process = 0
        if kind == 0 {
            primitive.state.slots[0].distance = 12.0
            primitive.state.slots[0].vecBPre = SIMD3<Float>(0, -115.0, 0)
        } else if kind == 4 {
            primitive.state.slots[0].distance = 14.0
            primitive.state.slots[0].vecBPre = SIMD3<Float>(0, -115.0 - Float(Int.random(in: 0..<56)), 0)
        } else {
            primitive.state.slots[0].distance = 8.0
            primitive.state.slots[0].vecBPre = SIMD3<Float>(0, -80.0, 0)
        }
        primitive.state.slots[0].alphaB = 0
        primitive.state.slots[0].rotStart = 0
        primitive.state.slots[0].height[1] = 3.0
        primitive.state.slots[0].fullDisplayAngle = Int16(Int.random(in: 0..<360))
        primitive.state.slots[0].flag1[0] = 0
        primitive.state.slots[0].flag1[2] = 7

        if kind == 1 {
            primitive.state.slots[0].flag1[2] = 9
            primitive.state.slots[0].flag1[3] = 1
        } else if kind == 2 {
            primitive.state.slots[0].flag1[2] = 9
            primitive.state.slots[0].flag1[3] = 3
        } else if kind == 3 {
            primitive.state.slots[0].flag1[2] = 9
            primitive.state.slots[0].flag1[3] = 4
        }

        primitive.state.slots[0].flag1[4] = kind
        for index in 1..<4 {
            primitive.state.slots[index].life = 1
            primitive.state.slots[index].alphaB = 0
        }
    }

    /// Spawns level-tinted impact ring (`88`) for `EF_PRESSURE` (365).
    func texturedLevelRing(texturePath: String, process: Int, level: Int8, context: EffectTickContext) {
        guard stateCnt == 0 else {
            return
        }

        _ = context.assets?.texture(atPath: texturePath)

        let primitive = launchPrimitive(88)
        primitive.state.renderFlag = EffectPrimitiveState.RenderFlag.alpha | EffectPrimitiveState.RenderFlag.customBlend
        primitive.state.duration = duration
        primitive.state.totalTexture = 1
        primitive.state.texturePaths = [texturePath]

        switch level {
        case 1: primitive.state.size = 101.0
        case 2: primitive.state.size = 102.0
        case 3: primitive.state.size = 111.0
        case 4: primitive.state.size = 113.0
        case 10: primitive.state.size = 114.0
        default: break
        }

        primitive.state.slots[0].life = 1
        primitive.state.slots[0].process = process
        if level == 3 {
            primitive.state.slots[0].distance = 13.0
            primitive.state.slots[0].height[0] = -5.0 - Float(Int.random(in: 0..<6))
        } else {
            primitive.state.slots[0].distance = 15.0
            primitive.state.slots[0].height[0] = -5.0
        }
        primitive.state.slots[0].riseAngle = 0
        primitive.state.slots[0].alphaB = 0
        for i in 1..<4 {
            primitive.state.slots[i].life = 0
        }
    }

    // MARK: - EF_BASH3D (366)

    /// Spawns 4-slot spinning fan beams (`89`) for `EF_BASH3D` (366), `EF_BASH3D2` (377), `EF_TRUESIGHT` (386), and `EF_BASH3D3` (399).
    func texturedQuadSpin(texturePath: String, phase: Int8, kind: Int8, context: EffectTickContext) {
        guard stateCnt == 0 else {
            return
        }

        _ = context.assets?.texture(atPath: texturePath)

        let primitive = launchPrimitive(89)
        primitive.state.renderFlag = EffectPrimitiveState.RenderFlag.alpha | EffectPrimitiveState.RenderFlag.customBlend
        primitive.state.duration = duration
        primitive.state.texturePaths = [texturePath]

        let initialProcess = (kind == 2 || kind == 3 || kind == 6) ? 0 : -24
        let phaseStep = kind == 3 ? 7 : 22

        for ec in 0..<4 {
            primitive.state.slots[ec].life = 1
            primitive.state.slots[ec].height[4] = Float(kind)
            primitive.state.slots[ec].process = initialProcess
            primitive.state.slots[ec].distance = 2.0
            primitive.state.slots[ec].riseAngle = Int16(90 * ec + Int(phase) * phaseStep)
            primitive.state.slots[ec].rotStart = Int16(Int.random(in: 0..<360))
            primitive.state.slots[ec].alphaB = 0
            primitive.state.slots[ec].height[0] = -12.0
        }
    }

    // MARK: - EF_AURABLADE (367)

    /// Spawns white and yellow aura rings for `EF_AURABLADE` (367).
    func whiteYellowRings(context: EffectTickContext) {
        guard stateCnt == 0 else {
            return
        }

        texturedQuadRingSized(baseAlpha: 45, texturePath: "effect\\ring_white.tga", kind: 22, context: context)
        texturedQuadRingSized(baseAlpha: 25, texturePath: "effect\\ring_yellow.tga", kind: 22, context: context)
    }

    // MARK: - EF_DRAGONSMOKE (373)

    private func processDragonSmoke(context: EffectTickContext) {
        guard stateCnt == 0 else {
            return
        }

        let spritePath = K2L("이팩트\\굴뚝연기.spr")
        let actionPath = K2L("이팩트\\굴뚝연기.act")
        _ = context.assets?.spriteAsset(spritePath: spritePath, actionPath: actionPath)

        let smoke = launchPrimitive(.pp_3dparticle, deltaPos: deltaPos)
        smoke.state.duration = duration
        smoke.state.rollSpeed = 0.75
        let rotX = EffectSpace.rotationX(radians: EffectSpace.radian(degrees: Int.random(in: 0..<30) + 75))
        let rotY = EffectSpace.rotationY(radians: EffectSpace.radian(degrees: Int.random(in: 0..<360)))
        smoke.state.transform = rotY * rotX
        smoke.state.deltaPos2.y = -9.0
        smoke.state.speed = Float(Int.random(in: 0..<3) + 3) / 10.0
        smoke.state.size = 1.5
        smoke.state.fadeOutCnt = smoke.state.duration - smoke.state.duration / 3
        smoke.state.spritePath = spritePath
        smoke.state.actionPath = actionPath
        smoke.initSegment()
    }

    // MARK: - EF_ENERGYDRAIN2 (378)

    /// Spawns 3 light-blue draining spline ribbons (`PP_3DPARTICLESPLINE` (8)) for `EF_ENERGYDRAIN2` (378).
    func energyDrain2(context: EffectTickContext) {
        guard stateCnt == 0 else {
            return
        }

        let spritePath = K2L("이팩트\\particle1.spr")
        let actionPath = K2L("이팩트\\particle1.act")
        _ = context.assets?.spriteAsset(spritePath: spritePath, actionPath: actionPath)

        let midX = deltaPos.x - (deltaPos.x - position.x) * 0.5
        let midZ = deltaPos.z - (deltaPos.z - position.z) * 0.5
        let faceX = position.x + position.x - deltaPos.x
        let faceZ = position.z + position.z - deltaPos.z

        for angle in stride(from: -90, to: 180, by: 90) {
            let spline = launchPrimitive(.pp_3dparticlespline)
            spline.state.duration = 60
            spline.state.deltaPos2 = SIMD3<Float>(deltaPos.x - position.x, -10.0, deltaPos.z - position.z)
            spline.state.radius = Self.effectDistanceXZ(from: spline.position, to: SIMD3<Float>(midX, 0, midZ))
            let heading = Self.effectHeading(fromX: spline.position.x, fromZ: spline.position.z, toX: faceX, toZ: faceZ)
            spline.angle = heading
            spline.state.longitude = -heading
            let speed = spline.state.radius / Float(spline.state.duration)
            spline.state.speed = speed + speed
            spline.state.gravSpeed = 2.0
            let rise = -(spline.state.gravSpeed / Float(spline.state.duration))
            spline.state.gravAccel = rise + rise
            spline.state.latiSpeed = -2.0
            let spread = -(spline.state.latiSpeed / Float(spline.state.duration))
            spline.state.latiAccel = spread + spread
            spline.state.roll = Float(angle)
            let rotY = EffectSpace.rotationY(radians: EffectSpace.radian(degrees: Int(spline.state.longitude)))
            spline.state.transform = rotY
            let forward = EffectSpace.transformVector(SIMD3<Float>(0, 0, 1), by: rotY)
            spline.state.deltaPos3 = forward
            spline.state.rotAxis = forward
            spline.state.red = Int.random(in: 0..<81) + 160
            spline.state.green = Int.random(in: 0..<81) + 160
            spline.state.blue = 255
            spline.state.size = Float(Int.random(in: 0..<6)) * 0.1 + 1.5
            spline.state.spritePath = spritePath
            spline.state.actionPath = actionPath
            spline.state.numSegment = 7
            spline.initSegment()
        }
    }

    // MARK: - EF_ENERGYDRAIN3 (383)

    /// Spawns 3 tinted sonic-slash spline ribbons (`PP_3DPARTICLESPLINE` (8)) for ticks `0...4` of `EF_ENERGYDRAIN3` (383).
    func sonicSlashFan(kind: Int8, context: EffectTickContext) {
        guard stateCnt <= 4 else {
            return
        }

        let spritePath = K2L("이팩트\\particle1.spr")
        let actionPath = K2L("이팩트\\particle1.act")
        _ = context.assets?.spriteAsset(spritePath: spritePath, actionPath: actionPath)

        for angle in stride(from: -90, to: 180, by: 90) {
            let spline = launchPrimitive(.pp_3dparticlespline)
            spline.state.duration = 60
            spline.state.deltaPos2 = SIMD3<Float>(0, -10.0, 0)
            spline.state.radius = Self.effectDistanceXZ(from: spline.position, to: position)
            let faceX = Float(Int.random(in: 0..<7)) + position.x - 3.0
            let faceZ = Float(Int.random(in: 0..<7)) + position.z - 3.0
            let heading = Self.effectHeading(fromX: spline.position.x, fromZ: spline.position.z, toX: faceX, toZ: faceZ)
            spline.angle = heading
            spline.state.longitude = -heading
            let speed = spline.state.radius / Float(spline.state.duration)
            spline.state.speed = speed + speed
            spline.state.gravSpeed = 2.0
            let rise = -(spline.state.gravSpeed / Float(spline.state.duration))
            spline.state.gravAccel = rise + rise
            spline.state.latiSpeed = -2.0
            let spread = -(spline.state.latiSpeed / Float(spline.state.duration))
            spline.state.latiAccel = spread + spread
            spline.state.roll = Float(angle)
            let rotY = EffectSpace.rotationY(radians: EffectSpace.radian(degrees: Int(spline.state.longitude)))
            spline.state.transform = rotY
            let forward = EffectSpace.transformVector(SIMD3<Float>(0, 0, 1), by: rotY)
            spline.state.deltaPos3 = forward
            spline.state.rotAxis = forward

            if kind == 0 {
                spline.state.red = Int.random(in: 0..<81) + 160
                spline.state.green = 255
                spline.state.blue = Int.random(in: 0..<81) + 160
            } else if kind == 1 {
                let color = Int.random(in: 0..<55) + 200
                spline.state.red = color
                spline.state.green = color
                spline.state.blue = color
            } else if kind == 2 {
                let color = Int.random(in: 0..<100) + 20
                spline.state.red = color
                spline.state.green = color
                spline.state.blue = color
            }

            spline.state.size = Float(Int.random(in: 0..<6)) * 0.1 + 1.0
            spline.state.spritePath = spritePath
            spline.state.actionPath = actionPath
            spline.state.numSegment = 7
            spline.initSegment()
        }
    }

    // MARK: - EF_TRIPLEATTACK2 (388)

    /// Spawns directional piercing trail streaks (`69`) for ticks `0...3` of `EF_TRIPLEATTACK2` (388).
    func alphaCenterTrail(context: EffectTickContext) {
        guard stateCnt <= 3 else {
            return
        }

        let texturePath = "effect\\alpha_center.tga"
        _ = context.assets?.texture(atPath: texturePath)

        let primitive = launchPrimitive(69)
        primitive.state.renderFlag = EffectPrimitiveState.RenderFlag.alpha | EffectPrimitiveState.RenderFlag.customBlend
        primitive.state.duration = duration
        primitive.state.texturePaths = [texturePath]
        primitive.state.size = 0
        primitive.state.deltaPos = deltaPos

        let deltaX = deltaPos.x - position.x
        let deltaZ = deltaPos.z - position.z
        let distance = sqrt(deltaZ * deltaZ + deltaX * deltaX)
        let rotStart = EffectPrimitive.angle(dx: deltaX, dy: deltaZ)
        let cosVal = EffectSpace.cosine(degrees: Int(rotStart))
        let sinVal = EffectSpace.sine(degrees: Int(rotStart))

        for index in 0..<4 {
            primitive.state.slots[index].life = 1
            primitive.state.slots[index].process = -45 - Int.random(in: 0..<20)
            primitive.state.slots[index].rotStart = rotStart
            primitive.state.slots[index].alphaB = 0
            let offset = Float(Int.random(in: 0..<100)) * 0.15
            let baseX = Float(Int.random(in: 0..<100)) * 0.08 - 4.0 + position.x - cosVal * offset
            let baseZ = Float(Int.random(in: 0..<100)) * 0.08 - 4.0 + position.z - sinVal * offset
            primitive.state.slots[index].height[1] = offset
            primitive.state.slots[index].vecBNow = SIMD3<Float>(baseX, position.y, baseZ)
            primitive.state.slots[index].vecTNow = SIMD3<Float>(baseX, position.y, baseZ)
            primitive.state.slots[index].maxHeight = 0.05
            primitive.state.slots[index].height[0] = Float(Int.random(in: 0..<100)) * 0.04 + 8.0
            primitive.state.slots[index].distance = Float(Int.random(in: 0..<100)) * 0.6 + distance
            primitive.state.slots[index].height[4] = 2.0
        }
    }

    // MARK: - EF_PORTAL4 (389)

    /// Spawns 4-slot swirling wind cloud burst (`PP_WIND` (62)) for `EF_PORTAL4` (389).
    func cloud11Burst(kind: Int8, context: EffectTickContext) {
        guard stateCnt == 0 else {
            return
        }

        let texturePath = "effect\\cloud11.tga"
        _ = context.assets?.texture(atPath: texturePath)

        let primitive = launchPrimitive(.pp_wind)
        primitive.state.renderFlag = EffectPrimitiveState.RenderFlag.alpha | EffectPrimitiveState.RenderFlag.customBlend
        primitive.state.duration = duration
        primitive.state.texturePaths = [texturePath]
        primitive.state.size = kind == 1 ? 8.0 : 5.0

        for i in 0..<4 {
            primitive.state.slots[i].life = 1
            primitive.state.slots[i].process = 0
            primitive.state.slots[i].fullDisplayAngle = 30

            if kind == 1 {
                primitive.state.slots[i].maxHeight = Float(i) * 2.0 + 3.0
            } else if kind == 2 {
                primitive.state.slots[i].maxHeight = 48.0 - Float(i) * 5.0
            } else if kind == 3 {
                primitive.state.slots[i].maxHeight = 28.0 - Float(i) * 5.0
            } else {
                primitive.state.slots[i].maxHeight = Float(i) * 2.0 + 5.0
            }

            primitive.state.slots[i].rotStart = Int16(i * 90)
            primitive.state.slots[i].alphaB = 0

            if kind >= 2 {
                primitive.state.slots[i].alphaT = 2
                if kind == 2 {
                    primitive.state.slots[i].distance = 14.0 - Float(i) * 2.0
                } else if kind == 3 {
                    primitive.state.slots[i].distance = 6.0 - Float(i)
                } else {
                    primitive.state.slots[i].distance = Float(Int.random(in: 0..<101)) * 0.03 + 4.5
                }
            } else {
                primitive.state.slots[i].alphaT = 1
                if kind == 1 {
                    primitive.state.slots[i].distance = Float(Int.random(in: 0..<101)) * 0.01 + 2.5
                } else {
                    primitive.state.slots[i].distance = Float(Int.random(in: 0..<101)) * 0.03 + 4.5
                }
            }

            primitive.state.slots[i].riseAngle = Int16(Int.random(in: 0..<21) + 80)
            primitive.state.slots[i].height = Array(repeating: 1.0, count: 21)
            primitive.state.slots[i].flag1 = Array(repeating: 0, count: 21)
        }
    }

    // MARK: - EF_TRIPLEATTACK3 (393)

    /// Spawns directional rapid-fire stream streaks (`69`) for ticks `0...8` of `EF_TRIPLEATTACK3` (393).
    func alphaCenterStream(context: EffectTickContext) {
        guard stateCnt <= 8 else {
            return
        }

        let texturePath = "effect\\alpha_center.tga"
        _ = context.assets?.texture(atPath: texturePath)

        let primitive = launchPrimitive(69)
        primitive.state.renderFlag = EffectPrimitiveState.RenderFlag.alpha | EffectPrimitiveState.RenderFlag.customBlend
        primitive.state.duration = duration
        primitive.state.texturePaths = [texturePath]
        primitive.state.size = 0
        primitive.state.deltaPos = deltaPos

        let dx = deltaPos.x - position.x
        let dz = deltaPos.z - position.z
        let range = sqrt(dz * dz + dx * dx)
        let rotStart = EffectPrimitive.angle(dx: dx, dy: dz)
        let cosVal = EffectSpace.cosine(degrees: Int(rotStart))
        let sinVal = EffectSpace.sine(degrees: Int(rotStart))

        for i in 0..<4 {
            primitive.state.slots[i].life = 1
            primitive.state.slots[i].process = -30 - Int.random(in: 0..<110)
            primitive.state.slots[i].rotStart = rotStart
            primitive.state.slots[i].alphaB = 0
            let offset = Float(Int.random(in: 0..<100)) * 0.15
            let baseX = Float(Int.random(in: 0..<100)) * 0.08 - 4.0 + position.x - cosVal * offset
            let baseZ = Float(Int.random(in: 0..<100)) * 0.08 - 4.0 + position.z - sinVal * offset
            primitive.state.slots[i].height[1] = offset
            primitive.state.slots[i].vecBNow = SIMD3<Float>(baseX, position.y, baseZ)
            primitive.state.slots[i].vecTNow = SIMD3<Float>(baseX, position.y, baseZ)
            primitive.state.slots[i].maxHeight = Float(Int.random(in: 0..<11)) * 0.008 + 0.02
            primitive.state.slots[i].height[0] = Float(Int.random(in: 0..<100)) * 0.06 + 4.0
            primitive.state.slots[i].distance = Float(Int.random(in: 0..<100)) * 0.3 + range
            primitive.state.slots[i].height[4] = 3.0
        }
    }

    // MARK: - EF_LINELINK3 (395)

    /// Spawns a wide `PP_LINELINK` (38) target-tracking link for `EF_LINELINK3` (395).
    func trackTargetWide(context: EffectTickContext) {
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
        primitive.state.slots[0].maxHeight = 0.7
        primitive.state.slots[0].height[4] = 3.0
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
