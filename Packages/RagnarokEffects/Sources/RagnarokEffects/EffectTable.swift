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
    // Keep entries sorted in ascending order by `EffectID.rawValue`.
    private static let table: [EffectID : [EffectDefinition]] = [
        .ef_hit1: [
            .`3D`(
                fileName: "effect\\pok3.tga",
                duration: 0.3,
                duplicate: .init(count: 4, interval: 0),
                attachedToTarget: false,
                zIndex: 1,
                alphaMin: 0.3,
                alphaMax: 0.8,
                fadesIn: true,
                fadesOut: true,
                sparkles: true,
                positionStart: [0, 0, 1],
                positionEndXRandomRange: -2...2,
                positionEndYRandomRange: -2...2,
                positionEndZRandomRange: -2...2,
                size: [10, 10],
                sizeXRandomRange: -10...30,
                sizeYRandomRange: -10...30,
                smoothSize: true
            ),
        ],
        .ef_hit2: [
            .`2D`(
                fileName: "effect\\lens1.tga",
                soundName: "effect\\ef_hit2.wav",
                duration: 0.25,
                durationRandomRange: 0.2...0.35,
                attachedToTarget: false,
                overlay: true,
                zIndex: 1,
                alphaMax: 12,
                fadesOut: true,
                circlePattern: true,
                circleInnerSize: 2.2,
                circleOuterSizeRandomRange: 5...6,
                sizeEnd: [1, 100],
                sizeStartXRandomRange: 25...40,
                sizeStartYRandomRange: 10...10,
                sizeEndYRandomRange: 250...300,
                angleRandomRange: 0...35
            ),
            .`2D`(
                fileName: "effect\\lens2.tga",
                duration: 0.25,
                durationRandomRange: 0.2...0.35,
                attachedToTarget: false,
                overlay: true,
                zIndex: 1,
                alphaMax: 12,
                fadesOut: true,
                circlePattern: true,
                circleInnerSize: 2.2,
                circleOuterSizeRandomRange: 5...6,
                sizeEnd: [1, 100],
                sizeStartXRandomRange: 25...40,
                sizeStartYRandomRange: 10...10,
                sizeEndYRandomRange: 250...300,
                angleRandomRange: 50...85
            ),
            .`2D`(
                fileName: "effect\\lens1.tga",
                duration: 0.25,
                durationRandomRange: 0.2...0.35,
                attachedToTarget: false,
                overlay: true,
                zIndex: 1,
                alphaMax: 12,
                fadesOut: true,
                circlePattern: true,
                circleInnerSize: 2.2,
                circleOuterSizeRandomRange: 5...6,
                sizeEnd: [1, 100],
                sizeStartXRandomRange: 25...40,
                sizeStartYRandomRange: 10...10,
                sizeEndYRandomRange: 250...300,
                angleRandomRange: 100...135
            ),
            .`2D`(
                fileName: "effect\\lens2.tga",
                duration: 0.25,
                durationRandomRange: 0.2...0.35,
                attachedToTarget: false,
                overlay: true,
                zIndex: 1,
                alphaMax: 12,
                fadesOut: true,
                circlePattern: true,
                circleInnerSize: 2.2,
                circleOuterSizeRandomRange: 5...6,
                sizeEnd: [1, 100],
                sizeStartXRandomRange: 25...40,
                sizeStartYRandomRange: 10...10,
                sizeEndYRandomRange: 250...300,
                angleRandomRange: 150...185
            ),
            .`2D`(
                fileName: "effect\\lens1.tga",
                duration: 0.25,
                durationRandomRange: 0.2...0.35,
                attachedToTarget: false,
                overlay: true,
                zIndex: 1,
                alphaMax: 12,
                fadesOut: true,
                circlePattern: true,
                circleInnerSize: 2.2,
                circleOuterSizeRandomRange: 5...6,
                sizeEnd: [1, 100],
                sizeStartXRandomRange: 25...40,
                sizeStartYRandomRange: 10...10,
                sizeEndYRandomRange: 250...300,
                angleRandomRange: 200...235
            ),
            .`2D`(
                fileName: "effect\\lens2.tga",
                duration: 0.25,
                durationRandomRange: 0.2...0.35,
                attachedToTarget: false,
                overlay: true,
                zIndex: 1,
                alphaMax: 12,
                fadesOut: true,
                circlePattern: true,
                circleInnerSize: 2.2,
                circleOuterSizeRandomRange: 5...6,
                sizeEnd: [1, 100],
                sizeStartXRandomRange: 25...40,
                sizeStartYRandomRange: 10...10,
                sizeEndYRandomRange: 250...300,
                angleRandomRange: 255...290
            ),
            .`2D`(
                fileName: "effect\\lens1.tga",
                duration: 0.25,
                durationRandomRange: 0.2...0.35,
                attachedToTarget: false,
                overlay: true,
                zIndex: 1,
                alphaMax: 12,
                fadesOut: true,
                circlePattern: true,
                circleInnerSize: 2.2,
                circleOuterSizeRandomRange: 5...6,
                sizeEnd: [1, 100],
                sizeStartXRandomRange: 25...40,
                sizeStartYRandomRange: 10...10,
                sizeEndYRandomRange: 250...300,
                angleRandomRange: 300...335
            ),
            .`2D`(
                fileName: "effect\\lens2.tga",
                duration: 0.25,
                durationRandomRange: 0.2...0.35,
                attachedToTarget: false,
                overlay: true,
                zIndex: 1,
                alphaMax: 12,
                fadesOut: true,
                circlePattern: true,
                circleInnerSize: 2.2,
                circleOuterSizeRandomRange: 5...6,
                sizeEnd: [1, 100],
                sizeStartXRandomRange: 25...40,
                sizeStartYRandomRange: 10...10,
                sizeEndYRandomRange: 250...300,
                angleRandomRange: 340...360
            ),
        ],
        .ef_endure: [
            .`3D`(
                fileName: "effect\\endure.tga",
                soundName: "effect\\ef_endure.wav",
                duration: 1,
                attachedToTarget: true,
                zIndex: 10,
                fadesIn: true,
                fadesOut: true,
                offset: [0, 0, 2],
                sizeStart: [200, 200],
                sizeEnd: [70, 70],
                smoothSize: true
            ),
        ],
        .ef_beginspell: [
            .cylinder(
                textureName: "ring_yellow",
                soundName: "effect\\ef_beginspell.wav",
                duration: 1,
                attachedToTarget: true,
                blendMode: .one,
                alpha: 0.8,
                fades: true,
                topRadius: 5,
                bottomRadius: 1,
                height: 4,
                animation: .growTopRadius
            ),
        ],
        .ef_soulstrike: [
            .`3D`(
                fileName: "effect\\pok3.tga",
                soundName: "effect\\ef_soulstrike.wav",
                duration: 0.2,
                delayLate: 0.25,
                attachedToTarget: true,
                zIndex: 1,
                fadesIn: true,
                fadesOut: true,
                positionStartZRandomRange: -5...5,
                smoothPositionAxes: EffectAxes(x: false, y: false, z: true),
                movesFromSource: true,
                size: [50, 50]
            ),
            .`3D`(
                spriteName: K2L("이팩트\\particle1"),
                playSprite: true,
                duration: 0.25,
                duplicate: .init(count: 5, interval: 0.02),
                attachedToTarget: false,
                zOffsetStart: 3,
                arc: 4,
                retreat: 3,
                movesFromSource: true,
                sizeStart: [100, 100],
                sizeEnd: [500, 500],
                rotatesToTarget: true,
                soulStrikePattern: true
            ),
        ],
        .ef_bash: [
            .cylinder(
                textureName: "alpha_down",
                soundName: "effect\\ef_bash.wav",
                duration: 1,
                attachedToTarget: true,
                zIndex: 1,
                alpha: 0.6,
                fades: true,
                topRadius: 2,
                bottomRadius: 0.1,
                height: 0,
                animation: .growTopRadius,
                positionOffset: [0, 0, 1.5],
                rotationDegrees: [-90, 0, 0],
                rotatesContinuously: true,
                fixedPerspective: true
            ),
            .cylinder(
                textureName: "alpha_center",
                duration: 1,
                duplicate: .init(count: 10, interval: 0),
                attachedToTarget: true,
                zIndex: 1.1,
                alpha: 0.6,
                fades: true,
                topRadius: 2.5,
                bottomRadius: 0.01,
                height: 0,
                totalCircleSides: 30,
                visibleCircleSides: 1,
                animation: .growTopRadius,
                positionOffset: [0, 0, 1.5],
                rotationDegrees: [-90, 0, 0],
                rotationZRandomRange: 0...360,
                rotatesContinuously: true,
                fixedPerspective: true
            ),
            .cylinder(
                textureName: "alpha_center",
                duration: 1,
                duplicate: .init(count: 8, interval: 0),
                attachedToTarget: true,
                zIndex: 1.2,
                alpha: 0.6,
                fades: true,
                topRadius: 4,
                bottomRadius: 0.01,
                height: 0,
                totalCircleSides: 30,
                visibleCircleSides: 1,
                animation: .growTopRadius,
                positionOffset: [0, 0, 1.5],
                rotationDegrees: [-90, 0, 0],
                rotationZRandomRange: 0...360,
                rotatesContinuously: true,
                fixedPerspective: true
            ),
        ],
        .ef_fireball: [
            .`3D`(
                spriteName: K2L("이팩트\\fireball"),
                playSprite: true,
                duration: 0.25,
                delayOffset: 0.16,
                duplicate: .init(count: 5, interval: 0, delayOffsetDelta: -0.04, alphaMaxDelta: 0.2),
                attachedToTarget: true,
                zIndex: 1,
                alphaMax: 0.2,
                offset: [0, 0, 2],
                movesFromSource: true,
                size: [200, 200],
                rotatesToTarget: true,
                rotatesWithCamera: true
            ),
            .wav(
                soundName: "effect\\ef_fireball.wav"
            ),
        ],
        .ef_frostdiver: [
            // The ice traveling to the target has no definition yet.
        ],
        .ef_frostdiver2: [
            .str(
                fileName: "freeze.str",
                soundName: "effect\\ef_frostdiver2.wav",
                attachedToTarget: true
            ),
        ],
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
                duplicate: .init(count: 7, interval: 0.2),
                attachedToTarget: true,
                alphaMax: 1,
                fadesOut: true,
                positionXRandomRange: -1.5...1.5,
                positionYRandomRange: -1...1,
                positionStartZRandomRange: 0...2,
                positionEndZRandomRange: 5...7,
                size: [2.5, 45],
                sizeYRandomRange: 30...60
            ),
            .`3D`(
                fileName: "effect\\ac_center2.tga",
                duration: 1,
                delayOffset: 0.4,
                duplicate: .init(count: 3, interval: 0.2),
                attachedToTarget: true,
                alphaMax: 0.75,
                fadesOut: true,
                positionXRandomRange: -1.5...1.5,
                positionYRandomRange: -1...1,
                positionStartZRandomRange: 0...2,
                positionEndZRandomRange: 5...7,
                size: [2.5, 45],
                sizeYRandomRange: 30...60
            ),
            .`3D`(
                fileName: "effect\\ac_center2.tga",
                duration: 1,
                duplicate: .init(count: 10, interval: 0),
                attachedToTarget: true,
                alphaMax: 1,
                fadesOut: true,
                positionXRandomRange: -1.5...1.5,
                positionYRandomRange: -1...1,
                positionStartZRandomRange: 0...2,
                positionEndZRandomRange: 5...7,
                size: [2.5, 45],
                sizeYRandomRange: 30...60
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
                size: [100, 45],
                smoothSize: true
            ),
        ],
        .ef_decagility: [
            .`3D`(
                fileName: "effect\\ac_center2.tga",
                duration: 1,
                duplicate: .init(count: 20, interval: 0),
                attachedToTarget: true,
                alphaMax: 1,
                fadesOut: true,
                positionXRandomRange: -1.5...1.5,
                positionYRandomRange: -1...1,
                positionStartZRandomRange: 5...7,
                positionEndZRandomRange: 0...2,
                size: [2.5, 45],
                sizeYRandomRange: 30...60
            ),
            .`3D`(
                fileName: "effect\\slow.bmp",
                soundName: "effect\\ef_decagility.wav",
                duration: 1,
                attachedToTarget: true,
                zIndex: 10,
                alphaMax: 1,
                fadesIn: true,
                fadesOut: true,
                positionStart: [0, 0, 2.8],
                positionEnd: [0, 0, 0.4],
                size: [100, 45],
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
        .ef_signum: [
            .str(
                fileName: "cross.str",
                soundName: "effect\\ef_signum.wav",
                attachedToTarget: true
            ),
        ],
        .ef_angelus: [
            .str(
                fileName: "angelus.str",
                soundName: "effect\\ef_angelus.wav",
                attachedToTarget: true
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
                positionEndXRandomRange: -3...3,
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
                size: [100, 100],
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
        .ef_coldhit: [
            .wav(
                soundName: "_hit_fist%d.wav",
                randomNumberRange: 3...4
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
                duplicate: .init(count: 6, interval: 0),
                attachedToTarget: true,
                zIndex: 1,
                alphaMax: 1,
                fadesIn: true,
                fadesOut: true,
                sparkles: true,
                sparkleCount: 2,
                positionXRandomRange: -1.2...1.2,
                positionYRandomRange: -1...1,
                positionStartZRandomRange: 3.5...7.5,
                positionEndZRandomRange: 0.5...1.5,
                size: [50, 50]
            ),
            .`3D`(
                spriteName: K2L("이팩트\\particle6"),
                duration: 1.2,
                delayOffset: 0.4,
                duplicate: .init(count: 6, interval: 0),
                attachedToTarget: true,
                zIndex: 1,
                alphaMax: 1,
                fadesIn: true,
                fadesOut: true,
                positionXRandomRange: -1.4...1.4,
                positionYRandomRange: -1.1...1.1,
                positionStartZRandomRange: 3.5...7.5,
                positionEndZRandomRange: 0.5...1.5,
                size: [50, 50]
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
                size: [140, 140]
            ),
        ],
        .ef_beginspell2: [
            .cylinder(
                textureName: "ring_blue",
                duration: 0.9,
                attachedToTarget: true,
                blendMode: .one,
                color: [0.5, 0.5, 1],
                alpha: 0.2,
                fades: true,
                topRadius: 1,
                bottomRadius: 1,
                height: 30,
                animation: .growHeight,
                rotatesContinuously: true
            ),
            .cylinder(
                textureName: "ring_blue",
                duration: 0.9,
                attachedToTarget: true,
                blendMode: .one,
                color: [0.5, 0.5, 1],
                alpha: 0.2,
                fades: true,
                topRadius: 1.3,
                bottomRadius: 1,
                height: 1,
                animation: .growHeight,
                rotatesContinuously: true
            ),
            .cylinder(
                textureName: "ring_blue",
                soundName: "effect\\ef_beginspell.wav",
                duration: 0.9,
                attachedToTarget: true,
                blendMode: .one,
                color: [0.5, 0.5, 1],
                alpha: 0.6,
                fades: true,
                topRadius: 4,
                bottomRadius: 1,
                height: 3,
                animation: .growTopRadius,
                rotatesContinuously: true
            ),
        ],
        .ef_beginspell3: [
            .cylinder(
                textureName: "ring_red",
                duration: 0.9,
                attachedToTarget: true,
                blendMode: .one,
                color: [1, 0.4, 0.4],
                alpha: 0.3,
                fades: true,
                topRadius: 1,
                bottomRadius: 1,
                height: 30,
                animation: .growHeight,
                rotatesContinuously: true
            ),
            .cylinder(
                textureName: "ring_red",
                duration: 0.9,
                attachedToTarget: true,
                blendMode: .one,
                color: [1, 0.4, 0.4],
                alpha: 0.7,
                fades: true,
                topRadius: 1.3,
                bottomRadius: 1,
                height: 2,
                animation: .growHeight,
                rotatesContinuously: true
            ),
            .cylinder(
                textureName: "ring_red",
                soundName: "effect\\ef_beginspell.wav",
                duration: 0.9,
                attachedToTarget: true,
                blendMode: .one,
                color: [1, 0.4, 0.4],
                alpha: 0.7,
                fades: true,
                topRadius: 4,
                bottomRadius: 1,
                height: 3,
                animation: .growTopRadius,
                rotatesContinuously: true
            ),
        ],
        .ef_beginspell4: [
            .cylinder(
                textureName: "ring_white",
                duration: 0.9,
                attachedToTarget: true,
                blendMode: .one,
                color: [0.6, 1, 0.6],
                alpha: 0.3,
                fades: true,
                topRadius: 1,
                bottomRadius: 1,
                height: 30,
                animation: .growHeight,
                rotatesContinuously: true
            ),
            .cylinder(
                textureName: "ring_white",
                duration: 0.9,
                attachedToTarget: true,
                blendMode: .one,
                color: [0.6, 1, 0.6],
                alpha: 0.6,
                fades: true,
                topRadius: 1.3,
                bottomRadius: 1,
                height: 2,
                animation: .growHeight,
                rotatesContinuously: true
            ),
            .cylinder(
                textureName: "ring_white",
                soundName: "effect\\ef_beginspell.wav",
                duration: 0.9,
                attachedToTarget: true,
                blendMode: .one,
                color: [0.6, 1, 0.6],
                alpha: 0.6,
                fades: true,
                topRadius: 4,
                bottomRadius: 1,
                height: 3,
                animation: .growTopRadius,
                rotatesContinuously: true
            ),
        ],
        .ef_beginspell5: [
            .cylinder(
                textureName: "ring_yellow",
                duration: 0.9,
                attachedToTarget: true,
                blendMode: .oneMinusSourceAlpha,
                alpha: 0.5,
                fades: true,
                topRadius: 1,
                bottomRadius: 1,
                height: 30,
                animation: .growHeight,
                rotatesContinuously: true
            ),
            .cylinder(
                textureName: "ring_yellow",
                duration: 0.9,
                attachedToTarget: true,
                blendMode: .oneMinusSourceAlpha,
                alpha: 1,
                fades: true,
                topRadius: 1.2,
                bottomRadius: 1.1,
                height: 3,
                animation: .growHeight,
                rotatesContinuously: true
            ),
            .cylinder(
                textureName: "ring_yellow",
                soundName: "effect\\ef_beginspell.wav",
                duration: 0.9,
                attachedToTarget: true,
                blendMode: .oneMinusSourceAlpha,
                alpha: 1,
                fades: true,
                topRadius: 4,
                bottomRadius: 1,
                height: 3,
                animation: .growTopRadius,
                rotatesContinuously: true
            ),
        ],
        .ef_beginspell6: [
            .cylinder(
                textureName: "ring_white",
                soundName: "effect\\ef_beginspell.wav",
                duration: 0.9,
                attachedToTarget: true,
                blendMode: .one,
                alpha: 0.8,
                fades: true,
                topRadius: 5,
                bottomRadius: 1,
                height: 4,
                animation: .growTopRadius,
                rotatesContinuously: true
            ),
        ],
        .ef_beginspell7: [
            .cylinder(
                textureName: "ring_purple",
                duration: 0.9,
                attachedToTarget: true,
                blendMode: .one,
                color: [0.8, 0.8, 0.8],
                alpha: 0.3,
                fades: true,
                topRadius: 1,
                bottomRadius: 1,
                height: 30,
                animation: .growHeight,
                rotatesContinuously: true
            ),
            .cylinder(
                textureName: "ring_purple",
                duration: 0.9,
                attachedToTarget: true,
                blendMode: .one,
                color: [0.8, 0.8, 0.8],
                alpha: 0.7,
                fades: true,
                topRadius: 1.3,
                bottomRadius: 1,
                height: 3,
                animation: .growHeight,
                rotatesContinuously: true
            ),
            .cylinder(
                textureName: "ring_purple",
                soundName: "effect\\ef_beginspell.wav",
                duration: 0.9,
                attachedToTarget: true,
                blendMode: .one,
                color: [0.8, 0.8, 0.8],
                alpha: 0.7,
                fades: true,
                topRadius: 4,
                bottomRadius: 1,
                height: 3,
                animation: .growTopRadius,
                rotatesContinuously: true
            ),
        ],
        .ef_cure: [
            .str(
                fileName: "cure.str",
                soundName: "effect\\acolyte_cure.wav",
                attachedToTarget: true
            ),
        ],
        .ef_provoke: [
            .str(
                fileName: "provoke.str",
                soundName: "effect\\swordman_provoke.wav",
                attachedToTarget: true
            ),
        ],
        .ef_resurrection: [
            .str(
                fileName: "resurrection.str",
                soundName: "effect\\priest_resurrection.wav",
                attachedToTarget: true
            ),
        ],
        .ef_magnus: [
            .str(
                fileName: "magnus.str",
                soundName: "effect\\priest_magnus.wav",
                attachedToTarget: false
            ),
        ],
        .ef_revive: [
            .wav(
                soundName: "effect\\priest_resurrection.wav"
            ),
        ],
        .ef_concentration: [
            .str(
                fileName: "concentration.str",
                soundName: "effect\\ac_concentration.wav",
                attachedToTarget: true
            ),
        ],
        .ef_joblvup: [
            .str(
                fileName: "joblvup.str",
                attachedToTarget: true
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
                positionXRandomRange: -1.5...1.5,
                positionYRandomRange: -1.5...1.5,
                positionEndZRandomRange: 4...8,
                size: [9, 9],
                sizeXRandomRange: 7...11,
                sizeYRandomRange: 7...11
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
                positionXRandomRange: -1...1,
                positionYRandomRange: -1...1,
                positionStartZRandomRange: -1...1,
                size: [9, 9],
                sizeXRandomRange: 7...11,
                sizeYRandomRange: 7...11
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
                positionXRandomRange: -1.5...1.5,
                positionYRandomRange: -1.5...1.5,
                positionEndZRandomRange: 3...9,
                size: [9, 9],
                sizeXRandomRange: 7...11,
                sizeYRandomRange: 7...11
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
                positionXRandomRange: -1...1,
                positionYRandomRange: -1...1,
                positionStartZRandomRange: -1...1,
                size: [9, 9],
                sizeXRandomRange: 7...11,
                sizeYRandomRange: 7...11
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
                positionStartXRandomRange: -3...3,
                positionStartYRandomRange: -3...3,
                positionEndZRandomRange: 0...4,
                size: [50, 50]
            ),
        ],
        .ef_angel: [
            .str(
                fileName: "angel.str",
                soundName: "levelup.wav",
                attachedToTarget: true
            ),
        ],
        .ef_darkcasting: [
            .cylinder(
                textureName: "ring_black",
                soundName: "effect\\ef_beginspell.wav",
                duration: 0.9,
                attachedToTarget: true,
                blendMode: .one,
                alpha: 0.8,
                fades: true,
                topRadius: 5,
                bottomRadius: 1,
                height: 4,
                animation: .growTopRadius,
                rotatesContinuously: true
            ),
        ],
    ]

    private static let namedTable: [String : [EffectDefinition]] = [
        "ef_arrow_projectile": [
            .`3D`(
                spriteName: "npc\\skel_archer_arrow",
                duration: 0.14,
                attachedToTarget: true,
                zIndex: 1,
                alphaMax: 1,
                fadesIn: true,
                fadesOut: true,
                offset: [0, 0, 1],
                movesFromSource: true,
                size: [100, 100],
                angle: 180,
                rotatesToTarget: true,
                rotatesWithCamera: true
            ),
        ],
        "ef_arrow_shower_projectile": [
            .`3D`(
                spriteName: "npc\\skel_archer_arrow",
                duration: 0.14,
                duplicate: EffectParameters.Duplicate(count: 10, interval: 0),
                attachedToTarget: false,
                zIndex: 1,
                alphaMax: 1,
                fadesIn: true,
                fadesOut: true,
                offset: [0, 0, 1],
                positionEndXRandomRange: -1.5...1.5,
                positionEndYRandomRange: -1.5...1.5,
                movesFromSource: true,
                size: [100, 100],
                angle: 180,
                rotatesToTarget: true,
                rotatesWithCamera: true
            ),
        ],
        "ef_coldbolt": [
            .`3D`(
                fileName: "effect\\icearrow.tga",
                soundName: "effect\\ef_icearrow%d.wav",
                randomNumberRange: 1...3,
                duration: 0.5,
                attachedToTarget: true,
                zIndex: 1,
                positionStart: [0, 0, 20],
                positionStartXRandomRange: 4...6,
                positionStartYRandomRange: 1...3,
                size: [50, 50],
                angle: 112.5
            ),
            .cylinder(
                textureName: "ring_blue",
                duration: 1,
                delayLate: 0.5,
                attachedToTarget: false,
                alpha: 0.7,
                fades: true,
                topRadius: 5,
                bottomRadius: 3,
                height: 0.1,
                animation: .growRadius,
                rotatesContinuously: true
            ),
        ],
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
                positionStartXRandomRange: 4...6,
                positionStartYRandomRange: 1...3,
                size: [100, 50],
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
