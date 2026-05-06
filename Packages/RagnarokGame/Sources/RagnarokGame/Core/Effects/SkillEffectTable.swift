//
//  SkillEffectTable.swift
//  RagnarokGame
//
//  Created by Leon Li on 2026/4/30.
//

import RagnarokConstants

// Ported from roBrowserLegacy:
// https://github.com/MrAntares/roBrowserLegacy/blob/master/src/DB/Skills/SkillEffect.js
enum SkillEffectTable {
    private static let table: [SkillID : SkillEffectDefinition] = [
        .mg_lightningbolt: .init(
            effectIDs: [.id(29)],
            hitEffectIDs: [.id(52)]
        ),
        .mg_thunderstorm: .init(
            effectIDs: [.id(30)],
            hitEffectIDs: [.id(52)]
        ),
    ]

    static func effectIDs(for skillID: SkillID) -> [Int] {
        guard let definition = table[skillID] else {
            return []
        }
        return definition.effectIDs.compactMap(\.effectID)
    }

    static func hitEffectIDs(for skillID: SkillID) -> [Int] {
        guard let definition = table[skillID] else {
            return []
        }
        return definition.hitEffectIDs.compactMap(\.effectID)
    }
}
