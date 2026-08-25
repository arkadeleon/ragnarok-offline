//
//  SkillEffectTable.swift
//  RagnarokEffects
//
//  Created by Leon Li on 2026/4/30.
//

import RagnarokConstants

// Ported from roBrowserLegacy:
// https://github.com/MrAntares/roBrowserLegacy/blob/master/src/DB/Skills/SkillEffect.js
public enum SkillEffectTable {
    // Keep entries sorted in ascending order by `SkillID.rawValue`.
    private static let table: [SkillID : SkillEffectDefinition] = [
        .sm_bash: .init(
            beginCastEffects: [.id(.ef_bash)],
            hitEffects: [.id(.ef_hit2)]
        ),
        .sm_provoke: .init(
            successEffects: [.id(.ef_provoke)]
        ),
        .sm_endure: .init(
            effects: [.id(.ef_endure)]
        ),
        .mg_lightningbolt: .init(
            effects: [.id(.ef_lightbolt)],
            hitEffects: [.id(.ef_windhit)]
        ),
        .mg_thunderstorm: .init(
            effects: [.id(.ef_thunderstorm)],
            hitEffects: [.id(.ef_windhit)]
        ),
        .mg_napalmbeat: .init(
            hitEffects: [.id(.ef_hit2)]
        ),
        .mg_soulstrike: .init(
            beforeHitEffects: [.id(.ef_soulstrike)],
            hitEffects: [.id(.ef_hit2)]
        ),
        .mg_coldbolt: .init(
            beforeHitEffects: [.name("ef_coldbolt")],
            hitEffects: [.id(.ef_coldhit)]
        ),
        .mg_fireball: .init(
            beforeHitEffects: [.id(.ef_fireball)],
            hitEffects: [.id(.ef_firehit)]
        ),
        .mg_firebolt: .init(
            beforeHitEffects: [.name("ef_firebolt")],
            hitEffects: [.id(.ef_firehit)]
        ),
        .al_heal: .init(
            effects: [.id(.ef_heal)],
            hitEffects: [.id(.ef_heal3)]
        ),
        .al_incagi: .init(
            effects: [.id(.ef_incagility)]
        ),
        .al_blessing: .init(
            effects: [.id(.ef_blessing)]
        ),
        .ac_concentration: .init(
            effects: [.id(.ef_concentration)]
        ),
        .ac_double: .init(
            beginCastEffects: [.id(.ef_bash)],
            beforeHitEffects: [.name("ef_arrow_projectile")],
            hitEffects: [.id(.ef_hit2)]
        ),
        .ac_shower: .init(
            effects: [.name("ef_arrow_shower_projectile")],
            hitEffects: [.id(.ef_hit2)]
        ),
    ]

    public static func beginCastEffects(for skillID: SkillID) -> [EffectReference] {
        table[skillID]?.beginCastEffects ?? []
    }

    public static func effects(for skillID: SkillID) -> [EffectReference] {
        table[skillID]?.effects ?? []
    }

    public static func beforeHitEffects(for skillID: SkillID) -> [EffectReference] {
        table[skillID]?.beforeHitEffects ?? []
    }

    public static func hitEffects(for skillID: SkillID) -> [EffectReference] {
        table[skillID]?.hitEffects ?? []
    }

    public static func successEffects(for skillID: SkillID) -> [EffectReference] {
        table[skillID]?.successEffects ?? []
    }
}
