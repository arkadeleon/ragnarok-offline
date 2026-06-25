//
//  CylinderEffectDefinition.swift
//  RagnarokGame
//
//  Created by Leon Li on 2026/6/25.
//

import Foundation
import simd

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
    public var delayOffsetDelta: TimeInterval
    public var delayLateDelta: TimeInterval
    public var duplicateCount: Int
    public var duplicateInterval: TimeInterval

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
    public var animation: CylinderEffectAnimation?
    public var blendMode: CylinderEffectBlendMode
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

public enum CylinderEffectAnimation: Int, Sendable {
    case growHeight = 1
    case growTopRadius = 2
    case shrinkRadius = 3
    case growRadius = 4
    case growThenShrinkHeight = 5
}

public enum CylinderEffectBlendMode: Int, Sendable {
    case zero = 1
    case one = 2
    case sourceColor = 3
    case oneMinusSourceColor = 4
    case destinationColor = 5
    case oneMinusDestinationColor = 6
    case sourceAlpha = 7
    case oneMinusSourceAlpha = 8
    case destinationAlpha = 9
    case oneMinusDestinationAlpha = 10
    case constantColor = 11
    case oneMinusConstantColor = 12
    case constantAlpha = 13
    case oneMinusConstantAlpha = 14
    case sourceAlphaSaturated = 15
}
