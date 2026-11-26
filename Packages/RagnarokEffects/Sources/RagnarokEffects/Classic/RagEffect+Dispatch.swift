//
//  RagEffect+Dispatch.swift
//  RagnarokEffects
//
//  Created by Leon Li on 2026/11/26.
//

import Foundation

extension RagEffect {

    // MARK: - Dispatch

    private nonisolated static let proceduralEffectIDs: [EffectID] = [
        .ef_entry,
        .ef_soulstrike,
        .ef_bash,
        .ef_steal,
        .ef_frostdiver2,
        .ef_wind,
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
        .ef_rainbow,
        .ef_bottom_fogwall,
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
        case .ef_entry:
            entry(context: context)
        case .ef_soulstrike:
            soulStrike(flag: 0, context: context)
        case .ef_bash:
            bash(context: context)
        case .ef_steal:
            steal(context: context)
        case .ef_frostdiver2:
            frostDiver2(context: context)
        case .ef_wind:
            healCloudRings(context: context)
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
        case .ef_rainbow:
            rainbow(texturePath: "effect\\alpha_center.tga", context: context)
        case .ef_bottom_fogwall:
            texturedPulseKind(texturePath: "effect\\ring_white.tga", kind: 2, context: context)
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
}
