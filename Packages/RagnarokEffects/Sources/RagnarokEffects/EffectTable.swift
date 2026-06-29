//
//  EffectTable.swift
//  RagnarokEffects
//
//  Created by Leon Li on 2026/4/30.
//

// Ported from roBrowserLegacy:
// https://github.com/MrAntares/roBrowserLegacy/blob/master/src/DB/Effects/EffectTable.js
public enum EffectTable {
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
                soundName: "effect\\magician_thunderstorm.wav",
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
        321: [ // EF_WARPZONE2
            .cylinder(
                textureName: "ring_blue",
                attachedToTarget: true,
                rendersBeforeEntities: true,
                repeats: true,
                duration: 4,
                duplicateCount: 4,
                duplicateInterval: 1,
                topRadius: 3.3,
                bottomRadius: 2,
                height: 1.1,
                color: [0.5, 0.5, 1],
                alpha: 0.4,
                fades: true,
                animation: .shrinkRadius,
                blendMode: .one
            ),
            .cylinder(
                textureName: "ring_blue",
                attachedToTarget: true,
                rendersBeforeEntities: true,
                repeats: true,
                duration: 4,
                duplicateCount: 4,
                duplicateInterval: 1,
                topRadius: 3.2,
                bottomRadius: 1.9,
                height: 1.1,
                color: [0.5, 0.5, 1],
                alpha: 0.4,
                fades: true,
                animation: .shrinkRadius,
                blendMode: .one
            ),
            .`3D`(
                fileName: "effect\\pok1.tga",
                attachedToTarget: true,
                rendersBeforeEntities: true,
                repeats: true,
                duration: 1,
                duplicateCount: 5,
                duplicateInterval: 0.3,
                color: [0.9, 1, 0.9],
                alphaMax: 1,
                fadesIn: true,
                fadesOut: true,
                blendMode: .one,
                zIndex: 1,
                positionStartRandomRange: [3, 3, 0],
                positionEndRandomRange: [0, 0, 2],
                positionEndRandomMiddle: [0, 0, 2],
                sizeStart: [50, 50],
                sizeEnd: [50, 50]
            ),
        ],
    ]

    public static func definitions(forEffectID effectID: Int) -> [EffectDefinition] {
        table[effectID] ?? []
    }
}
