//
//  EffectTable.swift
//  RagnarokGame
//
//  Created by Leon Li on 2026/4/30.
//

// Ported from roBrowserLegacy:
// https://github.com/MrAntares/roBrowserLegacy/blob/master/src/DB/Effects/EffectTable.js
enum EffectTable {
    private static let table: [Int : [EffectDefinition]] = [
        29: [ // EF_LIGHTBOLT
            .str(
                fileName: "lightning.str",
                attachedToTarget: true
            ),
            .str(
                fileName: "windhit%d.str",
                attachedToTarget: true,
                randomNumberRange: 1...3
            ),
        ],
        30: [ // EF_THUNDERSTORM
            .str(
                fileName: "thunderstorm.str",
                soundName: "effect/magician_thunderstorm.wav",
                attachedToTarget: false
            ),
        ],
        52: [ // EF_WINDHIT
            .str(
                fileName: "windhit%d.str",
                soundName: "_hit_fist%d.wav",
                attachedToTarget: true,
                randomNumberRange: 1...3
            ),
        ],
    ]

    static func definitions(forEffectID effectID: Int) -> [EffectDefinition] {
        table[effectID] ?? []
    }
}
