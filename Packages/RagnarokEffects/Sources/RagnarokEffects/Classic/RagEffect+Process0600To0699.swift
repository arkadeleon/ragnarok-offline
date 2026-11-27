//
//  RagEffect+Process0600To0699.swift
//  RagnarokEffects
//
//  Created by Leon Li on 2026/11/26.
//

import Foundation
import RagnarokCore
import simd

extension RagEffect {
    nonisolated static let proceduralEffectIDs0600To0699: [EffectID] = [
        .ef_throwitem6,
        .ef_sight2,
        .ef_quakebody4,
        .ef_npc_stop2,
        .ef_npc_stop2_del,
        .ef_fvoice,
        .ef_wink,
        .ef_temp_ok,
        .ef_temp_fail,
        .ef_hapgyeok,
        .ef_throwitem7,
        .ef_throwitem8,
        .ef_throwitem9,
        .ef_throwitem10,
        .ef_bunsinjyutsu,
        .ef_kouenka,
        .ef_hyousensou,
        .ef_bottom_suiton,
        .ef_stin4,
        .ef_thunderstorm2,
        .ef_chemical4,
        .ef_stin5,
        .ef_madness_blue,
        .ef_madness_red,
        .ef_rg_coin3,
        .ef_bash3d5,
        .ef_chookgi3,
        .ef_kirikage,
        .ef_tatami,
        .ef_kasumikiri,
        .ef_issen,
        .ef_kaen,
        .ef_desperado,
        .ef_lightning_s,
        .ef_blind_s,
        .ef_poison_s,
        .ef_freezing_s,
        .ef_flare_s,
        .ef_rapidshower,
        .ef_magicalbullet,
        .ef_spreadattack,
        .ef_tracking,
        .ef_tripleaction,
        .ef_map_magiczone,
        .ef_map_magiczone2,
        .ef_damage1,
        .ef_damage1_2,
        .ef_damage1_3,
        .ef_undeadbody,
        .ef_undeadbody_del,
        .ef_bubble_drop,
        .ef_npc_earthquake,
        .ef_da_space,
        .ef_bleeding,
        .ef_bottom_runner,
        .ef_bottom_transfer,
        .ef_crystal_blue,
        .ef_bottom_evilland,
        .ef_guard3,
        .ef_npc_slowcast,
        .ef_green99_3,
        .ef_green99_5,
        .ef_green99_6,
        .ef_mapsphere,
        .ef_pok_love,
        .ef_pok_white,
        .ef_pok_valen,
        .ef_pok_birth,
        .ef_pok_christmas,
        .ef_map_magiczone3,
        .ef_map_magiczone4,
        .ef_dust,
        .ef_torch_red,
        .ef_torch_green,
        .ef_map_ghost,
        .ef_glow1,
        .ef_glow2,
        .ef_glow4,
        .ef_torch_purple,
        .ef_cloud7,
        .ef_cloud8,
    ]

    func process0600To0699(context: EffectTickContext) -> Bool {
        switch effectID {
        case .ef_throwitem6:
            throwItem(texturePath: K2L("유저인터페이스\\item\\베넘나이프.bmp"), kind: 3, context: context)
        case .ef_sight2:
            if stateCnt % 2 == 0 {
                let angle = Int(Float(stateCnt) * -5.0)
                let sine = EffectSpace.sine(degrees: angle)
                let cosine = EffectSpace.cosine(degrees: angle)
                let spritePath = K2L("이팩트\\Sight.spr")
                let actionPath = K2L("이팩트\\Sight.act")
                _ = context.assets?.spriteAsset(spritePath: spritePath, actionPath: actionPath)

                let primitive = launchPrimitive(.pp_3dparticle)
                primitive.state.duration = 20
                primitive.state.deltaPos2 = SIMD3<Float>(sine * 15.0, -20.0, cosine * -15.0)
                primitive.state.deltaPosAccel.y = 0.1
                primitive.state.animSpeed = 3
                primitive.state.size = 2.5
                primitive.state.sizeSpeed = -0.1
                primitive.state.alpha = 50.0
                primitive.state.alphaSpeed = -3.0
                primitive.state.spritePath = spritePath
                primitive.state.actionPath = actionPath
                primitive.initSegment()
            }
        case .ef_quakebody4:
            if stateCnt == 20 {
                context.world.playSound(
                    named: "effect\\ef_hit6.wav",
                    atWorldPosition: EffectSpace.toWorldPosition(position),
                    delay: 0
                )
            }
            if stateCnt > 20, let targetID = targetObjectID ?? ownerObjectID {
                context.world.applyTargetModifier(.shake(amplitude: 2.0, durationTicks: 2), to: targetID)
                let color = stateCnt % 2 == 0
                    ? SIMD4<Float>(250.0 / 255.0, 50.0 / 255.0, 50.0 / 255.0, 1.0)
                    : SIMD4<Float>(1.0, 1.0, 1.0, 1.0)
                context.world.applyTargetModifier(.tint(color: color, durationTicks: 2), to: targetID)
            }
        case .ef_npc_stop2:
            npcStop(type: 2, context: context)
        case .ef_npc_stop2_del, .ef_damage1_2, .ef_damage1_3:
            break
        case .ef_fvoice:
            chimto(flag: 2, context: context)
        case .ef_wink:
            chimto(flag: 1, context: context)
        case .ef_temp_ok:
            if stateCnt == 0 {
                context.world.playSound(
                    named: "_heal_effect.wav",
                    atWorldPosition: EffectSpace.toWorldPosition(position),
                    delay: 0
                )
            }
            texturedAura(texturePath: "effect\\success.bmp", kind: 3, context: context)
        case .ef_temp_fail:
            if stateCnt == 0 {
                context.world.playSound(
                    named: "caramel_die.wav",
                    atWorldPosition: EffectSpace.toWorldPosition(position),
                    delay: 0
                )
            }
            texturedAura(texturePath: "effect\\failed.bmp", kind: 3, context: context)
        case .ef_hapgyeok:
            if stateCnt == 0 {
                configureSTR(path: "itempokjuk.str")
            }
            texturedClassChange(kind: 14, context: context)
            _ = processEZ2STR(offset: SIMD3<Float>(0, -80.0, 0), context: context)
        case .ef_throwitem7:
            throwItem(texturePath: K2L("유저인터페이스\\item\\수리검.bmp"), kind: 3, context: context)
        case .ef_throwitem8:
            throwItem(texturePath: K2L("유저인터페이스\\item\\쿠나이_독.bmp"), kind: 3, context: context)
        case .ef_throwitem9:
            throwItem(texturePath: K2L("유저인터페이스\\item\\풍마_열화.bmp"), kind: 3, context: context)
        case .ef_throwitem10:
            throwItem(texturePath: "effect\\coin_a.bmp", kind: 3, context: context)
        case .ef_bunsinjyutsu:
            spawnPaleBlur(context: context)
        case .ef_kouenka:
            sakuraFireArrow(context: context)
            for index in 0..<2 {
                texturedQuadSpin(texturePath: "effect\\alpha_center.tga", phase: Int8(index), kind: 2, context: context)
            }
        case .ef_hyousensou:
            earthSpike(type: 2, context: context)
        case .ef_bottom_suiton:
            texturedFlare(texturePath: "effect\\ring_blue.tga", size: 14, offsetX: 0, offsetZ: 0, context: context)
        case .ef_stin4:
            if stateCnt == 0 {
                context.world.playSound(
                    named: K2L("effect\\풍인.wav"),
                    atWorldPosition: EffectSpace.toWorldPosition(position),
                    delay: 0
                )
            }
            for index in 0..<max(0, count) {
                texturedSlashWave(texturePath: K2L("effect\\270바람.tga"), kind: Int8(index % 2), context: context)
            }
        case .ef_thunderstorm2:
            if stateCnt == 0 {
                context.world.playSound(
                    named: "effect\\EF_ThunderStorm.wav",
                    atWorldPosition: EffectSpace.toWorldPosition(position),
                    delay: 0
                )
                let spritePath = K2L("이팩트\\썬더스톰.spr")
                let actionPath = K2L("이팩트\\썬더스톰.act")
                _ = context.assets?.spriteAsset(spritePath: spritePath, actionPath: actionPath)

                let primitive = launchPrimitive(.pp_3dparticle)
                primitive.state.duration = duration
                primitive.state.renderFlag |= EffectPrimitiveState.RenderFlag.noDepth
                primitive.state.pattern |= 0x200
                primitive.state.deltaPos2.y = -4.5
                primitive.state.animSpeed = 2
                primitive.state.size = 2.5
                primitive.state.spritePath = spritePath
                primitive.state.actionPath = actionPath
                primitive.initSegment()
            }
        case .ef_chemical4:
            if stateCnt == 28 {
                context.world.playSound(
                    named: K2L("effect\\피어싱샷.wav"),
                    atWorldPosition: EffectSpace.toWorldPosition(position),
                    delay: 0
                )
            }
            for _ in 0..<4 {
                lineStreakLayered(kind: 20, context: context)
                lineStreakLayered(kind: 21, context: context)
            }
        case .ef_stin5:
            if stateCnt == 1 {
                context.world.playSound(
                    named: K2L("effect\\t_바람방출.wav"),
                    atWorldPosition: EffectSpace.toWorldPosition(position),
                    delay: 0
                )
            }
            texturedSlashCross(texturePath: K2L("effect\\270바람.tga"), context: context)
        case .ef_madness_blue:
            if stateCnt % 4 == 0, let targetID = targetObjectID ?? ownerObjectID,
               let alpha = Self.tintedOverlayAlpha(phase: 20) {
                context.world.applyTargetModifier(
                    .flash(color: SIMD4<Float>(5.0 / 255.0, 5.0 / 255.0, 1.0, alpha), durationTicks: 2),
                    to: targetID
                )
            }
        case .ef_madness_red:
            if stateCnt % 4 == 0, let targetID = targetObjectID ?? ownerObjectID,
               let alpha = Self.tintedOverlayAlpha(phase: 20) {
                context.world.applyTargetModifier(
                    .flash(color: SIMD4<Float>(1.0, 5.0 / 255.0, 5.0 / 255.0, alpha), durationTicks: 2),
                    to: targetID
                )
            }
        case .ef_rg_coin3:
            if stateCnt == 21 {
                context.world.playSound(
                    named: K2L("effect\\디스암.wav"),
                    atWorldPosition: EffectSpace.toWorldPosition(position),
                    delay: 0
                )
            }
            texturedSprayKind(texturePath: K2L("유저인터페이스\\item\\골드룩스.bmp"), spin: 5.0, kind: 0, context: context)
            texturedSprayKind(texturePath: K2L("유저인터페이스\\item\\더개리슨.bmp"), spin: 5.0, kind: 0, context: context)
            texturedSprayKind(texturePath: K2L("유저인터페이스\\item\\더블샷건.bmp"), spin: 5.0, kind: 0, context: context)
            texturedSprayKind(texturePath: K2L("유저인터페이스\\item\\더스크.bmp"), spin: 5.0, kind: 0, context: context)
        case .ef_bash3d5:
            if stateCnt == 0 {
                context.world.playSound(
                    named: K2L("effect\\더스트샷.wav"),
                    atWorldPosition: EffectSpace.toWorldPosition(position),
                    delay: 0
                )
            }
            for index in 0..<6 {
                texturedQuadSpin(texturePath: "effect\\alpha_center.tga", phase: Int8(index), kind: 5, context: context)
            }
        case .ef_chookgi3:
            elementalOrbit(kind: 3, context: context)
        case .ef_kirikage:
            if stateCnt == 0 {
                context.world.playSound(
                    named: K2L("effect\\그림자베기.wav"),
                    atWorldPosition: EffectSpace.toWorldPosition(position),
                    delay: 0
                )
            }
            texturedClassChange(kind: 15, context: context)
        case .ef_tatami:
            texturedClassChange(kind: 16, context: context)
        case .ef_kasumikiri:
            if stateCnt == 0 {
                context.world.playSound(
                    named: K2L("effect\\안개베기.wav"),
                    atWorldPosition: EffectSpace.toWorldPosition(position),
                    delay: 0
                )
            }
            texturedClassChange(kind: 17, context: context)
        case .ef_issen:
            if stateCnt == 0 {
                context.world.playSound(
                    named: K2L("effect\\일섬.wav"),
                    atWorldPosition: EffectSpace.toWorldPosition(position),
                    delay: 0
                )
            }
            texturedClassChange(kind: 18, context: context)
        case .ef_kaen:
            texturedClassChange(kind: 19, context: context)
        case .ef_desperado:
            if stateCnt == 10 {
                context.world.playSound(
                    named: K2L("effect\\데스페라도.wav"),
                    atWorldPosition: EffectSpace.toWorldPosition(position),
                    delay: 0
                )
            }
            texturedClassChange(kind: 20, context: context)
        case .ef_lightning_s:
            texturedClassChange(kind: 21, context: context)
        case .ef_blind_s:
            texturedClassChange(kind: 22, context: context)
        case .ef_poison_s:
            texturedClassChange(kind: 23, context: context)
        case .ef_freezing_s:
            texturedClassChange(kind: 24, context: context)
        case .ef_flare_s:
            texturedClassChange(kind: 25, context: context)
        case .ef_rapidshower:
            if stateCnt == 20 {
                context.world.playSound(
                    named: K2L("effect\\래피드샤워.wav"),
                    atWorldPosition: EffectSpace.toWorldPosition(position),
                    delay: 0
                )
            }
            texturedClassChange(kind: 26, context: context)
        case .ef_magicalbullet:
            if stateCnt == 0 {
                context.world.playSound(
                    named: K2L("effect\\매지컬불릿.wav"),
                    atWorldPosition: EffectSpace.toWorldPosition(position),
                    delay: 0
                )
            }
            texturedClassChange(kind: 27, context: context)
        case .ef_spreadattack:
            texturedClassChange(kind: 28, context: context)
        case .ef_tracking:
            texturedClassChange(kind: 29, context: context)
        case .ef_tripleaction:
            if stateCnt == 25 {
                context.world.playSound(
                    named: K2L("effect\\트리플액션.wav"),
                    atWorldPosition: EffectSpace.toWorldPosition(position),
                    delay: 0
                )
            }
            texturedClassChange(kind: 30, context: context)
        case .ef_map_magiczone:
            mapMagicZone(texturePath: "effect\\mjin2.tga", type: 0, context: context)
            mapMagicZone(texturePath: "effect\\mjin.tga", type: 1, context: context)
            mapPika(texturePath: "effect\\pikapika2.bmp", context: context)
            wideTripleRingStack(texturePath: "effect\\ring_blue.tga", context: context)
        case .ef_map_magiczone2:
            mapMagicZone(texturePath: "effect\\mjin2.tga", type: 2, context: context)
            mapMagicZone(texturePath: "effect\\mjin.tga", type: 3, context: context)
            for index in stride(from: 2, to: 21, by: 2) {
                texturedOrbitDust(texturePath: "effect\\mpa3.tga", rise: Int8(index), kind: 0, context: context)
            }
        case .ef_damage1:
            if stateCnt == 0 {
                context.world.playSound(
                    named: "effect\\EF_hit2.wav",
                    atWorldPosition: EffectSpace.toWorldPosition(position),
                    delay: 0
                )
            }
        case .ef_undeadbody:
            if let targetID = targetObjectID ?? ownerObjectID {
                let alpha = Float(min(stateCnt, 200)) / 255.0
                context.world.applyTargetModifier(
                    .outline(
                        color: SIMD4<Float>(5.0 / 255.0, 155.0 / 255.0, 5.0 / 255.0, alpha),
                        spread: 2.0,
                        layers: 2,
                        durationTicks: 2
                    ),
                    to: targetID
                )
            }
        case .ef_undeadbody_del:
            if stateCnt < 40, let targetID = targetObjectID ?? ownerObjectID {
                let alpha = Float(max(0, 200 - stateCnt * 5)) / 255.0
                context.world.applyTargetModifier(
                    .outline(
                        color: SIMD4<Float>(5.0 / 255.0, 155.0 / 255.0, 5.0 / 255.0, alpha),
                        spread: 2.0,
                        layers: 2,
                        durationTicks: 2
                    ),
                    to: targetID
                )
            }
        case .ef_bubble_drop:
            bubbleDrop(context: context)
        case .ef_npc_earthquake:
            if stateCnt == 0 {
                context.world.playSound(
                    named: "effect\\earth_quake.wav",
                    atWorldPosition: EffectSpace.toWorldPosition(position),
                    delay: 0
                )
            }
            texturedClassChange(kind: 31, context: context)
            if stateCnt == 0 || stateCnt == 35 || stateCnt == 70 {
                context.world.shakeCamera(amplitude: 1.0, duration: 0.35, frequency: 20.0)
            }
        case .ef_da_space:
            if let targetID = targetObjectID ?? ownerObjectID {
                let rawAlpha = stateCnt < 25 ? (stateCnt * 8) : 200
                let alpha = Float(rawAlpha) / 255.0
                context.world.applyTargetModifier(
                    .outline(color: SIMD4<Float>(1.0, 1.0, 1.0, alpha), spread: 6.0, layers: 2, durationTicks: 2),
                    to: targetID
                )
            }
        case .ef_bleeding:
            if stateCnt == 0 {
                configureSTR(path: "wideb.str")
            }
            if stateCnt == 1 {
                context.world.playSound(
                    named: "effect\\wideb.wav",
                    atWorldPosition: EffectSpace.toWorldPosition(position),
                    delay: 0
                )
            }
            coloredFlash(flag: 1, red: 255, green: 0, blue: 0, context: context)
            _ = processEZ2STR(offset: SIMD3<Float>(0, -80.0, 0), context: context)
        case .ef_bottom_runner:
            texturedHalo(texturePath: "effect\\hanmoon1.tga", kind: 3, context: context)
        case .ef_bottom_transfer:
            texturedHalo(texturePath: "effect\\hanmoon2.tga", kind: 3, context: context)
        case .ef_crystal_blue:
            coloredFlash(flag: 2, red: 0, green: 0, blue: 255, context: context)
        case .ef_bottom_evilland:
            bottomMusic(texturePath: "effect\\curse.bmp", kind: 6, context: context)
        case .ef_guard3:
            kyrieGuard(texturePath: "effect\\guardK.tga", kind: 2, context: context)
        case .ef_npc_slowcast:
            texturedAura(texturePath: "effect\\blast_mine##clock.bmp", kind: 4, context: context)
            if stateCnt == 10 {
                context.world.playSound(
                    named: "effect\\EF_DecAgility.wav",
                    atWorldPosition: EffectSpace.toWorldPosition(position),
                    delay: 0
                )
            }
        case .ef_green99_3:
            freezingCircle(kind: 2, context: context)
        case .ef_green99_5:
            tripleRingStack(texturePath: "effect\\ring_white.tga", large: 1, context: context)
        case .ef_green99_6:
            texturedDoubleRing(texturePath: "effect\\pikapika2.bmp", level: 1, context: context)
        case .ef_mapsphere:
            texturedAura(texturePath: K2L("effect\\구체2.bmp"), kind: 12, context: context)
            texturedAura(texturePath: K2L("effect\\구체3.bmp"), kind: 13, context: context)
            texturedAura(texturePath: K2L("effect\\구체4.bmp"), kind: 11, context: context)
            texturedAura(texturePath: K2L("effect\\구체5.bmp"), kind: 10, context: context)
        case .ef_pok_love:
            texturedClassChange(kind: 32, context: context)
        case .ef_pok_white:
            texturedClassChange(kind: 33, context: context)
        case .ef_pok_valen:
            texturedClassChange(kind: 34, context: context)
        case .ef_pok_birth:
            texturedClassChange(kind: 35, context: context)
        case .ef_pok_christmas:
            texturedClassChange(kind: 36, context: context)
        case .ef_map_magiczone3:
            mapMagicZone(texturePath: K2L("effect\\마법진1-1.bmp"), type: 4, context: context)
            mapMagicZone(texturePath: K2L("effect\\마법진1-2.bmp"), type: 14, context: context)
            mapMagicZone(texturePath: K2L("effect\\마법진1-3.bmp"), type: 4, context: context)
        case .ef_map_magiczone4:
            mapMagicZone(texturePath: K2L("effect\\마법진2-1.bmp"), type: 4, context: context)
            mapMagicZone(texturePath: K2L("effect\\마법진2-2.bmp"), type: 14, context: context)
            mapMagicZone(texturePath: K2L("effect\\마법진2-3.bmp"), type: 4, context: context)
        case .ef_dust:
            torchDust(kind: 0, context: context)
        case .ef_torch_red:
            torchDust(kind: 1, context: context)
        case .ef_torch_green:
            torchDust(kind: 2, context: context)
        case .ef_map_ghost:
            freezingCircle(kind: 3, context: context)
        case .ef_glow1:
            texturedAura(texturePath: "effect\\glow01.bmp", kind: 14, context: context)
        case .ef_glow2:
            texturedAura(texturePath: "effect\\glow02.bmp", kind: 14, context: context)
        case .ef_glow4:
            mapMagicZone(texturePath: "effect\\glow04.bmp", type: 5, context: context)
            for index in stride(from: 2, to: 21, by: 2) {
                texturedOrbitDust(texturePath: "effect\\mpa3.tga", rise: Int8(index), kind: 2, context: context)
            }
        case .ef_torch_purple:
            torchDust(kind: 3, context: context)
        case .ef_cloud7:
            for _ in 0..<80 {
                skyCloud(kind: 7, context: context)
            }
        case .ef_cloud8:
            for _ in 0..<80 {
                skyCloud(kind: 8, context: context)
            }
        default:
            return false
        }
        return true
    }

    // MARK: - EF_KOUENKA (618)

    /// Emits rising fiery sakura petals (`PP_KOUENKA` (124)) for the first 20 ticks of `EF_KOUENKA` (618).
    func sakuraFireArrow(context: EffectTickContext) {
        if stateCnt >= 12 && stateCnt <= 15 {
            let soundIndex = Int.random(in: 1...3)
            context.world.playSound(
                named: "effect\\EF_FireArrow\(soundIndex).wav",
                atWorldPosition: EffectSpace.toWorldPosition(position),
                delay: 0
            )
        }

        guard stateCnt < 20 else {
            return
        }

        let spritePath = K2L("이팩트\\sakura01.spr")
        let actionPath = K2L("이팩트\\sakura01.act")
        _ = context.assets?.spriteAsset(spritePath: spritePath, actionPath: actionPath)

        let primitive = launchPrimitive(.pp_kouenka)
        primitive.state.duration = duration
        primitive.state.slots[0].life = 1
        primitive.state.slots[0].maxHeight = Float(Int.random(in: 0..<3) + 2) * 0.15
        primitive.state.size = Float(Int.random(in: 0..<6) + 22) / 70.0
        let angle = Int.random(in: 0..<360)
        primitive.state.slots[0].vecBPre = SIMD3<Float>(
            EffectSpace.cosine(degrees: angle) * 8.0 + position.x,
            position.y,
            EffectSpace.sine(degrees: angle) * 8.0 + position.z
        )
        for h in 0..<4 {
            primitive.state.slots[0].height[h] = Float(Int.random(in: 0..<360))
        }
        for i in 1..<4 {
            primitive.state.slots[i].life = 0
        }
        primitive.state.alpha = 250.0
        primitive.state.spritePath = spritePath
        primitive.state.actionPath = actionPath
        primitive.previousAnimation = Int.random(in: 0..<3)
        primitive.currentMotion = 0
        primitive.initSegment()
    }

    // MARK: - EF_STIN4 (621)

    /// Spawns 4-slot wind slash wave (`PP_STIN4` (125)) for `EF_STIN4` (621).
    func texturedSlashWave(texturePath: String, kind: Int8, context: EffectTickContext) {
        guard stateCnt == 0 else {
            return
        }

        _ = context.assets?.texture(atPath: texturePath)

        let primitive = launchPrimitive(.pp_stin4)
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
            primitive.state.slots[index].distance = Float(Int.random(in: 0..<11)) * 0.5 + 10.0
            primitive.state.slots[index].alphaB = 0
            primitive.state.slots[index].vecBNow = SIMD3<Float>(position.x, position.y - 10.0, position.z)
            primitive.state.slots[index].rotStart = 0
            primitive.state.slots[index].riseAngle = Int16(index)
            primitive.state.slots[index].height[1] = Float(Int.random(in: 0..<21)) * 0.1 + 1.0
            primitive.state.slots[index].flag1[0] = 0
            primitive.state.slots[index].flag1[1] = 0
            if kind == 0 {
                primitive.state.slots[index].flag1[2] = 0
            } else if kind == 1 {
                primitive.state.slots[index].flag1[2] = 1
            }
            primitive.state.slots[index].flag1[3] = 1
        }
    }

    // MARK: - EF_STIN5 (624)

    /// Spawns 5-point wind cross rings (`126`) over ticks `0..<5` for `EF_STIN5` (624).
    func texturedSlashCross(texturePath: String, context: EffectTickContext) {
        guard stateCnt < 5 else {
            return
        }

        _ = context.assets?.texture(atPath: texturePath)

        let primitive = launchPrimitive(126)
        primitive.state.renderFlag = EffectPrimitiveState.RenderFlag.alpha | EffectPrimitiveState.RenderFlag.customBlend
        primitive.state.duration = duration
        primitive.state.totalTexture = 1
        primitive.state.texturePaths = [texturePath]
        primitive.state.size = 0
        primitive.state.deltaPos = deltaPos
        primitive.position = position

        let offsetXZ: (Float, Float) = switch stateCnt {
        case 0: (0, 0)
        case 1: (5.0, 0)
        case 2: (-5.0, 0)
        case 3: (0, 5.0)
        default: (0, -5.0)
        }

        for index in 0..<4 {
            primitive.state.slots[index].life = 1
            primitive.state.slots[index].process = index - 3
            primitive.state.slots[index].distance = 20.0
            primitive.state.slots[index].alphaB = 0
            primitive.state.slots[index].vecBNow = SIMD3<Float>(
                position.x + offsetXZ.0,
                Float(Int.random(in: 0..<5)) + (position.y - 10.0),
                position.z + offsetXZ.1
            )
            primitive.state.slots[index].rotStart = Int16(Int.random(in: 0..<360))
            primitive.state.slots[index].riseAngle = Int16(index)
            primitive.state.slots[index].height[1] = 1.5
            primitive.state.slots[index].flag1[0] = 0
            primitive.state.slots[index].flag1[3] = 1
        }
    }

    // MARK: - EF_MAP_MAGICZONE (650)

    /// Spawns rotating floor magic circle (`26`) for `EF_MAP_MAGICZONE*` (650/651/687/688) and `EF_GLOW4` (695).
    func mapMagicZone(texturePath: String, type: Int8, context: EffectTickContext) {
        guard stateCnt == 0 else {
            return
        }

        _ = context.assets?.texture(atPath: texturePath)

        let primitive = launchPrimitive(26)
        primitive.state.renderFlag = EffectPrimitiveState.RenderFlag.alpha | EffectPrimitiveState.RenderFlag.customBlend
        primitive.state.duration = duration
        primitive.state.totalTexture = 1
        primitive.state.texturePaths = [texturePath]

        if type == 4 || type == 14 {
            primitive.state.size = 111.0
        } else if type == 5 {
            primitive.state.size = 112.0
        } else {
            primitive.state.size = 110.0
        }

        for i in 1..<4 {
            primitive.state.slots[i].life = 0
        }
        primitive.state.slots[0].life = 1

        if type >= 2 && type <= 3 {
            primitive.state.slots[0].distance = 40.0
        } else if type == 4 || type == 14 {
            primitive.state.slots[0].distance = param[0] <= 0 ? 40.0 : param[0]
        } else {
            primitive.state.slots[0].distance = 30.0
        }

        if type == 4 || type == 5 || type == 14 {
            primitive.state.slots[0].rotStart = 0
            primitive.state.slots[0].alphaB = 250
            primitive.state.slots[0].height[0] = -0.5
        } else if type == 0 || type == 2 {
            primitive.state.slots[0].rotStart = 0
            primitive.state.slots[0].alphaB = 200
            primitive.state.slots[0].height[0] = -0.5
        } else {
            primitive.state.slots[0].rotStart = 358
            primitive.state.slots[0].alphaB = 50
            primitive.state.slots[0].height[0] = -0.4
        }

        primitive.state.slots[0].height[4] = Float(type)
    }

    /// Spawns twin pulsing ground glow plates (`28`) for `EF_MAP_MAGICZONE` (650).
    func mapPika(texturePath: String, context: EffectTickContext) {
        guard stateCnt == 0 else {
            return
        }

        _ = context.assets?.texture(atPath: texturePath)

        let primitive = launchPrimitive(28)
        primitive.state.renderFlag = EffectPrimitiveState.RenderFlag.alpha | EffectPrimitiveState.RenderFlag.customBlend
        primitive.state.duration = duration
        primitive.state.totalTexture = 1
        primitive.state.texturePaths = [texturePath]
        primitive.state.size = 4.0

        primitive.state.slots[0].life = 1
        primitive.state.slots[1].life = 1
        primitive.state.slots[2].life = 0
        primitive.state.slots[3].life = 0
        primitive.state.slots[0].distance = 46.0
        primitive.state.slots[1].distance = 46.0
        primitive.state.slots[0].riseAngle = 0
        primitive.state.slots[1].riseAngle = 180
        primitive.state.slots[0].alphaB = 25
        primitive.state.slots[1].alphaB = 25
        primitive.state.slots[0].height[0] = -1.0
        primitive.state.slots[1].height[0] = -1.0
    }

    /// Spawns 3-layer wide casting rings (`PP_3DCASTING` (23)) for `EF_MAP_MAGICZONE` (650).
    func wideTripleRingStack(texturePath: String, context: EffectTickContext) {
        guard stateCnt == 0 else {
            return
        }

        _ = context.assets?.texture(atPath: texturePath)

        let primitive = launchPrimitive(.pp_3dcasting)
        primitive.state.renderFlag = EffectPrimitiveState.RenderFlag.alpha | EffectPrimitiveState.RenderFlag.customBlend
        primitive.state.duration = duration
        primitive.state.totalTexture = 1
        primitive.state.texturePaths = [texturePath]
        primitive.state.size = 0

        let configs: [(maxHeight: Float, rotStart: Int16, distance: Float, riseAngle: Int16)] = [
            (15.0, 0, 12.9, 55),
            (13.0, 90, 13.1, 50),
            (11.0, 180, 13.3, 45),
        ]

        for (index, config) in configs.enumerated() {
            primitive.state.slots[index].life = 1
            primitive.state.slots[index].process = 0
            primitive.state.slots[index].fullDisplayAngle = 315
            primitive.state.slots[index].maxHeight = config.maxHeight
            primitive.state.slots[index].rotStart = config.rotStart
            primitive.state.slots[index].alphaB = 50
            primitive.state.slots[index].alphaT = 1
            primitive.state.slots[index].distance = config.distance
            primitive.state.slots[index].riseAngle = config.riseAngle
            primitive.state.slots[index].vecBNow.y = 0
            primitive.state.slots[index].height = Array(repeating: 0, count: 21)
            primitive.state.slots[index].flag1 = Array(repeating: 0, count: 21)
        }
        primitive.state.slots[3].life = 0
    }

    // MARK: - EF_MAP_MAGICZONE2 (651)

    /// Spawns orbiting dust motes (`PP_MAPPARTICLE` (27)) at elevated layers for `EF_MAP_MAGICZONE2` (651) and `EF_GLOW4` (695).
    func texturedOrbitDust(texturePath: String, rise: Int8, kind: Int8, context: EffectTickContext) {
        guard stateCnt == 0 else {
            return
        }

        _ = context.assets?.texture(atPath: texturePath)

        let primitive = launchPrimitive(.pp_mapparticle)
        primitive.state.renderFlag = EffectPrimitiveState.RenderFlag.alpha | EffectPrimitiveState.RenderFlag.customBlend
        primitive.state.duration = duration
        primitive.state.totalTexture = 1
        primitive.state.texturePaths = [texturePath]
        primitive.state.size = 0

        let lift = Float(Int(rise) * 2)
        for ec in 0..<4 {
            primitive.state.slots[ec].life = 1
            primitive.state.slots[ec].maxHeight = 0.15
            primitive.state.slots[ec].distance = 1.0
            for h in 0..<8 {
                primitive.state.slots[ec].height[h] = Float(Int.random(in: 0..<360))
            }
            primitive.state.slots[ec].vecBPre = SIMD3<Float>(0, -lift, 0)
            primitive.state.slots[ec].vecBNow = SIMD3<Float>(0, -lift, 0)
            primitive.state.slots[ec].vecTPre = SIMD3<Float>(0, -lift, 0)
            primitive.state.slots[ec].vecTNow = SIMD3<Float>(0, -lift, 0)
            primitive.state.slots[ec].flag1[0] = 1
            primitive.state.slots[ec].flag1[1] = kind == 2 ? 2 : 0
        }
    }

    // MARK: - EF_BUBBLE_DROP (665)

    /// Spawns falling blue droplet panels (`PP_BUBBLE_DROP` (127)) for `EF_BUBBLE_DROP` (665).
    func bubbleDrop(context: EffectTickContext) {
        guard stateCnt == 0 else {
            return
        }

        let dropHeight = param[0] <= 1.0 ? 50.0 : param[0]
        let texturePath = K2L("effect\\썬더스톰파티클.tga")
        _ = context.assets?.texture(atPath: texturePath)

        let primitive = launchPrimitive(.pp_bubble_drop)
        primitive.state.renderFlag = EffectPrimitiveState.RenderFlag.alpha | EffectPrimitiveState.RenderFlag.customBlend
        primitive.state.duration = duration
        primitive.state.totalTexture = 1
        primitive.state.texturePaths = [texturePath]
        primitive.state.size = 0

        primitive.state.slots[0].life = 1
        primitive.state.slots[0].process = 0
        primitive.state.slots[0].distance = 1.0
        primitive.state.slots[0].alphaB = 0
        primitive.state.slots[0].vecBPre = SIMD3<Float>(0, -dropHeight, 0)
        primitive.state.slots[0].rotStart = 0
        primitive.state.slots[0].height[1] = 1.0
        primitive.state.slots[0].fullDisplayAngle = Int16(Int.random(in: 0..<360))
        primitive.state.slots[0].flag1[0] = 0
        primitive.state.slots[0].flag1[2] = 2
        primitive.state.slots[0].flag1[4] = Int8(truncatingIfNeeded: Int(dropHeight))

        for i in 1..<4 {
            primitive.state.slots[i].life = 1
            primitive.state.slots[i].alphaB = 0
        }
    }

    // MARK: - EF_DUST (689)

    /// Spawns `PP_EFFECTTEXTURE_ANI` (128) animated billboard panel for `EF_DUST` (689) and torch variants.
    func torchDust(kind: Int8, context: EffectTickContext) {
        guard stateCnt == 0 else {
            return
        }

        let texturePaths: [String] = switch kind {
        case 0:
            (1...9).map { String(format: "effect\\dust%02d.bmp", $0) }
        case 1:
            (1...13).map { String(format: "effect\\torch_red%02d.bmp", $0) }
        case 2:
            (1...13).map { String(format: "effect\\torch_green%02d.bmp", $0) }
        case 3:
            (1...13).map { String(format: "effect\\torch_violet%02d.bmp", $0) }
        case 4:
            [
                "effect\\lord_stick_a.bmp",
                "effect\\lord_stick_b.bmp",
                "effect\\lord_stick_c.bmp",
                "effect\\lord_stick_e.bmp",
                "effect\\lord_stick_f.bmp",
                "effect\\lord_stick_g.bmp",
                "effect\\lord_stick_h.bmp",
                "effect\\lord_stick_plazma_a.bmp",
                "effect\\lord_stick_plazma_b.bmp",
                "effect\\lord_stick_plazma_c.bmp",
                "effect\\lord_blast_stick_a.bmp",
            ]
        default:
            []
        }

        for path in texturePaths {
            _ = context.assets?.texture(atPath: path)
        }

        let primitive = launchPrimitive(.pp_effecttexture_ani)
        primitive.state.renderFlag = EffectPrimitiveState.RenderFlag.alpha | EffectPrimitiveState.RenderFlag.customBlend
        primitive.state.duration = duration
        primitive.state.totalTexture = texturePaths.count
        primitive.state.texturePaths = texturePaths
        primitive.state.size = 0

        for i in 0..<4 {
            primitive.state.slots[i].life = 0
        }
        primitive.state.slots[0].life = 1
        primitive.state.slots[0].process = 0
        primitive.state.slots[0].distance = param[0] > 0 ? param[0] : 20.0
        primitive.state.slots[0].vecBPre.y = position.y - 10.0
        primitive.state.slots[0].flag1[2] = 4
        if kind == 4 {
            primitive.state.slots[0].fullDisplayAngle = 120
            primitive.state.slots[0].height[10] = 1.0
            primitive.state.slots[0].height[8] = 0
            primitive.state.slots[0].alphaB = 130
        } else {
            primitive.state.slots[0].fullDisplayAngle = 135
            primitive.state.slots[0].height[10] = 0
            primitive.state.slots[0].height[8] = 0
            primitive.state.slots[0].alphaB = kind != 0 ? 130 : 100
        }
        primitive.state.slots[0].vecBNow.x = position.x
        primitive.state.slots[0].vecBNow.z = position.z
        primitive.state.slots[0].rotStart = Int16(Int.random(in: 0..<360))
        primitive.state.slots[0].flag1[0] = 0
        primitive.state.slots[0].flag1[4] = kind
    }
}
