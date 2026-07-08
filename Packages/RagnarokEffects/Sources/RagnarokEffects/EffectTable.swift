//
//  EffectTable.swift
//  RagnarokEffects
//
//  Created by Leon Li on 2026/4/30.
//

import Foundation
import RagnarokConstants
import RagnarokCore

// Ported from roBrowserLegacy:
// https://github.com/MrAntares/roBrowserLegacy/blob/master/src/DB/Effects/EffectTable.js
public enum EffectTable {
    private static let table: [EffectID : [EffectDefinition]] = [
        .ef_lightbolt: [
            .str(
                fileName: "lightning.str",
                attachedToTarget: true
            ),
            .str(
                fileName: "windhit%d.str",
                randomNumberRange: 1...3,
                attachedToTarget: true
            ),
        ],
        .ef_thunderstorm: [
            .str(
                fileName: "thunderstorm.str",
                soundName: "effect\\magician_thunderstorm.wav",
                attachedToTarget: false
            ),
        ],
        .ef_incagility: [
            .`3D`(
                fileName: "effect\\ac_center2.tga",
                duration: 1,
                delayLate: 0.5,
                duplicate: .init(count: 7),
                attachedToTarget: true,
                alphaMax: 1,
                fadesOut: true,
                positionRandomRange: [1.5, 1, 0],
                positionStartRandomRange: [0, 0, 1],
                positionStartRandomMiddle: [0, 0, 1],
                positionEndRandomRange: [0, 0, 1],
                positionEndRandomMiddle: [0, 0, 6],
                sizeStart: [2.5, 45],
                sizeEnd: [2.5, 45],
                sizeRandomRange: [0, 15]
            ),
            .`3D`(
                fileName: "effect\\ac_center2.tga",
                duration: 1,
                delayOffset: 0.4,
                duplicate: .init(count: 3),
                attachedToTarget: true,
                alphaMax: 0.75,
                fadesOut: true,
                positionRandomRange: [1.5, 1, 0],
                positionStartRandomRange: [0, 0, 1],
                positionStartRandomMiddle: [0, 0, 1],
                positionEndRandomRange: [0, 0, 1],
                positionEndRandomMiddle: [0, 0, 6],
                sizeStart: [2.5, 45],
                sizeEnd: [2.5, 45],
                sizeRandomRange: [0, 15]
            ),
            .`3D`(
                fileName: "effect\\ac_center2.tga",
                duration: 1,
                duplicate: .init(count: 10),
                attachedToTarget: true,
                alphaMax: 1,
                fadesOut: true,
                positionRandomRange: [1.5, 1, 0],
                positionStartRandomRange: [0, 0, 1],
                positionStartRandomMiddle: [0, 0, 1],
                positionEndRandomRange: [0, 0, 1],
                positionEndRandomMiddle: [0, 0, 6],
                sizeStart: [2.5, 45],
                sizeEnd: [2.5, 45],
                sizeRandomRange: [0, 15]
            ),
            .`3D`(
                fileName: "effect\\agi_up.bmp",
                soundName: "effect\\ef_incagility.wav",
                duration: 1,
                attachedToTarget: true,
                overlay: true,
                zIndex: 10,
                alphaMax: 1,
                fadesIn: true,
                fadesOut: true,
                positionStart: [0, 0, 0.4],
                positionEnd: [0, 0, 3],
                sizeStart: [100, 45],
                sizeEnd: [100, 45],
                smoothSize: true
            ),
        ],
        .ef_aqua: [
            .spr(
                fileName: K2L("성수뜨기"),
                soundName: "effect\\ef_aqua.wav",
                attachedToTarget: true,
                rendersAtHead: true
            ),
        ],
        .ef_smoke: [
            .`3D`(
                spriteName: K2L("이팩트\\굴뚝연기"),
                duration: 10,
                repeats: true,
                delay: 0.1,
                duplicate: .init(count: 10, interval: 1),
                attachedToTarget: false,
                alphaMax: 0.8,
                fadesOut: true,
                positionEnd: [0, 0, 20],
                positionEndRandomRange: [3, 0, 0],
                smoothPositionAxes: EffectAxes(x: true, y: false, z: false),
                sizeStart: [70, 70],
                sizeEnd: [300, 300],
                smoothSize: true,
                angle: -90,
                targetAngle: 0,
                rotates: true,
                rotatesWithCamera: true
            ),
        ],
        .ef_torch: [
            .`3D`(
                spriteName: K2L("이팩트\\torch_01"),
                playSprite: true,
                duration: 0.6,
                repeats: true,
                attachedToTarget: true,
                offset: [0.1, 0, 0.8],
                sizeStart: [100, 100],
                sizeEnd: [100, 100],
                angle: 270,
                rotatesToTarget: true
            ),
        ],
        .ef_firehit: [
            .str(
                fileName: "firehit%d.str",
                soundName: "effect\\ef_firehit.wav",
                randomNumberRange: 1...3,
                attachedToTarget: true
            ),
        ],
        .ef_windhit: [
            .str(
                fileName: "windhit%d.str",
                soundName: "_hit_fist%d.wav",
                randomNumberRange: 1...3,
                attachedToTarget: true
            ),
        ],
        .ef_blessing: [
            .spr(
                fileName: K2L("축복"),
                actionIndex: 0,
                frameInterval: 0.03,
                duration: 1.5,
                repeats: true,
                isStackable: true,
                attachedToTarget: true,
                rendersAtHead: true,
                spriteOffset: [0, -120]
            ),
            .`3D`(
                spriteName: K2L("이팩트\\particle6"),
                duration: 1.2,
                delayOffset: 0.3,
                duplicate: .init(count: 6),
                attachedToTarget: true,
                zIndex: 1,
                alphaMax: 1,
                fadesIn: true,
                fadesOut: true,
                sparkles: true,
                sparkleCount: 2,
                positionRandomRange: [1.2, 1, 0],
                positionStartRandomRange: [0, 0, 2],
                positionStartRandomMiddle: [0, 0, 5.5],
                positionEndRandomRange: [0, 0, 0.5],
                positionEndRandomMiddle: [0, 0, 1],
                sizeStart: [50, 50],
                sizeEnd: [50, 50]
            ),
            .`3D`(
                spriteName: K2L("이팩트\\particle6"),
                duration: 1.2,
                delayOffset: 0.4,
                duplicate: .init(count: 6),
                attachedToTarget: true,
                zIndex: 1,
                alphaMax: 1,
                fadesIn: true,
                fadesOut: true,
                positionRandomRange: [1.4, 1.1, 0],
                positionStartRandomRange: [0, 0, 2],
                positionStartRandomMiddle: [0, 0, 5.5],
                positionEndRandomRange: [0, 0, 0.5],
                positionEndRandomMiddle: [0, 0, 1],
                sizeStart: [50, 50],
                sizeEnd: [50, 50]
            ),
            .`3D`(
                fileName: "effect\\pok2.tga",
                soundName: "effect\\ef_blessing.wav",
                duration: 2.5,
                attachedToTarget: false,
                zIndex: 10,
                blendMode: .one,
                color: [0.1, 0.75, 1],
                alphaMax: 0.3,
                fadesIn: true,
                fadesOut: true,
                sizeStart: [140, 140],
                sizeEnd: [140, 140]
            ),
        ],
        .ef_magnus: [
            .str(
                fileName: "magnus.str",
                soundName: "effect\\priest_magnus.wav",
                attachedToTarget: false
            ),
        ],
        .ef_heal: [
            .cylinder(
                textureName: "ring_white",
                soundName: "_heal_effect.wav",
                duration: 1.5,
                attachedToTarget: true,
                blendMode: .one,
                color: [0.7, 1, 0.7],
                alpha: 0.2,
                fades: true,
                topRadius: 0.95,
                bottomRadius: 0.95,
                height: 8,
                animation: .growHeight,
                rotatesContinuously: true
            ),
            .cylinder(
                textureName: "ring_white",
                duration: 1.5,
                attachedToTarget: true,
                blendMode: .one,
                color: [0.7, 1, 0.7],
                alpha: 0.2,
                fades: true,
                topRadius: 1,
                bottomRadius: 1,
                height: 8,
                animation: .growHeight,
                rotatesContinuously: true
            ),
            .`3D`(
                fileName: "effect\\pok3.tga",
                duration: 1.3,
                delayOffset: 0.4,
                duplicate: .init(count: 15, interval: 0.01),
                attachedToTarget: true,
                zIndex: 1,
                blendMode: .one,
                alphaMax: 0.6,
                fadesIn: true,
                fadesOut: true,
                positionRandomRange: [1.5, 1.5, 0],
                positionEndRandomRange: [0, 0, 2],
                positionEndRandomMiddle: [0, 0, 6],
                sizeStart: [9, 9],
                sizeEnd: [9, 9],
                sizeRandomRange: [2, 2]
            ),
            .`3D`(
                fileName: "effect\\pok3.tga",
                duration: 1.1,
                delayLate: 0.2,
                duplicate: .init(count: 7, interval: 0.05),
                attachedToTarget: true,
                zIndex: 1,
                blendMode: .one,
                alphaMax: 0.6,
                fadesIn: true,
                fadesOut: true,
                positionEnd: [0, 0, 5],
                positionRandomRange: [1, 1, 0],
                positionStartRandomRange: [0, 0, 1],
                sizeStart: [9, 9],
                sizeEnd: [9, 9],
                sizeRandomRange: [2, 2]
            ),
        ],
        .ef_heal3: [
            .cylinder(
                textureName: "ring_white",
                soundName: "_heal_effect.wav",
                duration: 1,
                attachedToTarget: true,
                blendMode: .one,
                alpha: 0.2,
                fades: true,
                topRadius: 0.95,
                bottomRadius: 0.95,
                height: 10,
                animation: .growHeight,
                rotatesContinuously: true
            ),
            .cylinder(
                textureName: "ring_white",
                duration: 1,
                attachedToTarget: true,
                blendMode: .one,
                alpha: 0.2,
                fades: true,
                topRadius: 1,
                bottomRadius: 1,
                height: 9,
                animation: .growHeight,
                rotatesContinuously: true
            ),
            .`3D`(
                fileName: "effect\\pok3.tga",
                duration: 1,
                delayOffset: 0.4,
                duplicate: .init(count: 10, interval: 0.01),
                attachedToTarget: true,
                zIndex: 1,
                blendMode: .one,
                alphaMax: 0.8,
                fadesIn: true,
                fadesOut: true,
                sparkles: true,
                sparkleCount: 2,
                positionRandomRange: [1.5, 1.5, 0],
                positionEndRandomRange: [0, 0, 3],
                positionEndRandomMiddle: [0, 0, 6],
                sizeStart: [9, 9],
                sizeEnd: [9, 9],
                sizeRandomRange: [2, 2]
            ),
            .`3D`(
                fileName: "effect\\pok3.tga",
                duration: 0.9,
                delayLate: 0.2,
                duplicate: .init(count: 5, interval: 0.05),
                attachedToTarget: true,
                zIndex: 1,
                blendMode: .one,
                alphaMax: 0.8,
                fadesIn: true,
                fadesOut: true,
                sparkles: true,
                sparkleCount: 2,
                positionEnd: [0, 0, 6],
                positionRandomRange: [1, 1, 0],
                positionStartRandomRange: [0, 0, 1],
                sizeStart: [9, 9],
                sizeEnd: [9, 9],
                sizeRandomRange: [2, 2]
            ),
        ],
        .ef_warpzone2: [
            .cylinder(
                textureName: "ring_blue",
                duration: 4,
                repeats: true,
                duplicate: .init(count: 4, interval: 1),
                attachedToTarget: true,
                rendersBeforeEntities: true,
                blendMode: .one,
                color: [0.5, 0.5, 1],
                alpha: 0.4,
                fades: true,
                topRadius: 3.3,
                bottomRadius: 2,
                height: 1.1,
                animation: .shrinkRadius
            ),
            .cylinder(
                textureName: "ring_blue",
                duration: 4,
                repeats: true,
                duplicate: .init(count: 4, interval: 1),
                attachedToTarget: true,
                rendersBeforeEntities: true,
                blendMode: .one,
                color: [0.5, 0.5, 1],
                alpha: 0.4,
                fades: true,
                topRadius: 3.2,
                bottomRadius: 1.9,
                height: 1.1,
                animation: .shrinkRadius
            ),
            .`3D`(
                fileName: "effect\\pok1.tga",
                duration: 1,
                repeats: true,
                duplicate: .init(count: 5, interval: 0.3),
                attachedToTarget: true,
                rendersBeforeEntities: true,
                zIndex: 1,
                blendMode: .one,
                color: [0.9, 1, 0.9],
                alphaMax: 1,
                fadesIn: true,
                fadesOut: true,
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
                randomNumberRange: 1...3,
                duration: 0.5,
                attachedToTarget: true,
                zIndex: 1,
                blendMode: .one,
                positionStart: [0, 0, 20],
                positionStartRandomRange: [1, 1, 0],
                positionStartRandomMiddle: [5, 2, 0],
                sizeStart: [100, 50],
                sizeEnd: [100, 50],
                angle: 112.5
            ),
        ]
    ]

    public static var effectIDs: [EffectID] {
        table.keys.sorted(using: KeyPathComparator(\.rawValue))
    }

    public static func definitions(for effectReference: EffectReference) -> [EffectDefinition] {
        switch effectReference {
        case .id(let effectID):
            definitions(for: effectID)
        case .name(let effectName):
            definitions(forEffectName: effectName)
        }
    }

    public static func definitions(for effectID: EffectID) -> [EffectDefinition] {
        table[effectID] ?? []
    }

    public static func definitions(forEffectName effectName: String) -> [EffectDefinition] {
        namedTable[effectName] ?? []
    }
}
