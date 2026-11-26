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
    /// Multiplies the target's sprite color by normalized RGBA channels (`0...1`).
    case tint(color: SIMD4<Float>, durationTicks: Int)
    /// Multiplies the target's sprite opacity (`0...1`).
    case alpha(Float, durationTicks: Int)
    /// Scales the target's sprite (`x` horizontal, `y` vertical; `z` reserved for 3D space).
    case scale(SIMD3<Float>, durationTicks: Int)
    /// Offsets the target's 8-way facing direction in degrees (quantized to 45° steps).
    case facingYaw(degrees: Float, durationTicks: Int)
    /// Rotates the target's 2D sprite plane in degrees.
    case spriteRoll(degrees: Float, durationTicks: Int)
    /// Translates the target's 2D sprite in sprite-pixel units (positive Y is upward).
    case spriteOffset(SIMD2<Float>, durationTicks: Int)
    /// Renders expanded tinted silhouette copies around the target sprite (e.g., aura or outline glow).
    case outline(color: SIMD4<Float>, spread: Float, layers: Int, durationTicks: Int)
    /// Renders four translucent copies of the target sprite offset along ±X and ±Y.
    case fourWaySplit(spread: Float, alpha: Float, durationTicks: Int)
    /// Blends a decaying normalized RGBA flash color over the target's sprite.
    case flash(color: SIMD4<Float>, durationTicks: Int)
    /// Spawns a fading afterimage snapshot of the target sprite with an optional normalized RGBA tint.
    case afterimage(style: EffectAfterimageStyle, tint: SIMD4<Float>? = nil, durationTicks: Int)
    /// Keeps a cloaked target partially visible at the given opacity (`0...1`).
    case cloaking(alpha: Float)
    /// Applies decaying horizontal jitter around the target's world position.
    case shake(amplitude: Float, durationTicks: Int)
}

/// Single boundary protocol bridging `EffectManager` with its host world
/// (`MapScene` in-game or `EffectViewerEffectWorldContext` in `EffectViewer`).
@MainActor
public protocol EffectWorldContext: AnyObject {
    /// Returns terrain elevation in native effect space (`-worldY * 5.0`) at the given effect-space XZ coordinates.
    func terrainHeight(atEffectX x: Float, effectZ z: Float) -> Float

    /// Returns the spatial state of the object with the given identifier, or `nil` if absent.
    func targetState(for targetID: EffectTargetID) -> EffectTargetState?

    /// Current camera position in world coordinates.
    var cameraWorldPosition: SIMD3<Float> { get }

    /// Current camera yaw in degrees.
    var cameraYawDegrees: Float { get }

    /// Current camera pitch (elevation) in degrees.
    var cameraPitchDegrees: Float { get }

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

    public func worldTerrainHeight(atWorldX x: Float, worldZ z: Float) -> Float {
        let effectPosition = EffectSpace.toEffectPosition(SIMD3<Float>(x, 0, z))
        let effectHeight = terrainHeight(atEffectX: effectPosition.x, effectZ: effectPosition.z)
        return EffectSpace.toWorldHeight(effectHeight)
    }

    public func isWithinRange(ofEffectPosition position: SIMD3<Float>, maxDistance: Float) -> Bool {
        let delta = position - cameraEffectPosition
        return simd_length_squared(delta) <= maxDistance * maxDistance
    }
}
