//
//  EffectTable.swift
//  RagnarokEffects
//
//  Created by Leon Li on 2026/4/30.
//

import RagnarokCore

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
        49: [ // EF_FIREHIT
            .str(
                fileName: "firehit%d.str",
                soundName: "effect\\ef_firehit.wav",
                attachedToTarget: true,
                randomNumberRange: 1...3
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
        312: [ // EF_HEAL
            .cylinder(
                textureName: "ring_white",
                soundName: "_heal_effect.wav",
                attachedToTarget: true,
                duration: 1.5,
                topRadius: 0.95,
                bottomRadius: 0.95,
                height: 8,
                color: [0.7, 1, 0.7],
                alpha: 0.2,
                fades: true,
                animation: .growHeight,
                blendMode: .one,
                rotatesContinuously: true
            ),
            .cylinder(
                textureName: "ring_white",
                attachedToTarget: true,
                duration: 1.5,
                topRadius: 1,
                bottomRadius: 1,
                height: 8,
                color: [0.7, 1, 0.7],
                alpha: 0.2,
                fades: true,
                animation: .growHeight,
                blendMode: .one,
                rotatesContinuously: true
            ),
            .`3D`(
                fileName: "effect\\pok3.tga",
                attachedToTarget: true,
                duration: 1.3,
                delayOffset: 0.4,
                duplicate: .init(count: 15, interval: 0.01),
                alphaMax: 0.6,
                fadesIn: true,
                fadesOut: true,
                blendMode: .one,
                zIndex: 1,
                positionRandomRange: [1.5, 1.5, 0],
                positionEndRandomRange: [0, 0, 2],
                positionEndRandomMiddle: [0, 0, 6],
                sizeStart: [9, 9],
                sizeEnd: [9, 9],
                sizeRandomRange: [2, 2]
            ),
            .`3D`(
                fileName: "effect\\pok3.tga",
                attachedToTarget: true,
                duration: 1.1,
                delayLate: 0.2,
                duplicate: .init(count: 7, interval: 0.05),
                alphaMax: 0.6,
                fadesIn: true,
                fadesOut: true,
                blendMode: .one,
                zIndex: 1,
                positionEnd: [0, 0, 5],
                positionRandomRange: [1, 1, 0],
                positionStartRandomRange: [0, 0, 1],
                sizeStart: [9, 9],
                sizeEnd: [9, 9],
                sizeRandomRange: [2, 2]
            ),
        ],
        320: [ // EF_HEAL3
            .cylinder(
                textureName: "ring_white",
                soundName: "_heal_effect.wav",
                attachedToTarget: true,
                duration: 1,
                topRadius: 0.95,
                bottomRadius: 0.95,
                height: 10,
                alpha: 0.2,
                fades: true,
                animation: .growHeight,
                blendMode: .one,
                rotatesContinuously: true
            ),
            .cylinder(
                textureName: "ring_white",
                attachedToTarget: true,
                duration: 1,
                topRadius: 1,
                bottomRadius: 1,
                height: 9,
                alpha: 0.2,
                fades: true,
                animation: .growHeight,
                blendMode: .one,
                rotatesContinuously: true
            ),
            .`3D`(
                fileName: "effect\\pok3.tga",
                attachedToTarget: true,
                duration: 1,
                delayOffset: 0.4,
                duplicate: .init(count: 10, interval: 0.01),
                alphaMax: 0.8,
                fadesIn: true,
                fadesOut: true,
                blendMode: .one,
                zIndex: 1,
                positionRandomRange: [1.5, 1.5, 0],
                positionEndRandomRange: [0, 0, 3],
                positionEndRandomMiddle: [0, 0, 6],
                sizeStart: [9, 9],
                sizeEnd: [9, 9],
                sizeRandomRange: [2, 2],
                sparkles: true,
                sparkleCount: 2
            ),
            .`3D`(
                fileName: "effect\\pok3.tga",
                attachedToTarget: true,
                duration: 0.9,
                delayLate: 0.2,
                duplicate: .init(count: 5, interval: 0.05),
                alphaMax: 0.8,
                fadesIn: true,
                fadesOut: true,
                blendMode: .one,
                zIndex: 1,
                positionEnd: [0, 0, 6],
                positionRandomRange: [1, 1, 0],
                positionStartRandomRange: [0, 0, 1],
                sizeStart: [9, 9],
                sizeEnd: [9, 9],
                sizeRandomRange: [2, 2],
                sparkles: true,
                sparkleCount: 2
            ),
        ],
        321: [ // EF_WARPZONE2
            .cylinder(
                textureName: "ring_blue",
                attachedToTarget: true,
                rendersBeforeEntities: true,
                repeats: true,
                duration: 4,
                duplicate: .init(count: 4, interval: 1),
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
                duplicate: .init(count: 4, interval: 1),
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
                duplicate: .init(count: 5, interval: 0.3),
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

    private static let namedTable: [String : [EffectDefinition]] = [
        "ef_firebolt": [
            .`3D`(
                fileNames: [
                    K2L("effect\\불화살1.tga"),
                    K2L("effect\\불화살2.tga"),
                    K2L("effect\\불화살3.tga"),
                    K2L("effect\\불화살4.tga"),
                    K2L("effect\\불화살5.tga"),
                    K2L("effect\\불화살6.tga"),
                ],
                frameDelay: 0.03,
                soundName: "effect\\ef_firearrow%d.wav",
                attachedToTarget: true,
                duration: 0.5,
                blendMode: .one,
                zIndex: 1,
                positionStart: [0, 0, 20],
                positionStartRandomRange: [1, 1, 0],
                positionStartRandomMiddle: [5, 2, 0],
                sizeStart: [100, 50],
                sizeEnd: [100, 50],
                angle: 112.5,
                randomNumberRange: 1...3
            ),
        ]
    ]

    public static var effectIDs: [Int] {
        table.keys.sorted()
    }

    public static func definitions(for effectReference: EffectReference) -> [EffectDefinition] {
        switch effectReference {
        case .id(let effectID):
            definitions(forEffectID: effectID)
        case .name(let effectName):
            definitions(forEffectName: effectName)
        }
    }

    public static func definitions(forEffectID effectID: Int) -> [EffectDefinition] {
        table[effectID] ?? []
    }

    public static func definitions(forEffectName effectName: String) -> [EffectDefinition] {
        namedTable[effectName] ?? []
    }
}
