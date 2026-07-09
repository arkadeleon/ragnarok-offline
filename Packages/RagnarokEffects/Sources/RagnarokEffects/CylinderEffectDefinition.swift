//
//  CylinderEffectDefinition.swift
//  RagnarokEffects
//
//  Created by Leon Li on 2026/6/25.
//

import Foundation
import simd

// Ported from roBrowserLegacy EffectTable.js (Swift property → JS key):
// - textureName:            textureName
// - soundName:              wav
// - duration:               duration
// - repeats:                repeat
// - delayStart:             delayStart
// - delayOffset:            delayOffset
// - delayLate:              delayLate
// - duplicate:              duplicate, timeBetweenDupli
// - attachedToTarget:       attachedEntity
// - rendersBeforeEntities:  renderBeforeEntities
// - zIndex:                 zIndex
// - blendMode:              blendMode
// - color:                  red, green, blue
// - alpha:                  alphaMax
// - fades:                  fade
// - topRadius:              topSize
// - bottomRadius:           bottomSize
// - height:                 height
// - totalCircleSides:       totalCircleSides
// - visibleCircleSides:     circleSides
// - usesSemicircle:         semiCircle (inverted)
// - textureRepeatX:         repeatTextureX
// - animation:              animation, animationSpeed, animationOut
// - positionOffset:         posX, posY, posZ
// - rotationDegrees:        angleX, angleY, angleZ
// - rotationXRandomRange:   angleXRandom
// - rotationYRandomRange:   angleYRandom
// - rotationZRandomRange:   angleZRandom
// - rotatesContinuously:    rotate
// - rotatesWithCamera:      rotateWithCamera
// - rotatesToTarget:        rotateToTarget
// - rotatesWithSource:      rotateWithSource
// - fixedPerspective:       fixedPerspective
public struct CylinderEffectDefinition: Sendable {
    public var textureName: String
    public var soundName: String?

    public var duration: TimeInterval
    public var repeats: Bool
    public var delayStart: TimeInterval
    public var delayOffset: TimeInterval
    public var delayLate: TimeInterval
    public var duplicate: EffectParameters.Duplicate

    public var attachedToTarget: Bool
    public var rendersBeforeEntities: Bool
    public var zIndex: Float
    public var blendMode: EffectParameters.BlendMode
    public var color: SIMD3<Float>

    public var alpha: Float
    public var fades: Bool

    public var topRadius: Float
    public var bottomRadius: Float
    public var height: Float
    public var totalCircleSides: Int
    public var visibleCircleSides: Int
    public var usesSemicircle: Bool
    public var textureRepeatX: Float
    public var animation: EffectParameters.Animation?

    public var positionOffset: SIMD3<Float>
    public var rotationDegrees: SIMD3<Float>
    public var rotationXRandomRange: ClosedRange<Float>?
    public var rotationYRandomRange: ClosedRange<Float>?
    public var rotationZRandomRange: ClosedRange<Float>?
    public var rotatesContinuously: Bool
    public var rotatesWithCamera: Bool
    public var rotatesToTarget: Bool
    public var rotatesWithSource: Bool
    public var fixedPerspective: Bool

    public func delay(duplicateID: Int) -> TimeInterval {
        delayStart
            + delayOffset
            + duplicate.delayOffsetDelta * TimeInterval(duplicateID)
            + delayLate
            + duplicate.delayLateDelta * TimeInterval(duplicateID)
            + duplicate.interval * TimeInterval(duplicateID)
    }

    func resolved() -> CylinderEffectDefinition {
        var definition = self

        if let rotationXRandomRange {
            definition.rotationDegrees.x += Float.random(in: rotationXRandomRange)
            definition.rotationXRandomRange = nil
        }
        if let rotationYRandomRange {
            definition.rotationDegrees.y += Float.random(in: rotationYRandomRange)
            definition.rotationYRandomRange = nil
        }
        if let rotationZRandomRange {
            definition.rotationDegrees.z += Float.random(in: rotationZRandomRange)
            definition.rotationZRandomRange = nil
        }

        return definition
    }
}

extension EffectDefinition {
    public static func cylinder(
        textureName: String,
        soundName: String? = nil,
        duration: TimeInterval,
        repeats: Bool = false,
        delayStart: TimeInterval = 0,
        delayOffset: TimeInterval = 0,
        delayLate: TimeInterval = 0,
        duplicate: EffectParameters.Duplicate = EffectParameters.Duplicate(),
        attachedToTarget: Bool,
        rendersBeforeEntities: Bool = false,
        zIndex: Float = 0,
        blendMode: EffectParameters.BlendMode = .oneMinusSourceAlpha,
        color: SIMD3<Float> = [1, 1, 1],
        alpha: Float = 1,
        fades: Bool = false,
        topRadius: Float,
        bottomRadius: Float,
        height: Float,
        totalCircleSides: Int = 20,
        visibleCircleSides: Int? = nil,
        usesSemicircle: Bool = true,
        textureRepeatX: Float = 1,
        animation: EffectParameters.Animation? = nil,
        positionOffset: SIMD3<Float> = .zero,
        rotationDegrees: SIMD3<Float> = .zero,
        rotationXRandomRange: ClosedRange<Float>? = nil,
        rotationYRandomRange: ClosedRange<Float>? = nil,
        rotationZRandomRange: ClosedRange<Float>? = nil,
        rotatesContinuously: Bool = false,
        rotatesWithCamera: Bool = false,
        rotatesToTarget: Bool = false,
        rotatesWithSource: Bool = false,
        fixedPerspective: Bool = false
    ) -> EffectDefinition {
        let definition = CylinderEffectDefinition(
            textureName: textureName,
            soundName: soundName,
            duration: duration,
            repeats: repeats,
            delayStart: delayStart,
            delayOffset: delayOffset,
            delayLate: delayLate,
            duplicate: duplicate,
            attachedToTarget: attachedToTarget,
            rendersBeforeEntities: rendersBeforeEntities,
            zIndex: zIndex,
            blendMode: blendMode,
            color: color,
            alpha: alpha,
            fades: fades,
            topRadius: topRadius,
            bottomRadius: bottomRadius,
            height: height,
            totalCircleSides: totalCircleSides,
            visibleCircleSides: visibleCircleSides ?? totalCircleSides,
            usesSemicircle: usesSemicircle,
            textureRepeatX: textureRepeatX,
            animation: animation,
            positionOffset: positionOffset,
            rotationDegrees: rotationDegrees,
            rotationXRandomRange: rotationXRandomRange,
            rotationYRandomRange: rotationYRandomRange,
            rotationZRandomRange: rotationZRandomRange,
            rotatesContinuously: rotatesContinuously,
            rotatesWithCamera: rotatesWithCamera,
            rotatesToTarget: rotatesToTarget,
            rotatesWithSource: rotatesWithSource,
            fixedPerspective: fixedPerspective
        )
        return .cylinder(definition)
    }
}
