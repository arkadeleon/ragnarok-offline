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
            effects: [.id(29)],
            hitEffects: [.id(52)]
        ),
        .mg_thunderstorm: .init(
            effects: [.id(30)],
            hitEffects: [.id(52)]
        ),
        .mg_firebolt: .init(
            beforeHitEffects: [.name("ef_firebolt")],
            hitEffects: [.id(49)]
        ),
        .al_heal: .init(
            effects: [.id(312)],
            hitEffects: [.id(320)]
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
