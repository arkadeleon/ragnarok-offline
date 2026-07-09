//
//  Effect3DDefinition.swift
//  RagnarokEffects
//
//  Created by Leon Li on 2026/6/29.
//

import Foundation
import simd

public struct EffectAxes: Sendable {
    public var x: Bool
    public var y: Bool
    public var z: Bool

    public static let none = EffectAxes(x: false, y: false, z: false)
}

// Ported from roBrowserLegacy EffectTable.js (Swift property → JS key):
// - fileName:                       file
// - fileNames:                      fileList
// - frameDelay:                     frameDelay
// - spriteName:                     spriteName, absoluteSpriteName (full path relative to data\sprite)
// - playSprite:                     playSprite
// - spriteFrameDelay:               sprDelay
// - soundName:                      wav
// - delaySound:                     delayWav
// - randomNumberRange:              rand
// - duration:                       duration
// - repeats:                        repeat
// - delayStart:                     delayStart
// - delay:                          delayFrame
// - delayOffset:                    delayOffset
// - delayLate:                      delayLate
// - duplicate:                      duplicate, timeBetweenDupli
// - attachedToTarget:               attachedEntity
// - rendersBeforeEntities:          renderBeforeEntities
// - overlay:                        overlay
// - zIndex:                         zIndex
// - blendMode:                      blendMode
// - color:                          red, green, blue
// - castsShadow:                    shadowTexture
// - alphaMin:                       alphaMin
// - alphaMax:                       alphaMax
// - fadesIn:                        fadeIn
// - fadesOut:                       fadeOut
// - sparkles:                       sparkling
// - sparkleCount:                   sparkNumber
// - sparkleCountRandomRange:        sparkNumber
// - offset:                         posx, posy, posz
// - positionStart:                  posxStart, posyStart, poszStart
// - positionEnd:                    posxEnd, posyEnd, poszEnd
// - positionXRandomRange:           posxRand
// - positionYRandomRange:           posyRand
// - positionZRandomRange:           poszRand
// - positionXRandomDifferenceRange: posxRandDiff
// - positionYRandomDifferenceRange: posyRandDiff
// - positionZRandomDifferenceRange: poszRandDiff
// - positionStartXRandomRange:      posxStartRand, posxStartRandMiddle
// - positionStartYRandomRange:      posyStartRand, posyStartRandMiddle
// - positionStartZRandomRange:      poszStartRand, poszStartRandMiddle
// - positionEndXRandomRange:        posxEndRand, posxEndRandMiddle
// - positionEndYRandomRange:        posyEndRand, posyEndRandMiddle
// - positionEndZRandomRange:        poszEndRand, poszEndRandMiddle
// - smoothPositionAxes:             posxSmooth, posySmooth, poszSmooth
// - zOffsetStart:                   zOffsetStart
// - zOffsetEnd:                     zOffsetEnd
// - arc:                            arc
// - retreat:                        retreat
// - movesFromSource:                fromSrc
// - movesToSource:                  toSrc
// - size:                           size, sizeX, sizeY
// - sizeStart:                      sizeStart, sizeStartX, sizeStartY
// - sizeEnd:                        sizeEnd, sizeEndX, sizeEndY
// - sizeXRandomRange:               sizeRand, sizeRandX, sizeRandXMiddle
// - sizeYRandomRange:               sizeRand, sizeRandY, sizeRandYMiddle
// - smoothSize:                     sizeSmooth
// - angle:                          angle
// - targetAngle:                    toAngle
// - rotates:                        rotate
// - rotationCount:                  nbOfRotation
// - rotationDelay:                  rotateLate
// - rotatesClockwise:               rotationClockwise
// - rotatePosition:                 rotatePosX, rotatePosY, rotatePosZ
// - rotatesToTarget:                rotateToTarget
// - rotatesWithCamera:              rotateWithCamera
// - soulStrikePattern:              soulStrikePattern
// - drainPattern:                   drainPattern
public struct Effect3DDefinition: Sendable {
    public var fileName: String?
    public var fileNames: [String]
    public var frameDelay: TimeInterval
    public var spriteName: String?
    public var playSprite: Bool
    public var spriteFrameDelay: TimeInterval
    public var soundName: String?
    public var delaySound: TimeInterval
    public var randomNumberRange: ClosedRange<Int>?

    public var duration: TimeInterval
    public var repeats: Bool
    public var delayStart: TimeInterval
    public var delay: TimeInterval
    public var delayOffset: TimeInterval
    public var delayLate: TimeInterval
    public var duplicate: EffectParameters.Duplicate

    public var attachedToTarget: Bool
    public var rendersBeforeEntities: Bool
    public var overlay: Bool
    public var zIndex: Float
    public var blendMode: EffectParameters.BlendMode
    public var color: SIMD3<Float>
    public var castsShadow: Bool

    public var alphaMin: Float
    public var alphaMax: Float
    public var fadesIn: Bool
    public var fadesOut: Bool
    public var sparkles: Bool
    public var sparkleCount: Float
    public var sparkleCountRandomRange: ClosedRange<Float>?

    public var offset: SIMD3<Float>
    public var positionStart: SIMD3<Float>
    public var positionEnd: SIMD3<Float>
    public var positionXRandomRange: ClosedRange<Float>?
    public var positionYRandomRange: ClosedRange<Float>?
    public var positionZRandomRange: ClosedRange<Float>?
    public var positionXRandomDifferenceRange: ClosedRange<Float>?
    public var positionYRandomDifferenceRange: ClosedRange<Float>?
    public var positionZRandomDifferenceRange: ClosedRange<Float>?
    public var positionStartXRandomRange: ClosedRange<Float>?
    public var positionStartYRandomRange: ClosedRange<Float>?
    public var positionStartZRandomRange: ClosedRange<Float>?
    public var positionEndXRandomRange: ClosedRange<Float>?
    public var positionEndYRandomRange: ClosedRange<Float>?
    public var positionEndZRandomRange: ClosedRange<Float>?
    public var smoothPositionAxes: EffectAxes
    public var zOffsetStart: Float
    public var zOffsetEnd: Float
    public var arc: Float
    public var retreat: Float
    public var movesFromSource: Bool
    public var movesToSource: Bool

    public var size: SIMD2<Float>
    public var sizeStart: SIMD2<Float>?
    public var sizeEnd: SIMD2<Float>?
    public var sizeXRandomRange: ClosedRange<Float>?
    public var sizeYRandomRange: ClosedRange<Float>?
    public var smoothSize: Bool

    public var angle: Float
    public var targetAngle: Float?
    public var rotates: Bool
    public var rotationCount: Float
    public var rotationDelay: TimeInterval
    public var rotatesClockwise: Bool
    public var rotatePosition: SIMD3<Float>
    public var rotatesToTarget: Bool
    public var rotatesWithCamera: Bool

    public var soulStrikePattern: Int?
    public var drainPattern: Int?

    public var primaryAssetName: String {
        fileName ?? fileNames.first ?? spriteName ?? ""
    }

    public func delay(duplicateID: Int) -> TimeInterval {
        delayStart
            + delay
            + delayOffset
            + duplicate.delayOffsetDelta * TimeInterval(duplicateID)
            + delayLate
            + duplicate.delayLateDelta * TimeInterval(duplicateID)
            + duplicate.interval * TimeInterval(duplicateID)
    }

    func resolved() -> Effect3DDefinition {
        var definition = self

        if let randomNumberRange {
            let randomNumber = Int.random(in: randomNumberRange)
            definition.fileName = fileName?.replacingOccurrences(of: "%d", with: "\(randomNumber)")
            definition.fileNames = fileNames.map {
                $0.replacingOccurrences(of: "%d", with: "\(randomNumber)")
            }
            definition.soundName = soundName?.replacingOccurrences(of: "%d", with: "\(randomNumber)")
            definition.randomNumberRange = nil
        }

        if let sparkleCountRandomRange {
            definition.sparkleCount = Float.random(in: sparkleCountRandomRange)
            definition.sparkleCountRandomRange = nil
        }

        return definition
    }
}

extension EffectDefinition {
    public static func `3D`(
        fileName: String? = nil,
        fileNames: [String] = [],
        frameDelay: TimeInterval = 0.1,
        spriteName: String? = nil,
        playSprite: Bool = false,
        spriteFrameDelay: TimeInterval = 0,
        soundName: String? = nil,
        delaySound: TimeInterval = 0,
        randomNumberRange: ClosedRange<Int>? = nil,
        duration: TimeInterval,
        repeats: Bool = false,
        delayStart: TimeInterval = 0,
        delay: TimeInterval = 0,
        delayOffset: TimeInterval = 0,
        delayLate: TimeInterval = 0,
        duplicate: EffectParameters.Duplicate = EffectParameters.Duplicate(),
        attachedToTarget: Bool,
        rendersBeforeEntities: Bool = false,
        overlay: Bool = false,
        zIndex: Float = 0,
        blendMode: EffectParameters.BlendMode = .oneMinusSourceAlpha,
        color: SIMD3<Float> = [1, 1, 1],
        castsShadow: Bool = false,
        alphaMin: Float = 0,
        alphaMax: Float = 1,
        fadesIn: Bool = false,
        fadesOut: Bool = false,
        sparkles: Bool = false,
        sparkleCount: Float = 1,
        sparkleCountRandomRange: ClosedRange<Float>? = nil,
        offset: SIMD3<Float> = .zero,
        positionStart: SIMD3<Float> = .zero,
        positionEnd: SIMD3<Float> = .zero,
        positionXRandomRange: ClosedRange<Float>? = nil,
        positionYRandomRange: ClosedRange<Float>? = nil,
        positionZRandomRange: ClosedRange<Float>? = nil,
        positionXRandomDifferenceRange: ClosedRange<Float>? = nil,
        positionYRandomDifferenceRange: ClosedRange<Float>? = nil,
        positionZRandomDifferenceRange: ClosedRange<Float>? = nil,
        positionStartXRandomRange: ClosedRange<Float>? = nil,
        positionStartYRandomRange: ClosedRange<Float>? = nil,
        positionStartZRandomRange: ClosedRange<Float>? = nil,
        positionEndXRandomRange: ClosedRange<Float>? = nil,
        positionEndYRandomRange: ClosedRange<Float>? = nil,
        positionEndZRandomRange: ClosedRange<Float>? = nil,
        smoothPositionAxes: EffectAxes = .none,
        zOffsetStart: Float = 0,
        zOffsetEnd: Float = 0,
        arc: Float = 0,
        retreat: Float = 0,
        movesFromSource: Bool = false,
        movesToSource: Bool = false,
        size: SIMD2<Float> = [100, 100],
        sizeStart: SIMD2<Float>? = nil,
        sizeEnd: SIMD2<Float>? = nil,
        sizeXRandomRange: ClosedRange<Float>? = nil,
        sizeYRandomRange: ClosedRange<Float>? = nil,
        smoothSize: Bool = false,
        angle: Float = 0,
        targetAngle: Float? = nil,
        rotates: Bool = false,
        rotationCount: Float = 1,
        rotationDelay: TimeInterval = 0,
        rotatesClockwise: Bool = false,
        rotatePosition: SIMD3<Float> = .zero,
        rotatesToTarget: Bool = false,
        rotatesWithCamera: Bool = false,
        soulStrikePattern: Int? = nil,
        drainPattern: Int? = nil
    ) -> EffectDefinition {
        let definition = Effect3DDefinition(
            fileName: fileName,
            fileNames: fileNames,
            frameDelay: frameDelay,
            spriteName: spriteName,
            playSprite: playSprite,
            spriteFrameDelay: spriteFrameDelay,
            soundName: soundName,
            delaySound: delaySound,
            randomNumberRange: randomNumberRange,
            duration: duration,
            repeats: repeats,
            delayStart: delayStart,
            delay: delay,
            delayOffset: delayOffset,
            delayLate: delayLate,
            duplicate: duplicate,
            attachedToTarget: attachedToTarget,
            rendersBeforeEntities: rendersBeforeEntities,
            overlay: overlay,
            zIndex: zIndex,
            blendMode: blendMode,
            color: color,
            castsShadow: castsShadow,
            alphaMin: alphaMin,
            alphaMax: alphaMax,
            fadesIn: fadesIn,
            fadesOut: fadesOut,
            sparkles: sparkles,
            sparkleCount: sparkleCount,
            sparkleCountRandomRange: sparkleCountRandomRange,
            offset: offset,
            positionStart: positionStart,
            positionEnd: positionEnd,
            positionXRandomRange: positionXRandomRange,
            positionYRandomRange: positionYRandomRange,
            positionZRandomRange: positionZRandomRange,
            positionXRandomDifferenceRange: positionXRandomDifferenceRange,
            positionYRandomDifferenceRange: positionYRandomDifferenceRange,
            positionZRandomDifferenceRange: positionZRandomDifferenceRange,
            positionStartXRandomRange: positionStartXRandomRange,
            positionStartYRandomRange: positionStartYRandomRange,
            positionStartZRandomRange: positionStartZRandomRange,
            positionEndXRandomRange: positionEndXRandomRange,
            positionEndYRandomRange: positionEndYRandomRange,
            positionEndZRandomRange: positionEndZRandomRange,
            smoothPositionAxes: smoothPositionAxes,
            zOffsetStart: zOffsetStart,
            zOffsetEnd: zOffsetEnd,
            arc: arc,
            retreat: retreat,
            movesFromSource: movesFromSource,
            movesToSource: movesToSource,
            size: size,
            sizeStart: sizeStart,
            sizeEnd: sizeEnd,
            sizeXRandomRange: sizeXRandomRange,
            sizeYRandomRange: sizeYRandomRange,
            smoothSize: smoothSize,
            angle: angle,
            targetAngle: targetAngle,
            rotates: rotates,
            rotationCount: rotationCount,
            rotationDelay: rotationDelay,
            rotatesClockwise: rotatesClockwise,
            rotatePosition: rotatePosition,
            rotatesToTarget: rotatesToTarget,
            rotatesWithCamera: rotatesWithCamera,
            soulStrikePattern: soulStrikePattern,
            drainPattern: drainPattern
        )
        return .`3D`(definition)
    }
}
