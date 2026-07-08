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
// - randomRotationDegrees:  angleZRandom
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
    public var randomRotationDegrees: SIMD3<Float>
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
        guard randomRotationDegrees != .zero else {
            return self
        }

        var definition = self
        definition.rotationDegrees += [
            randomRotationDegrees.x > 0 ? Float.random(in: 0..<randomRotationDegrees.x) : 0,
            randomRotationDegrees.y > 0 ? Float.random(in: 0..<randomRotationDegrees.y) : 0,
            randomRotationDegrees.z > 0 ? Float.random(in: 0..<randomRotationDegrees.z) : 0,
        ]
        definition.randomRotationDegrees = .zero
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
        randomRotationDegrees: SIMD3<Float> = .zero,
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
            randomRotationDegrees: randomRotationDegrees,
            rotatesContinuously: rotatesContinuously,
            rotatesWithCamera: rotatesWithCamera,
            rotatesToTarget: rotatesToTarget,
            rotatesWithSource: rotatesWithSource,
            fixedPerspective: fixedPerspective
        )
        return .cylinder(definition)
    }
}
