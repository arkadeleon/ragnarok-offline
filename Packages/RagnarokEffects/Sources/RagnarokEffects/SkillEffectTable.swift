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
    private static let table: [SkillID : SkillEffectDefinition] = [
        .mg_lightningbolt: .init(
            effects: [.id(.ef_lightbolt)],
            hitEffects: [.id(.ef_windhit)]
        ),
        .mg_thunderstorm: .init(
            effects: [.id(.ef_thunderstorm)],
            hitEffects: [.id(.ef_windhit)]
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
    ]

    public static func effects(for skillID: SkillID) -> [EffectReference] {
        table[skillID]?.effects ?? []
    }

    public static func beforeHitEffects(for skillID: SkillID) -> [EffectReference] {
        table[skillID]?.beforeHitEffects ?? []
    }

    public static func hitEffects(for skillID: SkillID) -> [EffectReference] {
        table[skillID]?.hitEffects ?? []
    }
}
