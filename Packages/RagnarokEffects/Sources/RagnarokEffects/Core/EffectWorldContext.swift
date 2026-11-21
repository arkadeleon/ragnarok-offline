//
//  EffectWorldContext.swift
//  RagnarokEffects
//
//  Created by Leon Li on 2026/11/20.
//

import Foundation
import simd

/// Identifier for a world object that an effect attaches to or targets, matching `GameObjectID` (`UInt32`).
public typealias EffectTargetID = UInt32

/// Attachment key used to group and selectively retire effects owned by a target or skill unit.
public enum EffectAttachmentKey: Hashable, Sendable {
    case untagged
    case cast
    case status(Int)
    case skillUnit(EffectTargetID)
}

/// Request payload used to spawn an effect through `EffectManager`.
public struct EffectSpawnRequest: Sendable {
    /// Raw numeric effect identifier:
    /// - `-1...2483`: `EffectID`
    /// - `2485...`: Hat effects (`hatEffect + 2485`)
    /// - `10000...`: Data-driven `EZ2STREffect.bson` entries
    public var rawEffectID: Int

    public var worldPosition: SIMD3<Float>
    public var sourceWorldPosition: SIMD3<Float>?
    public var ownerObjectID: EffectTargetID?
    public var targetObjectID: EffectTargetID?
    public var sourceObjectID: EffectTargetID?
    public var attachmentKey: EffectAttachmentKey
    public var direction: SIMD3<Float>?
    public var level: Int
    public var delay: TimeInterval
    public var duration: TimeInterval?
    public var parameters: [Float]

    public var effectID: EffectID? {
        EffectID(rawValue: rawEffectID)
    }

    public var effectPosition: SIMD3<Float> {
        EffectSpace.toEffectPosition(worldPosition)
    }

    public var sourceEffectPosition: SIMD3<Float>? {
        sourceWorldPosition.map(EffectSpace.toEffectPosition)
    }

    public init(
        rawEffectID: Int,
        worldPosition: SIMD3<Float>,
        sourceWorldPosition: SIMD3<Float>? = nil,
        ownerObjectID: EffectTargetID? = nil,
        targetObjectID: EffectTargetID? = nil,
        sourceObjectID: EffectTargetID? = nil,
        attachmentKey: EffectAttachmentKey = .untagged,
        direction: SIMD3<Float>? = nil,
        level: Int = 0,
        delay: TimeInterval = 0,
        duration: TimeInterval? = nil,
        parameters: [Float] = []
    ) {
        self.rawEffectID = rawEffectID
        self.worldPosition = worldPosition
        self.sourceWorldPosition = sourceWorldPosition
        self.ownerObjectID = ownerObjectID
        self.targetObjectID = targetObjectID
        self.sourceObjectID = sourceObjectID
        self.attachmentKey = attachmentKey
        self.direction = direction
        self.level = level
        self.delay = delay
        self.duration = duration
        self.parameters = parameters
    }

    public init(
        effectID: EffectID,
        worldPosition: SIMD3<Float>,
        sourceWorldPosition: SIMD3<Float>? = nil,
        ownerObjectID: EffectTargetID? = nil,
        targetObjectID: EffectTargetID? = nil,
        sourceObjectID: EffectTargetID? = nil,
        attachmentKey: EffectAttachmentKey = .untagged,
        direction: SIMD3<Float>? = nil,
        level: Int = 0,
        delay: TimeInterval = 0,
        duration: TimeInterval? = nil,
        parameters: [Float] = []
    ) {
        self.init(
            rawEffectID: effectID.rawValue,
            worldPosition: worldPosition,
            sourceWorldPosition: sourceWorldPosition,
            ownerObjectID: ownerObjectID,
            targetObjectID: targetObjectID,
            sourceObjectID: sourceObjectID,
            attachmentKey: attachmentKey,
            direction: direction,
            level: level,
            delay: delay,
            duration: duration,
            parameters: parameters
        )
    }
}

/// Read-only spatial state of a world object exposed to running effects.
public struct EffectTargetState: Sendable, Equatable {
    public var objectID: EffectTargetID
    public var worldPosition: SIMD3<Float>
    public var headHeight: Float
    public var facingAngle: Float
    public var directionIndex: Int
    public var isValid: Bool

    public var effectPosition: SIMD3<Float> {
        EffectSpace.toEffectPosition(worldPosition)
    }

    /// Head offset in native effect space (negative Y is upward).
    public var effectHeadOffsetY: Float {
        EffectSpace.toEffectHeight(headHeight)
    }

    public init(
        objectID: EffectTargetID,
        worldPosition: SIMD3<Float>,
        headHeight: Float = 2.0,
        facingAngle: Float = 0,
        directionIndex: Int = 0,
        isValid: Bool = true
    ) {
        self.objectID = objectID
        self.worldPosition = worldPosition
        self.headHeight = headHeight
        self.facingAngle = facingAngle
        self.directionIndex = directionIndex
        self.isValid = isValid
    }
}

/// Afterimage styles triggered by `CRagEffect` on target objects.
public enum EffectAfterimageStyle: Sendable, Equatable {
    case blur
    case hallucination
    case paleBlur
    case lightBlur
}

/// Visual modification requested by an active effect on a target object.
public enum EffectTargetModifier: Sendable, Equatable {
    case tint(color: SIMD4<Float>, durationTicks: Int)
    case alpha(Float, durationTicks: Int)
    case scale(SIMD3<Float>, durationTicks: Int)
    case rotation(SIMD3<Float>, durationTicks: Int)
    case flash(color: SIMD4<Float>, durationTicks: Int)
    case afterimage(style: EffectAfterimageStyle, durationTicks: Int)
    case cloaking(alpha: Float)
    case shake(amplitude: Float, durationTicks: Int)
}

/// Single boundary protocol bridging `EffectManager` with its host world
/// (`MapWorldContext` in-game or `PreviewEffectWorldContext` in `EffectViewer`).
@MainActor
public protocol EffectWorldContext: AnyObject {
    /// Returns terrain elevation in native effect space (`-worldY * 5.0`) at the given effect-space XZ coordinates.
    func terrainHeight(atEffectX x: Float, effectZ z: Float) -> Float

    /// Returns the spatial state of the object with the given identifier, or `nil` if absent.
    func targetState(for targetID: EffectTargetID) -> EffectTargetState?

    /// Current camera position in world coordinates.
    var cameraWorldPosition: SIMD3<Float> { get }

    /// Checks whether an effect-space position is within the specified effect-space distance of the camera.
    func isWithinRange(ofEffectPosition position: SIMD3<Float>, maxDistance: Float) -> Bool

    func playSound(named name: String, atWorldPosition position: SIMD3<Float>?, delay: TimeInterval)
    func shakeCamera(amplitude: Float, duration: TimeInterval, frequency: Float)
    func applyTargetModifier(_ modifier: EffectTargetModifier, to targetID: EffectTargetID)
    func spawnChildEffect(_ request: EffectSpawnRequest)
}

extension EffectWorldContext {
    public var cameraEffectPosition: SIMD3<Float> {
        EffectSpace.toEffectPosition(cameraWorldPosition)
    }

    public func isWithinRange(ofEffectPosition position: SIMD3<Float>, maxDistance: Float) -> Bool {
        let delta = position - cameraEffectPosition
        return simd_length_squared(delta) <= maxDistance * maxDistance
    }
}
