//
//  RagEffect+Dispatch.swift
//  RagnarokEffects
//
//  Created by Leon Li on 2026/11/26.
//

import Foundation
import RagnarokCore
import simd

extension RagEffect {
    private nonisolated static let proceduralEffectIDs: [EffectID] = [
        .ef_hit1,
        .ef_hit2,
        .ef_hit3,
        .ef_hit4,
        .ef_hit5,
        .ef_hit6,
        .ef_entry,
        .ef_exit,
        .ef_warp,
        .ef_enhance,
        .ef_coin,
        .ef_endure,
        .ef_beginspell,
        .ef_glasswall,
        .ef_healsp,
        .ef_soulstrike,
        .ef_bash,
        .ef_magnumbreak,
        .ef_steal,
        .ef_pattack,
        .ef_detoxication,
        .ef_sight,
        .ef_fireball,
        .ef_icearrow,
        .ef_frostdiver,
        .ef_frostdiver2,
        .ef_firearrow,
        .ef_napalmbeat,
        .ef_ruwach,
        .ef_teleportation,
        .ef_readyportal,
        .ef_portal,
        .ef_incagility,
        .ef_decagility,
        .ef_aqua,
        .ef_signum,
        .ef_blessing,
        .ef_incagidex,
        .ef_smoke,
        .ef_firefly,
        .ef_sandwind,
        .ef_torch,
        .ef_spraypond,
        .ef_firesplashhit,
        .ef_coldhit,
        .ef_poisonhit,
        .ef_beginspell2,
        .ef_beginspell3,
        .ef_beginspell4,
        .ef_beginspell5,
        .ef_beginspell6,
        .ef_beginspell7,
        .ef_lockon,
        .ef_warpzone,
        .ef_sightrasher,
        .ef_barrier,
        .ef_cone,
        .ef_sphere,
        .ef_bowlingbash,
        .ef_icewall,
        .ef_earthspike,
        .ef_spearbmr,
        .ef_pierce,
        .ef_turnundead,
        .ef_aspersio,
        .ef_stormgust,
        .ef_yufitel,
        .ef_yufitelhit,
        .ef_hasteup,
        .ef_flasher,
        .ef_removetrap,
        .ef_blastmine,
        .ef_bottom,
        .ef_blitzbeat,
        .ef_waterball,
        .ef_waterball2,
        .ef_fireivy,
        .ef_detecting,
        .ef_cloaking,
        .ef_sonicblow,
        .ef_sonicblowhit,
        .ef_grimtooth,
        .ef_enchantpoison,
        .ef_overthrust,
        .ef_twohandquicken,
        .ef_grimtoothatk,
        .ef_bottom2,
        .ef_firepillaron,
        .ef_revive,
        .ef_heavensdrive,
        .ef_toprank,
        .ef_party,
        .ef_rain,
        .ef_snow,
        .ef_sakura,
        .ef_status_state,
        .ef_banjjakii,
        .ef_makeblur,
        .ef_cartrevolution,
        .ef_venomdust2,
        .ef_changedark,
        .ef_changefire,
        .ef_changecold,
        .ef_changewind,
        .ef_changeflame,
        .ef_changeearth,
        .ef_chaingeholy,
        .ef_changepoison,
        .ef_hitdark,
        .ef_sui_explosion,
        .ef_darkattack,
        .ef_telekhit,
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
        .ef_bottom_dissonance,
        .ef_bottom_rokisweil,
        .ef_bottom_whistle,
        .ef_bottom_assassincross,
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
        .ef_bottom_fogwall,
        .ef_rainbow,
        .ef_hitline3,
        .ef_hitline6,
        .ef_electric,
        .ef_electric2,
        .ef_hitline7,
        .ef_grandcross2,
        .ef_flowercast,
        .ef_groundsample,
        .ef_kaizel,
        .ef_dust,
        .ef_infraredscan,
        .ef_beginspell_n1,
        .ef_water_fade,
        .ef_primecharge,
        .ef_dq9_charge4,
        .ef_selfscroll,
        .ef_waterball3,
    ]

    private nonisolated static let proceduralEffectIDSet: Set<EffectID> = Set(proceduralEffectIDs)

    public nonisolated static let supportedEffectIDs: [EffectID] = Array(
        proceduralEffectIDSet.union(STRDefinition.definitions.map(\.effectID))
    ).sorted()

    public nonisolated static func supports(_ effectID: EffectID) -> Bool {
        proceduralEffectIDSet.contains(effectID) || STRDefinition.definition(for: effectID) != nil
    }

    static func make(
        id: UUID,
        request: EffectSpawnRequest,
        usesMinimalEffects: Bool = false
    ) -> RagEffect? {
        if proceduralEffectIDSet.contains(request.effectID) {
            return RagEffect(id: id, request: request) { effect, context in
                effect.processEffect(context: context)
            }
        }

        if let definition = STRDefinition.definition(for: request.effectID) {
            let effect = RagEffect(id: id, request: request) { effect, context in
                effect.processSTRDefinition(definition, context: context)
            }
            effect.configureSTR(
                path: definition.resolveSTRPath(usesMinimalEffects: usesMinimalEffects),
                loopLimit: definition.loopLimit
            )
            return effect
        }

        return nil
    }

    func processEffect(context: EffectTickContext) -> Bool {
        switch effectID {
        case .ef_hit1:
            hit1(context: context)
        case .ef_hit2:
            hit2(option: 0, context: context)
        case .ef_hit3:
            hit3(context: context)
        case .ef_hit4:
            hit4(context: context)
        case .ef_hit5:
            hit5(context: context)
        case .ef_hit6:
            hit6(context: context)
        case .ef_entry:
            entry(context: context)
        case .ef_exit:
            exit(context: context)
        case .ef_warp:
            warp(context: context)
        case .ef_enhance:
            enhance(context: context)
        case .ef_coin:
            return coin(context: context)
        case .ef_endure:
            endure(context: context)
        case .ef_beginspell:
            processBeginSpellTexturedRing(texturePath: "effect\\ring_yellow.tga", kind: 1, context: context)
        case .ef_glasswall:
            return glassWall(context: context)
        case .ef_healsp:
            healSP(context: context)
        case .ef_soulstrike:
            soulStrike(flag: 0, context: context)
        case .ef_bash:
            bash(context: context)
        case .ef_magnumbreak:
            magnumBreak(context: context)
        case .ef_steal:
            steal(context: context)
        case .ef_pattack:
            poisonAttack(flag: 0, context: context)
        case .ef_detoxication:
            detoxication(context: context)
        case .ef_sight:
            sight(context: context)
        case .ef_fireball:
            fireBall(context: context)
        case .ef_icearrow:
            iceArrow(context: context)
        case .ef_frostdiver:
            frostDiver(type: 0, context: context)
        case .ef_frostdiver2:
            frostDiver2(context: context)
        case .ef_firearrow:
            fireArrow(context: context)
        case .ef_napalmbeat:
            napalmFragments(context: context)
        case .ef_ruwach:
            processRuwach(context: context)
        case .ef_teleportation:
            processTeleportation(context: context)
        case .ef_readyportal:
            processReadyPortal(context: context)
        case .ef_portal:
            portal(context: context)
        case .ef_incagility:
            incAgility(context: context)
        case .ef_decagility:
            decAgility(context: context)
        case .ef_aqua:
            processAqua(context: context)
        case .ef_signum:
            return signum(context: context)
        case .ef_blessing:
            blessing(context: context)
        case .ef_incagidex:
            incAgiDex(context: context)
        case .ef_smoke:
            processSmoke(context: context)
        case .ef_firefly:
            fireSparks(context: context)
        case .ef_sandwind:
            sandScatter(context: context)
        case .ef_torch:
            processTorch(context: context)
        case .ef_spraypond:
            sprayPond(context: context)
        case .ef_firesplashhit:
            processFireSplashHit(context: context)
        case .ef_coldhit:
            coldHit(context: context)
        case .ef_poisonhit:
            processPoisonHit(context: context)
        case .ef_beginspell2:
            processBeginSpellQuadStack(texturePath: "effect\\ring_blue.tga", kind: 2, context: context)
        case .ef_beginspell3:
            processBeginSpellQuadStack(texturePath: "effect\\ring_yellow.tga", kind: 1, context: context)
        case .ef_beginspell4:
            processBeginSpellQuadStack(texturePath: "effect\\Magic_Green.tga", kind: 33, context: context)
        case .ef_beginspell5:
            processBeginSpellQuadStack(texturePath: "effect\\ring_yellow.tga", kind: 0, context: context)
        case .ef_beginspell6:
            processBeginSpellTexturedRing(texturePath: "effect\\ring_white.tga", kind: 0, context: context)
        case .ef_beginspell7:
            processBeginSpellQuadStack(texturePath: "effect\\Magic_Violet.tga", kind: 33, context: context)
        case .ef_lockon:
            lockOnMarker(context: context)
        case .ef_warpzone:
            warpZone(context: context)
        case .ef_sightrasher:
            sightrasher(context: context)
        case .ef_barrier:
            processBarrier(context: context)
        case .ef_cone:
            processCone(context: context)
        case .ef_sphere:
            sphere(context: context)
        case .ef_bowlingbash:
            bowlingBash(context: context)
        case .ef_icewall:
            iceWall(context: context)
        case .ef_earthspike:
            earthSpike(type: 0, context: context)
        case .ef_spearbmr:
            spearBmr(context: context)
        case .ef_pierce:
            ringBurstSparks(context: context)
        case .ef_turnundead:
            turnUndead(context: context)
        case .ef_aspersio:
            return aspersio(context: context)
        case .ef_stormgust:
            return stormGust(context: context)
        case .ef_yufitel:
            yufitel(flag: 0, context: context)
        case .ef_yufitelhit:
            yufitelHit(kind: 0, context: context)
        case .ef_hasteup:
            hasteUp(context: context)
        case .ef_flasher:
            flasher(context: context)
        case .ef_removetrap:
            removeTrap(context: context)
        case .ef_blastmine:
            break
        case .ef_bottom:
            bottom(context: context)
        case .ef_blitzbeat:
            blitzBeat(context: context)
        case .ef_waterball:
            waterOut(context: context)
        case .ef_waterball2:
            waterBall2(context: context)
        case .ef_fireivy:
            processFireIvy(context: context)
        case .ef_detecting:
            texturedSkillAura(type: 0, context: context)
        case .ef_cloaking:
            assassinCloaking(context: context)
        case .ef_sonicblow:
            processSonicBlow(context: context)
        case .ef_sonicblowhit:
            sonicBlowHit(context: context)
        case .ef_grimtooth:
            grimTooth(context: context)
        case .ef_enchantpoison:
            poisonAttack(flag: 0, context: context)
        case .ef_overthrust:
            stoneCurseRing(context: context)
        case .ef_twohandquicken:
            return twoHandQuicken(context: context)
        case .ef_grimtoothatk:
            grimToothAtk(context: context)
        case .ef_bottom2:
            bottom2(context: context)
        case .ef_firepillaron:
            ringStack(white: 0, context: context)
        case .ef_revive:
            processRevive(context: context)
        case .ef_heavensdrive:
            stoneSpike(context: context)
        case .ef_toprank:
            processTopRank(context: context)
        case .ef_party:
            processPartyMarker(context: context)
        case .ef_rain:
            break
        case .ef_snow:
            snow(context: context)
        case .ef_sakura:
            sakura(context: context)
        case .ef_status_state:
            statusIconColumn(context: context)
        case .ef_banjjakii:
            processBanjjakii(context: context)
        case .ef_makeblur:
            let tintRGB = deltaPos2 == .zero ? SIMD3<Float>(250, 250, 250) : deltaPos2
            spawnBlurAfterimage(tintRGB: tintRGB, context: context)
        case .ef_cartrevolution:
            return cartRevolution(context: context)
        case .ef_venomdust2:
            processVenomDust2(context: context)
        case .ef_changedark:
            if stateCnt == 0 {
                quadRingStackSized(texturePath: "effect\\ring_black.tga", kind: 3, context: context)
            }
        case .ef_changefire:
            if stateCnt == 0 {
                quadRingStackSized(texturePath: "effect\\ring_red.tga", kind: 3, context: context)
            }
        case .ef_changecold:
            if stateCnt == 0 {
                quadRingStackSized(texturePath: "effect\\ring_blue.tga", kind: 3, context: context)
            }
        case .ef_changewind:
            if stateCnt == 0 {
                quadRingStackSized(texturePath: "effect\\ring_yellow.tga", kind: 3, context: context)
            }
        case .ef_changeflame:
            if stateCnt == 0 {
                quadRingStackSized(texturePath: "effect\\ring_jadu.tga", kind: 3, context: context)
            }
        case .ef_changeearth:
            if stateCnt == 0 {
                quadRingStackSized(texturePath: "effect\\ring_brown.tga", kind: 3, context: context)
            }
        case .ef_chaingeholy:
            if stateCnt == 0 {
                quadRingStackSized(texturePath: "effect\\ring_white.tga", kind: 3, context: context)
            }
        case .ef_changepoison:
            if stateCnt == 0 {
                quadRingStackSized(texturePath: "effect\\ring_purple.tga", kind: 3, context: context)
            }
        case .ef_hitdark:
            hitDark(context: context)
        case .ef_sui_explosion:
            return processSuiExplosion(context: context)
        case .ef_darkattack:
            hitDark(context: context)
        case .ef_telekhit:
            break
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
        case .ef_bottom_dissonance:
            texturedMagicRing(texturePath: "effect\\ring_blue.tga", kind: 0, context: context)
        case .ef_bottom_rokisweil:
            bottomOut(texturePath: "effect\\safeline.bmp", kind: 0, context: context)
        case .ef_bottom_whistle:
            bottomMusic(texturePath: "effect\\melody_b.bmp", kind: 0, context: context)
        case .ef_bottom_assassincross:
            texturedMagicRing(texturePath: "effect\\ring_red.tga", kind: 1, context: context)
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
                    named: "effect\\소울 체인지.wav",
                    atWorldPosition: EffectSpace.toWorldPosition(position),
                    delay: 0
                )
            }
            trackTarget(context: context)
        case .ef_bottom_fogwall:
            texturedPulseKind(texturePath: "effect\\ring_white.tga", kind: 2, context: context)
        case .ef_rainbow:
            rainbow(texturePath: "effect\\alpha_center.tga", context: context)
        case .ef_hitline3:
            whiteSparkStreak(kind: 0, context: context)
        case .ef_hitline6:
            whiteSparkStreak(kind: 3, context: context)
        case .ef_electric:
            if stateCnt == 25 {
                context.world.playSound(
                    named: "effect\\T_전기.wav",
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
        case .ef_grandcross2:
            grandCrossRings(angle: 0, kind: 1, context: context)
            grandCross2(flag: 1, context: context)
        case .ef_flowercast:
            texturedSlashAir(texturePath: "effect\\ring_blue.tga", size: 4, phase: 0, context: context)
            texturedSlashAir(texturePath: "effect\\ring_blue.tga", size: 4, phase: 1, context: context)
        case .ef_groundsample:
            groundSample(context: context)
        case .ef_kaizel:
            if stateCnt == 15 {
                jobLvUp50Pair(angle: 0, context: context)
                jobLvUp50Pair(angle: 45, context: context)
            }
        case .ef_dust:
            torchDust(kind: 0, context: context)
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
        case .ef_water_fade:
            texturedDualSpin(
                firstTexturePath: "effect\\W_Comp_00.tga",
                secondTexturePath: "effect\\W_Comp_24.tga",
                context: context
            )
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
        case .ef_dq9_charge4:
            texturedSpiralFade(texturePath: "effect\\shockwave_c.bmp", context: context)
        case .ef_selfscroll:
            texturedDoubleSpiral(texturePath: "effect\\shockwave_c.bmp", context: context)
        case .ef_waterball3:
            waterBallBurst(context: context)
        default:
            return false
        }
        return true
    }

    // MARK: - Inline OnProcess Cases (0...125)

    private func processBeginSpellTexturedRing(texturePath: String, kind: Int, context: EffectTickContext) {
        guard stateCnt == 0 else {
            return
        }

        context.world.playSound(
            named: "effect\\EF_BeginSpell.wav",
            atWorldPosition: EffectSpace.toWorldPosition(position),
            delay: 0
        )
        texturedQuadRingSized(baseAlpha: 45, texturePath: texturePath, kind: kind, context: context)
        texturedQuadRingSized(baseAlpha: 25, texturePath: texturePath, kind: kind, context: context)
    }

    private func processBeginSpellQuadStack(texturePath: String, kind: Int, context: EffectTickContext) {
        guard stateCnt == 0 else {
            return
        }

        context.world.playSound(
            named: "effect\\EF_BeginSpell.wav",
            atWorldPosition: EffectSpace.toWorldPosition(position),
            delay: 0
        )
        quadRingStackSized(texturePath: texturePath, kind: kind, context: context)
    }

    private func processRuwach(context: EffectTickContext) {
        guard stateCnt % 3 == 0 else {
            return
        }

        let spritePath = K2L("이팩트\\particle2.spr")
        let actionPath = K2L("이팩트\\particle2.act")
        let shadowSprite = "Shadow.spr"
        let shadowAction = "Shadow.act"
        _ = context.assets?.spriteAsset(spritePath: spritePath, actionPath: actionPath)
        _ = context.assets?.spriteAsset(spritePath: shadowSprite, actionPath: shadowAction)

        let angle = Int(Float(stateCnt) / 1.3 * -5.0)
        let offsetX = EffectSpace.sine(degrees: angle) * 15.0
        let offsetZ = EffectSpace.cosine(degrees: angle) * -15.0

        let particle = launchPrimitive(.pp_3dparticle)
        particle.state.duration = 25
        particle.state.deltaPos2 = SIMD3<Float>(offsetX, -10.0, offsetZ)
        particle.state.spritePath = spritePath
        particle.state.actionPath = actionPath
        particle.state.size = 3.0
        particle.state.sizeSpeed = -0.1
        particle.state.alpha = 250.0
        particle.state.alphaSpeed = -3.0
        particle.state.fadeOutCnt = particle.state.duration - 6
        particle.initSegment()

        let shadow = launchPrimitive(.pp_3dparticle)
        shadow.state.duration = 25
        shadow.state.deltaPos2 = SIMD3<Float>(offsetX, 0, offsetZ)
        shadow.state.spritePath = shadowSprite
        shadow.state.actionPath = shadowAction
        shadow.state.animSpeed = 2
        shadow.state.size = 1.5
        shadow.state.sizeSpeed = -0.06
        shadow.state.alpha = 150.0
        shadow.state.alphaSpeed = -2.5
        shadow.state.fadeOutCnt = shadow.state.duration - 6
        shadow.initSegment()
    }

    private func processTeleportation(context: EffectTickContext) {
        guard stateCnt == 0 else {
            return
        }

        context.world.playSound(
            named: "effect\\EF_Teleportation.wav",
            atWorldPosition: EffectSpace.toWorldPosition(position),
            delay: 0
        )

        let texturePath = "effect\\ring_blue.tga"
        _ = context.assets?.texture(atPath: texturePath)

        let cylinder = launchPrimitive(.pp_3dcylinder)
        cylinder.state.duration = 60
        cylinder.state.pattern |= 1
        cylinder.state.outerSize = 4.0
        cylinder.state.innerSize = 4.0
        cylinder.state.heightSpeed = 5.0
        cylinder.state.heightAccel = 0.25
        cylinder.state.longSpeed = 2.0
        cylinder.state.fadeOutCnt = 0
        cylinder.state.texturePaths = [texturePath]
    }

    private func processReadyPortal(context: EffectTickContext) {
        guard stateCnt % 14 == 0 else {
            return
        }

        context.world.playSound(
            named: "effect\\EF_ReadyPortal.wav",
            atWorldPosition: EffectSpace.toWorldPosition(position),
            delay: 0
        )

        let texturePath = "effect\\ring_blue.tga"
        _ = context.assets?.texture(atPath: texturePath)

        let ring = launchPrimitive(.pp_3dcircle)
        ring.state.duration = 30
        ring.state.deltaPos2.y = -1.0
        ring.state.innerSize = 8.0
        ring.state.latitude = 90.0
        ring.state.transform = EffectSpace.rotationX(radians: EffectSpace.radian(degrees: Int(ring.state.latitude)))
        ring.state.radiusSpeed = 1.0
        ring.state.radiusAccel = -(ring.state.radiusSpeed / Float(ring.state.duration)) * 0.5
        ring.state.fadeOutCnt = ring.state.duration - ring.state.duration / 2
        ring.initSegment()
        ring.state.texturePaths = [texturePath]
    }

    private func processAqua(context: EffectTickContext) {
        guard stateCnt == 0 else {
            return
        }

        context.world.playSound(
            named: "effect\\EF_Aqua.wav",
            atWorldPosition: EffectSpace.toWorldPosition(position),
            delay: 0
        )

        let spritePath = K2L("이팩트\\성수뜨기.spr")
        let actionPath = K2L("이팩트\\성수뜨기.act")
        _ = context.assets?.spriteAsset(spritePath: spritePath, actionPath: actionPath)

        let particle = launchPrimitive(.pp_3dparticle)
        particle.state.duration = duration
        particle.state.deltaPos2.y = -20.0
        particle.state.animSpeed = 2
        particle.state.repeatAnim = false
        particle.state.spritePath = spritePath
        particle.state.actionPath = actionPath
        particle.initSegment()
    }

    private func processSmoke(context: EffectTickContext) {
        guard stateCnt == 0 else {
            return
        }

        let spritePath = K2L("이팩트\\굴뚝연기.spr")
        let actionPath = K2L("이팩트\\굴뚝연기.act")
        _ = context.assets?.spriteAsset(spritePath: spritePath, actionPath: actionPath)

        let puffCount = Int.random(in: 0..<4) + 1
        for _ in 0..<puffCount {
            let smoke = launchPrimitive(.pp_3dparticle)
            smoke.state.duration = duration
            let rotX = EffectSpace.rotationX(radians: EffectSpace.radian(degrees: Int.random(in: 0..<30) + 75))
            let rotY = EffectSpace.rotationY(radians: EffectSpace.radian(degrees: Int.random(in: 0..<360)))
            smoke.state.transform = rotY * rotX
            smoke.state.deltaPos2.y = -9.0
            smoke.state.rollSpeed = 0.75
            smoke.state.speed = Float(Int.random(in: 0..<3) + 3) / 10.0
            smoke.state.size = 1.5
            smoke.state.fadeOutCnt = smoke.state.duration - smoke.state.duration / 3
            smoke.state.spritePath = spritePath
            smoke.state.actionPath = actionPath
            smoke.initSegment()
        }
    }

    private func processTorch(context: EffectTickContext) {
        guard stateCnt == 0 else {
            return
        }

        let spritePath = K2L("이팩트\\torch_01.spr")
        let actionPath = K2L("이팩트\\torch_01.act")
        _ = context.assets?.spriteAsset(spritePath: spritePath, actionPath: actionPath)

        if param[0] <= 0 {
            param[0] = 1.0
        }
        if param[1] < 1.0 {
            param[1] = 1.0
        }

        let torch = launchPrimitive(.pp_3dparticle)
        torch.state.pattern |= 0x200
        torch.state.duration = duration
        torch.state.deltaPos2.y = -10.0
        torch.state.size = param[0]
        torch.state.animSpeed = Int(param[1])
        torch.state.spritePath = spritePath
        torch.state.actionPath = actionPath
        torch.initSegment()
    }

    private func processFireSplashHit(context: EffectTickContext) {
        guard stateCnt == 0 else {
            return
        }

        let texturePath = "effect\\FireRing.tga"
        _ = context.assets?.texture(atPath: texturePath)

        let ring = launchPrimitive(.pp_2dtexture)
        ring.state.duration = 30
        ring.state.deltaPos2.y = -20.0
        ring.state.widthSize = 10.0
        ring.state.heightSize = 10.0
        ring.state.widthSpeed = 5.7
        ring.state.heightSpeed = 5.7
        ring.state.roll = Float(Int.random(in: 0..<360))
        ring.state.rollSpeed = -18.0
        ring.state.rollAccel = -(ring.state.rollSpeed / Float(ring.state.duration)) / 2.5
        ring.state.fadeOutCnt = ring.state.duration - ring.state.duration / 2
        ring.state.texturePaths = [texturePath]
        ring.state.slots[0].life = 0
    }

    private func processPoisonHit(context: EffectTickContext) {
        guard stateCnt == 0 else {
            return
        }

        let spritePath = K2L("이팩트\\PoisonHit.spr")
        let actionPath = K2L("이팩트\\PoisonHit.act")
        _ = context.assets?.spriteAsset(spritePath: spritePath, actionPath: actionPath)

        let hit = launchPrimitive(.pp_3dparticle)
        hit.state.duration = duration
        hit.state.size = 1.5
        hit.state.animSpeed = 2
        hit.state.pattern |= 0x200
        hit.state.repeatAnim = false
        hit.state.spritePath = spritePath
        hit.state.actionPath = actionPath
        hit.initSegment()
    }

    private func processBarrier(context: EffectTickContext) {
        guard stateCnt == 0 else {
            return
        }

        let texturePath = K2L("effect\\대폭발.tga")
        _ = context.assets?.texture(atPath: texturePath)

        let sphere = launchPrimitive(.pp_3dsphere)
        sphere.state.duration = 250
        sphere.state.radius = 13.5
        sphere.state.deltaPos2.y = -10.0
        sphere.state.longitude = 2.0
        sphere.state.alpha = 100.0
        sphere.state.texturePaths = [texturePath]
    }

    private func processCone(context: EffectTickContext) {
        guard stateCnt % 130 == 0 else {
            return
        }

        let spritePath = K2L("이팩트\\particle1.spr")
        let actionPath = K2L("이팩트\\particle1.act")
        _ = context.assets?.spriteAsset(spritePath: spritePath, actionPath: actionPath)

        duration = 200
        let orbit = launchPrimitive(.pp_3dparticleorbit)
        orbit.state.duration = 300
        orbit.state.radius = 0.1
        orbit.state.radiusSpeed = 0.2
        orbit.state.gravSpeed = 0.1
        orbit.state.gravAccel = 0.005
        orbit.state.longitude = 2.0
        orbit.state.longSpeed = 15.0
        orbit.state.longAccel = -0.01
        orbit.state.size = 1.2
        orbit.state.transform = EffectSpace.rotationY(radians: EffectSpace.radian(degrees: Int(orbit.state.longitude)))
        orbit.state.deltaPos2 = EffectSpace.transformVector(SIMD3<Float>(0, -30.0, orbit.state.radius), by: orbit.state.transform)
        orbit.state.spritePath = spritePath
        orbit.state.actionPath = actionPath
        orbit.initSegment()
    }

    private func processFireIvy(context: EffectTickContext) {
        guard stateCnt == 0 else {
            return
        }

        context.world.playSound(
            named: "effect\\wizard_fire_ivy.wav",
            atWorldPosition: EffectSpace.toWorldPosition(position),
            delay: 0
        )

        let texturePath = "effect\\fire_ivy.bmp"
        _ = context.assets?.texture(atPath: texturePath)

        let panel = launchPrimitive(.pp_3dtexture)
        panel.state.duration = duration
        panel.state.pattern = 0x40 | 0x100
        panel.state.renderFlag |= EffectPrimitiveState.RenderFlag.additive
        panel.state.widthSize = 3.5
        panel.state.heightSize = 3.5
        panel.state.speed3d.y = -(25.0 / Float(panel.state.duration))
        panel.state.deltaPos2.y = -5.0
        panel.state.texturePaths = [texturePath]
    }

    private func processSonicBlow(context: EffectTickContext) {
        guard stateCnt == 0 else {
            return
        }

        context.world.playSound(
            named: "effect\\EF_StoneCurse.wav",
            atWorldPosition: EffectSpace.toWorldPosition(position),
            delay: 0
        )

        let texturePath = "effect\\alpha_center.tga"
        _ = context.assets?.texture(atPath: texturePath)

        let ring = launchPrimitive(.pp_2dcircle)
        ring.state.duration = duration
        ring.state.fadeOutCnt = 0
        ring.state.deltaPos2.y = -20.0
        ring.state.arcAngle = 10.0
        ring.state.innerSize = 10.0
        ring.state.radiusSpeed = 7.0
        ring.state.radiusAccel = -(ring.state.radiusSpeed / Float(ring.state.duration + 40)) * 2.0
        ring.state.texturePaths = [texturePath]
    }

    // MARK: - Inline OnProcess Cases (126...250)

    private func processRevive(context: EffectTickContext) {
        guard stateCnt % 25 == 0 else {
            return
        }

        let texturePath = "effect\\ring_yellow.tga"
        _ = context.assets?.texture(atPath: texturePath)

        let cylinder = launchPrimitive(.pp_3dcylinder)
        cylinder.state.duration = 60
        cylinder.state.longSpeed = 1.5
        cylinder.state.longAccel = 0.03
        cylinder.state.outerSize = 10.5
        cylinder.state.innerSpeed = -0.12
        cylinder.state.innerAccel = 0.003
        cylinder.state.outerSpeed = -0.12
        cylinder.state.outerAccel = 0.003
        cylinder.state.innerSize = 7.5
        cylinder.state.heightSize = 7.5
        cylinder.state.alpha = 240.0
        cylinder.state.fadeOutCnt = cylinder.state.duration - cylinder.state.duration / 2

        if stateCnt == 0 {
            cylinder.state.duration = duration
            cylinder.state.innerSpeed = 0
            cylinder.state.innerAccel = 0
            cylinder.state.longSpeed = 1.5
            cylinder.state.outerSize = 11.0
            cylinder.state.innerSize = 7.5
            cylinder.state.outerSpeed = 0
            cylinder.state.outerAccel = 0
            cylinder.state.fadeOutCnt = cylinder.state.duration - cylinder.state.duration / 10
        }

        cylinder.state.texturePaths = [texturePath]
    }

    private func processTopRank(context: EffectTickContext) {
        if stateCnt == 9998 {
            stateCnt = 0
        }

        if stateCnt == 0 {
            let texturePath = "effect\\LockOn128.tga"
            _ = context.assets?.texture(atPath: texturePath)

            let badge = launchPrimitive(.pp_3dtexture)
            badge.state.duration = 9999
            badge.state.longitude = 0
            badge.state.longSpeed = 4.5
            badge.state.roll = 90.0
            badge.state.widthSize = 4.0
            badge.state.heightSize = 4.0
            if count != 11 {
                let tintChannel = max(0, (10 - Int(count)) * 25)
                badge.state.red = 250
                badge.state.blue = tintChannel
                badge.state.green = tintChannel
            } else {
                badge.state.red = 0
                badge.state.blue = 0
                badge.state.green = 250
            }
            badge.state.texturePaths = [texturePath]
        }

        position.y = context.world.terrainHeight(atEffectX: position.x, effectZ: position.z) - 2.0
    }

    private func processPartyMarker(context: EffectTickContext) {
        if stateCnt == 9998 {
            stateCnt = 0
        }

        if stateCnt == 0 {
            let texturePath = "effect\\party.tga"
            _ = context.assets?.texture(atPath: texturePath)

            let marker = launchPrimitive(.pp_3dtexture)
            marker.state.duration = 9999
            marker.state.longitude = 0
            marker.state.roll = 90.0
            marker.state.widthSize = 4.0
            marker.state.heightSize = 4.0
            marker.state.red = 50
            marker.state.blue = 253
            marker.state.green = 50
            marker.state.texturePaths = [texturePath]
        }

        position.y = context.world.terrainHeight(atEffectX: position.x, effectZ: position.z) - 2.0
    }

    private func processBanjjakii(context: EffectTickContext) {
        guard stateCnt == 0 else {
            return
        }

        let spritePath = K2L("이팩트\\크리스마스.spr")
        let actionPath = K2L("이팩트\\크리스마스.act")
        _ = context.assets?.spriteAsset(spritePath: spritePath, actionPath: actionPath)

        if param[0] <= 0 {
            param[0] = 1.0
        }
        if param[1] < 1.0 {
            param[1] = 1.0
        }

        let ornament = launchPrimitive(.pp_3dparticle)
        ornament.state.pattern |= 0x200
        ornament.state.duration = 125
        ornament.state.deltaPos2.y = -10.0
        ornament.state.animSpeed = Int(param[1])
        ornament.state.spritePath = spritePath
        ornament.state.actionPath = actionPath
        let kind = Int.random(in: 0..<10)
        ornament.state.size = kind % 3 == 1 ? 0.01 : 1.0
        ornament.currentMotion = kind / 2
        ornament.initSegment()
    }

    private func processVenomDust2(context: EffectTickContext) {
        guard stateCnt % 5 == 0 else {
            return
        }

        let spritePath = K2L("이팩트\\particle3.spr")
        let actionPath = K2L("이팩트\\particle3.act")
        _ = context.assets?.spriteAsset(spritePath: spritePath, actionPath: actionPath)

        let cloud = launchPrimitive(.pp_3dparticle)
        cloud.state.duration = 10
        cloud.state.transform = EffectSpace.rotationX(radians: EffectSpace.radian(degrees: 90))
        cloud.state.speed = Float(Int.random(in: 0..<20) + 20) / 80.0
        cloud.state.accel = -(cloud.state.speed / Float(cloud.state.duration)) * 0.5
        cloud.state.size = 0.8
        cloud.state.rollSpeed = 3.0
        cloud.state.alpha = 70.0
        cloud.state.alphaSpeed = cloud.state.maxAlpha / 10.0
        cloud.state.fadeOutCnt = cloud.state.duration - cloud.state.duration / 5
        cloud.state.spritePath = spritePath
        cloud.state.actionPath = actionPath
        cloud.initSegment()
    }

    private func processSuiExplosion(context: EffectTickContext) -> Bool {
        if stateCnt == 0 {
            configureSTR(path: "sui_explosion.str")
            hit2(option: 1, context: context)
        } else if stateCnt == 3 || stateCnt == 7 || stateCnt == 9 {
            context.world.shakeCamera(amplitude: 1.0, duration: 0.35, frequency: 20.0)
        }

        return processEZ2STRRaised(context: context)
    }

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
}
