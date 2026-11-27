//
//  ParticleMath.swift
//  RagnarokEffects
//
//  Created by Leon Li on 2026/11/27.
//

import Foundation
import simd

/// Math and random helpers shared by modern particle effects.
public enum ParticleMath {
    /// Generates a random float in `[minValue, maxValue]` quantized to 0.1 steps.
    public static func randomRange(_ minValue: Float, _ maxValue: Float) -> Float {
        let low = min(minValue, maxValue)
        let high = max(minValue, maxValue)
        let steps = Int(((high - low) * 10.0).rounded(.towardZero))
        guard steps > 0 else {
            return low
        }
        let sample = Int.random(in: 0..<steps)
        return low + Float(sample) * 0.1
    }

    /// Generates a random point on a horizontal disc centered at `center` with the given `radius`.
    public static func randomDiscPoint(center: SIMD3<Float>, radius: Float) -> SIMD3<Float> {
        let angle = Float.random(in: 0..<(2.0 * EffectSpace.clientPi))
        let distance = Float.random(in: 0...max(0, radius))
        return SIMD3<Float>(
            center.x + cosf(angle) * distance,
            center.y,
            center.z + sinf(angle) * distance
        )
    }

    @inlinable
    public static func makeScaleMatrix(_ sx: Float, _ sy: Float, _ sz: Float) -> simd_float4x4 {
        simd_float4x4(diagonal: SIMD4<Float>(sx, sy, sz, 1))
    }

    @inlinable
    public static func makeTranslationMatrix(_ offset: SIMD3<Float>) -> simd_float4x4 {
        var matrix = matrix_identity_float4x4
        matrix.columns.3 = SIMD4<Float>(offset.x, offset.y, offset.z, 1)
        return matrix
    }
}
