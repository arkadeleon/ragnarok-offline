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
// - attachedToTarget:       attachedEntity
// - repeats:                repeat
// - duration:               duration
// - delayOffset:            delayOffset
// - delayLate:              delayLate
// - duplicate:              duplicate, timeBetweenDupli
// - totalCircleSides:       totalCircleSides
// - visibleCircleSides:     circleSides
// - textureRepeatX:         repeatTextureX
// - topRadius:              topSize
// - bottomRadius:           bottomSize
// - height:                 height
// - color:                  red, green, blue
// - alpha:                  alphaMax
// - fades:                  fade
// - animation:              animation, animationSpeed, animationOut
// - blendMode:              blendMode
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
    public var attachedToTarget: Bool
    public var rendersBeforeEntities: Bool
    public var repeats: Bool

    public var duration: TimeInterval?
    public var delayStart: TimeInterval
    public var delayOffset: TimeInterval
    public var delayLate: TimeInterval
    public var duplicate: EffectParameters.Duplicate

    public var totalCircleSides: Int
    public var visibleCircleSides: Int
    public var textureRepeatX: Float
    public var topRadius: Float
    public var bottomRadius: Float
    public var height: Float
    public var usesSemicircle: Bool

    public var color: SIMD3<Float>
    public var alpha: Float
    public var fades: Bool
    public var animation: EffectParameters.Animation?
    public var blendMode: EffectParameters.BlendMode
    public var zIndex: Float

    public var positionOffset: SIMD3<Float>
    public var rotationDegrees: SIMD3<Float>
    public var randomRotationDegrees: SIMD3<Float>
    public var rotatesContinuously: Bool

    public var rotatesWithCamera: Bool
    public var rotatesToTarget: Bool
    public var rotatesWithSource: Bool
    public var fixedPerspective: Bool

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
        attachedToTarget: Bool,
        rendersBeforeEntities: Bool = false,
        repeats: Bool = false,
        duration: TimeInterval? = nil,
        delayStart: TimeInterval = 0,
        delayOffset: TimeInterval = 0,
        delayLate: TimeInterval = 0,
        duplicate: EffectParameters.Duplicate = EffectParameters.Duplicate(),
        totalCircleSides: Int = 20,
        visibleCircleSides: Int? = nil,
        textureRepeatX: Float = 1,
        topRadius: Float,
        bottomRadius: Float,
        height: Float,
        usesSemicircle: Bool = true,
        color: SIMD3<Float> = [1, 1, 1],
        alpha: Float = 1,
        fades: Bool = false,
        animation: EffectParameters.Animation? = nil,
        blendMode: EffectParameters.BlendMode = .oneMinusSourceAlpha,
        zIndex: Float = 0,
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
            attachedToTarget: attachedToTarget,
            rendersBeforeEntities: rendersBeforeEntities,
            repeats: repeats,
            duration: duration,
            delayStart: delayStart,
            delayOffset: delayOffset,
            delayLate: delayLate,
            duplicate: duplicate,
            totalCircleSides: totalCircleSides,
            visibleCircleSides: visibleCircleSides ?? totalCircleSides,
            textureRepeatX: textureRepeatX,
            topRadius: topRadius,
            bottomRadius: bottomRadius,
            height: height,
            usesSemicircle: usesSemicircle,
            color: color,
            alpha: alpha,
            fades: fades,
            animation: animation,
            blendMode: blendMode,
            zIndex: zIndex,
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
