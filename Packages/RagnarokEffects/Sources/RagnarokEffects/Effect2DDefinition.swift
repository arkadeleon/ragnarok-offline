//
//  Effect2DDefinition.swift
//  RagnarokEffects
//
//  Created by Leon Li on 2026/7/9.
//

import Foundation
import simd

// Ported from roBrowserLegacy EffectTable.js (Swift property → JS key):
// - fileName:                       file
// - soundName:                      wav
// - randomNumberRange:              rand
// - duration:                       duration
// - durationRandomRange:            durationRand
// - repeats:                        repeat
// - delayStart:                     delayStart
// - delay:                          delayFrame
// - delayOffset:                    delayOffset
// - delayLate:                      delayLate
// - delaySound:                     delayWav
// - duplicate:                      duplicate, timeBetweenDupli, angleDelta
// - attachedToTarget:               attachedEntity
// - rendersBeforeEntities:          renderBeforeEntities
// - overlay:                        overlay
// - zIndex:                         zIndex
// - blendMode:                      blendMode
// - color:                          red, green, blue
// - castsShadow:                    shadowTexture
// - alphaMax:                       alphaMax
// - fadesIn:                        fadeIn
// - fadesOut:                       fadeOut
// - positionOffset:                 posx, posy, posz
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
// - circlePattern:                  circlePattern
// - circleInnerSize:                circleInnerSize
// - circleOuterSizeRandomRange:     circleOuterSizeRand
// - offsetStart:                    offsetxStart, offsetyStart
// - offsetEnd:                      offsetxEnd, offsetyEnd
// - sizeStart:                      size, sizeX, sizeY, sizeStart, sizeStartX, sizeStartY
// - sizeEnd:                        size, sizeX, sizeY, sizeEnd, sizeEndX, sizeEndY
// - sizeXRandomRange:               sizeRand, sizeRandX, sizeRandXMiddle
// - sizeYRandomRange:               sizeRand, sizeRandY, sizeRandYMiddle
// - sizeStartXRandomRange:          sizeRandStartX
// - sizeStartYRandomRange:          sizeRandStartY
// - sizeEndXRandomRange:            sizeRandEndX
// - sizeEndYRandomRange:            sizeRandEndY
// - smoothSize:                     sizeSmooth
// - angle:                          angle
// - targetAngle:                    toAngle
// - angleRandomRange:               angleRand
// - rotates:                        rotate
// - rotatesToTarget:                rotateToTarget
public struct Effect2DDefinition: Sendable {
    public var fileName: String
    public var soundName: String?
    public var randomNumberRange: ClosedRange<Int>?

    public var duration: TimeInterval
    public var durationRandomRange: ClosedRange<TimeInterval>?
    public var repeats: Bool
    public var delayStart: TimeInterval
    public var delay: TimeInterval
    public var delayOffset: TimeInterval
    public var delayLate: TimeInterval
    public var delaySound: TimeInterval
    public var duplicate: EffectParameters.Duplicate

    public var attachedToTarget: Bool
    public var rendersBeforeEntities: Bool
    public var overlay: Bool
    public var zIndex: Float
    public var blendMode: EffectParameters.BlendMode
    public var color: SIMD3<Float>
    public var castsShadow: Bool

    public var alphaMax: Float
    public var fadesIn: Bool
    public var fadesOut: Bool

    public var positionOffset: SIMD3<Float>
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
    public var circlePattern: Bool
    public var circleInnerSize: Float
    public var circleOuterSizeRandomRange: ClosedRange<Float>?

    public var offsetStart: SIMD2<Float>
    public var offsetEnd: SIMD2<Float>

    public var sizeStart: SIMD2<Float>
    public var sizeEnd: SIMD2<Float>
    public var sizeXRandomRange: ClosedRange<Float>?
    public var sizeYRandomRange: ClosedRange<Float>?
    public var sizeStartXRandomRange: ClosedRange<Float>?
    public var sizeStartYRandomRange: ClosedRange<Float>?
    public var sizeEndXRandomRange: ClosedRange<Float>?
    public var sizeEndYRandomRange: ClosedRange<Float>?
    public var smoothSize: Bool

    public var angle: Float
    public var targetAngle: Float
    public var angleRandomRange: ClosedRange<Float>?
    public var rotates: Bool
    public var rotatesToTarget: Bool

    public func delay(duplicateID: Int) -> TimeInterval {
        delayStart
            + delay
            + delayOffset
            + duplicate.delayOffsetDelta * TimeInterval(duplicateID)
            + delayLate
            + duplicate.delayLateDelta * TimeInterval(duplicateID)
            + duplicate.interval * TimeInterval(duplicateID)
    }

    func resolved() -> Effect2DDefinition {
        guard let randomNumberRange else {
            return self
        }

        var definition = self
        let randomNumber = Int.random(in: randomNumberRange)
        definition.fileName = fileName.replacingOccurrences(of: "%d", with: "\(randomNumber)")
        definition.soundName = soundName?.replacingOccurrences(of: "%d", with: "\(randomNumber)")
        definition.randomNumberRange = nil
        return definition
    }
}

extension EffectDefinition {
    public static func `2D`(
        fileName: String,
        soundName: String? = nil,
        randomNumberRange: ClosedRange<Int>? = nil,
        duration: TimeInterval,
        durationRandomRange: ClosedRange<TimeInterval>? = nil,
        repeats: Bool = false,
        delayStart: TimeInterval = 0,
        delay: TimeInterval = 0,
        delayOffset: TimeInterval = 0,
        delayLate: TimeInterval = 0,
        delaySound: TimeInterval = 0,
        duplicate: EffectParameters.Duplicate = EffectParameters.Duplicate(),
        attachedToTarget: Bool,
        rendersBeforeEntities: Bool = false,
        overlay: Bool = false,
        zIndex: Float = 0,
        blendMode: EffectParameters.BlendMode = .oneMinusSourceAlpha,
        color: SIMD3<Float> = [1, 1, 1],
        castsShadow: Bool = false,
        alphaMax: Float = 1,
        fadesIn: Bool = false,
        fadesOut: Bool = false,
        positionOffset: SIMD3<Float> = .zero,
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
        circlePattern: Bool = false,
        circleInnerSize: Float = 0,
        circleOuterSizeRandomRange: ClosedRange<Float>? = nil,
        offsetStart: SIMD2<Float> = .zero,
        offsetEnd: SIMD2<Float> = .zero,
        sizeStart: SIMD2<Float> = [100, 100],
        sizeEnd: SIMD2<Float> = [100, 100],
        sizeXRandomRange: ClosedRange<Float>? = nil,
        sizeYRandomRange: ClosedRange<Float>? = nil,
        sizeStartXRandomRange: ClosedRange<Float>? = nil,
        sizeStartYRandomRange: ClosedRange<Float>? = nil,
        sizeEndXRandomRange: ClosedRange<Float>? = nil,
        sizeEndYRandomRange: ClosedRange<Float>? = nil,
        smoothSize: Bool = false,
        angle: Float = 0,
        targetAngle: Float = 0,
        angleRandomRange: ClosedRange<Float>? = nil,
        rotates: Bool = false,
        rotatesToTarget: Bool = false
    ) -> EffectDefinition {
        let definition = Effect2DDefinition(
            fileName: fileName,
            soundName: soundName,
            randomNumberRange: randomNumberRange,
            duration: duration,
            durationRandomRange: durationRandomRange,
            repeats: repeats,
            delayStart: delayStart,
            delay: delay,
            delayOffset: delayOffset,
            delayLate: delayLate,
            delaySound: delaySound,
            duplicate: duplicate,
            attachedToTarget: attachedToTarget,
            rendersBeforeEntities: rendersBeforeEntities,
            overlay: overlay,
            zIndex: zIndex,
            blendMode: blendMode,
            color: color,
            castsShadow: castsShadow,
            alphaMax: alphaMax,
            fadesIn: fadesIn,
            fadesOut: fadesOut,
            positionOffset: positionOffset,
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
            circlePattern: circlePattern,
            circleInnerSize: circleInnerSize,
            circleOuterSizeRandomRange: circleOuterSizeRandomRange,
            offsetStart: offsetStart,
            offsetEnd: offsetEnd,
            sizeStart: sizeStart,
            sizeEnd: sizeEnd,
            sizeXRandomRange: sizeXRandomRange,
            sizeYRandomRange: sizeYRandomRange,
            sizeStartXRandomRange: sizeStartXRandomRange,
            sizeStartYRandomRange: sizeStartYRandomRange,
            sizeEndXRandomRange: sizeEndXRandomRange,
            sizeEndYRandomRange: sizeEndYRandomRange,
            smoothSize: smoothSize,
            angle: angle,
            targetAngle: targetAngle,
            angleRandomRange: angleRandomRange,
            rotates: rotates,
            rotatesToTarget: rotatesToTarget
        )
        return .`2D`(definition)
    }
}
