//
//  EffectSpace.swift
//  RagnarokEffects
//
//  Created by Leon Li on 2026/11/20.
//

import Foundation
import simd

/// Bridges between the unified Y-up world coordinate space (`1 GAT cell = 1.0`)
/// and the native Ragnarok client effect space (`1 GAT cell = 5.0`, Y-down, Z-inverted).
public enum EffectSpace: Sendable {
    public static let worldToEffectScale: Float = 5.0
    public static let effectToWorldScale: Float = 0.2

    /// Exact pi approximation used by the official client (`ClientAngles.cpp`).
    public static let clientPi: Float = 3.141592

    // MARK: - Coordinate Conversions

    @inlinable
    public static func toEffectPosition(_ world: SIMD3<Float>) -> SIMD3<Float> {
        SIMD3<Float>(
            world.x * worldToEffectScale,
            -world.y * worldToEffectScale,
            -world.z * worldToEffectScale
        )
    }

    @inlinable
    public static func toWorldPosition(_ effect: SIMD3<Float>) -> SIMD3<Float> {
        SIMD3<Float>(
            effect.x * effectToWorldScale,
            -effect.y * effectToWorldScale,
            -effect.z * effectToWorldScale
        )
    }

    @inlinable
    public static func toEffectVector(_ world: SIMD3<Float>) -> SIMD3<Float> {
        toEffectPosition(world)
    }

    @inlinable
    public static func toWorldVector(_ effect: SIMD3<Float>) -> SIMD3<Float> {
        toWorldPosition(effect)
    }

    @inlinable
    public static func toEffectHeight(_ worldY: Float) -> Float {
        -worldY * worldToEffectScale
    }

    @inlinable
    public static func toWorldHeight(_ effectY: Float) -> Float {
        -effectY * effectToWorldScale
    }

    @inlinable
    public static func toEffectDistance(_ worldDistance: Float) -> Float {
        worldDistance * worldToEffectScale
    }

    @inlinable
    public static func toWorldDistance(_ effectDistance: Float) -> Float {
        effectDistance * effectToWorldScale
    }

    // MARK: - 720-Step Half-Degree Trigonometric Tables (0...719, 0.5° per step)

    public static let halfDegreeSinTable: [Float] = {
        (0..<720).map { index in
            let radians = (Float(index) * 0.5) / 180.0 * clientPi
            return sinf(radians)
        }
    }()

    public static let halfDegreeCosTable: [Float] = {
        (0..<720).map { index in
            let radians = (Float(index) * 0.5) / 180.0 * clientPi
            return cosf(radians)
        }
    }()

    @inlinable
    public static func halfDegreeSine(_ halfDegrees: Int) -> Float {
        let wrapped = ((halfDegrees % 720) + 720) % 720
        return halfDegreeSinTable[wrapped]
    }

    @inlinable
    public static func halfDegreeCosine(_ halfDegrees: Int) -> Float {
        let wrapped = ((halfDegrees % 720) + 720) % 720
        return halfDegreeCosTable[wrapped]
    }

    // MARK: - ClientAngles.cpp 722-Entry Integer-Degree Trigonometric Tables

    /// Mirrors `g_radTable[722]` from `ClientAngles.cpp`:
    /// indices `0...360` hold positive angles in radians; `361...721` hold their negations.
    public static let radTable: [Float] = {
        var table = [Float](repeating: 0, count: 722)
        for index in 0...360 {
            let angle = Float(index) / 180.0 * clientPi
            table[index] = angle
            table[index + 361] = -angle
        }
        return table
    }()

    /// Mirrors `g_sinTable[722]` from `ClientAngles.cpp`.
    public static let sinTable: [Float] = {
        var table = [Float](repeating: 0, count: 722)
        for index in 0...360 {
            let value = sinf(radTable[index])
            table[index] = value
            table[index + 361] = -value
        }
        return table
    }()

    /// Mirrors `g_cosTable[722]` from `ClientAngles.cpp`.
    public static let cosTable: [Float] = {
        var table = [Float](repeating: 0, count: 722)
        for index in 0...360 {
            let value = cosf(radTable[index])
            table[index] = value
            table[index + 361] = -value
        }
        return table
    }()

    @inline(__always)
    private static func wrapClientDegrees(_ degrees: Int) -> Int {
        if degrees > 360 || degrees < -360 {
            return degrees % 360
        }
        return degrees
    }

    /// Mirrors `GetRadian(int degrees)` from `ClientAngles.cpp`, preserving negative index lookup.
    public static func radian(degrees: Int) -> Float {
        let wrapped = wrapClientDegrees(degrees)
        if wrapped < 0 {
            return radTable[361 + wrapped]
        }
        return radTable[wrapped]
    }

    /// Mirrors `ClientSine(int degrees)` from `ClientAngles.cpp`, preserving negative index lookup.
    public static func sine(degrees: Int) -> Float {
        let wrapped = wrapClientDegrees(degrees)
        if wrapped < 0 {
            return sinTable[361 + wrapped]
        }
        return sinTable[wrapped]
    }

    /// Mirrors `ClientCosine(int degrees)` from `ClientAngles.cpp`, preserving negative index lookup.
    public static func cosine(degrees: Int) -> Float {
        let wrapped = wrapClientDegrees(degrees)
        if wrapped < 0 {
            return cosTable[361 + wrapped]
        }
        return cosTable[wrapped]
    }

    // MARK: - Client Euler Rotation Matrices (X -> Y -> Z order)

    /// Column-vector matrix equivalent of `matrix::MakeXRotation(radians)` in `AffineMatrix.cpp`.
    public static func rotationX(radians: Float) -> simd_float4x4 {
        let c = cosf(radians)
        let s = sinf(radians)
        return simd_float4x4(columns: (
            SIMD4<Float>(1, 0, 0, 0),
            SIMD4<Float>(0, c, s, 0),
            SIMD4<Float>(0, -s, c, 0),
            SIMD4<Float>(0, 0, 0, 1)
        ))
    }

    /// Column-vector matrix equivalent of `matrix::MakeYRotation(radians)` in `AffineMatrix.cpp`.
    public static func rotationY(radians: Float) -> simd_float4x4 {
        let c = cosf(radians)
        let s = sinf(radians)
        return simd_float4x4(columns: (
            SIMD4<Float>(c, 0, -s, 0),
            SIMD4<Float>(0, 1, 0, 0),
            SIMD4<Float>(s, 0, c, 0),
            SIMD4<Float>(0, 0, 0, 1)
        ))
    }

    /// Column-vector matrix equivalent of `matrix::MakeZRotation(radians)` in `AffineMatrix.cpp`.
    public static func rotationZ(radians: Float) -> simd_float4x4 {
        let c = cosf(radians)
        let s = sinf(radians)
        return simd_float4x4(columns: (
            SIMD4<Float>(c, s, 0, 0),
            SIMD4<Float>(-s, c, 0, 0),
            SIMD4<Float>(0, 0, 1, 0),
            SIMD4<Float>(0, 0, 0, 1)
        ))
    }

    /// Applies rotations in the client's X -> Y -> Z order (`v' = Rz * Ry * Rx * v`,
    /// matching row-vector `v' = v * Rx_row * Ry_row * Rz_row`).
    public static func eulerRotationMatrix(x: Float, y: Float, z: Float) -> simd_float4x4 {
        rotationZ(radians: z) * rotationY(radians: y) * rotationX(radians: x)
    }

    /// Convenience overload taking integer degrees resolved through `radian(degrees:)`.
    public static func eulerRotationMatrix(degreesX: Int, degreesY: Int, degreesZ: Int) -> simd_float4x4 {
        eulerRotationMatrix(
            x: radian(degrees: degreesX),
            y: radian(degrees: degreesY),
            z: radian(degrees: degreesZ)
        )
    }

    @inlinable
    public static func transformPoint(_ point: SIMD3<Float>, by matrix: simd_float4x4) -> SIMD3<Float> {
        let result = matrix * SIMD4<Float>(point.x, point.y, point.z, 1)
        return SIMD3<Float>(result.x, result.y, result.z)
    }

    @inlinable
    public static func transformVector(_ vector: SIMD3<Float>, by matrix: simd_float4x4) -> SIMD3<Float> {
        let result = matrix * SIMD4<Float>(vector.x, vector.y, vector.z, 0)
        return SIMD3<Float>(result.x, result.y, result.z)
    }

    // MARK: - Perspective Distance Scaling

    /// Mirrors `CRenderer::ScaleDistance(float distance)` (`(viewport.scaleX * rhw) / 7.0f`).
    @inlinable
    public static func scaleDistance(_ reciprocalDepth: Float, viewportScaleX: Float) -> Float {
        (viewportScaleX * reciprocalDepth) / 7.0
    }
}
