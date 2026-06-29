//
//  EffectDefinition.swift
//  RagnarokEffects
//
//  Created by Leon Li on 2026/4/30.
//

import Foundation
import simd

public enum EffectDefinition: Sendable {
    case cylinder(CylinderEffectDefinition)
    case str(STREffectDefinition)

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
        delayOffsetDelta: TimeInterval = 0,
        delayLateDelta: TimeInterval = 0,
        duplicateCount: Int = 1,
        duplicateInterval: TimeInterval = 0.2,
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
        animation: CylinderEffectAnimation? = nil,
        blendMode: CylinderEffectBlendMode = .oneMinusSourceAlpha,
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
            delayOffsetDelta: delayOffsetDelta,
            delayLateDelta: delayLateDelta,
            duplicateCount: duplicateCount,
            duplicateInterval: duplicateInterval,
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

    public static func str(
        fileName: String,
        soundName: String? = nil,
        attachedToTarget: Bool,
        randomNumberRange: ClosedRange<Int>? = nil
    ) -> EffectDefinition {
        let definition = STREffectDefinition(
            fileName: fileName,
            soundName: soundName,
            attachedToTarget: attachedToTarget,
            randomNumberRange: randomNumberRange
        )
        return .str(definition)
    }
}

extension EffectDefinition {
    public var soundName: String? {
        switch self {
        case .cylinder(let definition):
            definition.soundName
        case .str(let definition):
            definition.soundName
        }
    }

    public var assetKey: String {
        switch self {
        case .cylinder(let definition):
            "cylinder:\(definition.textureName)"
        case .str(let definition):
            "str:\(definition.fileName)"
        }
    }

    public func resolved() -> EffectDefinition {
        switch self {
        case .cylinder(let definition):
            .cylinder(definition.resolved())
        case .str(let definition):
            .str(definition.resolved())
        }
    }
}
