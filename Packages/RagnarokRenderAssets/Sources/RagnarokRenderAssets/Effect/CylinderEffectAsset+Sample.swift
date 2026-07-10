//
//  CylinderEffectAsset+Sample.swift
//  RagnarokRenderAssets
//
//  Created by Leon Li on 2026/7/10.
//

import Foundation
import RagnarokCore
import simd

extension CylinderEffectAsset {
    public struct Sample: Sendable {
        public var topRadius: Float
        public var bottomRadius: Float
        public var height: Float
        public var color: SIMD4<Float>
        public var rotationMatrix: simd_float4x4
    }

    public func isExpired(instance: CylinderEffectAsset.Instance, elapsedTime: TimeInterval) -> Bool {
        guard !definition.repeats else {
            return false
        }

        let elapsedTime = elapsedTime - instance.delay
        guard elapsedTime >= 0 else {
            return false
        }

        return elapsedTime >= definition.duration
    }

    public func sample(
        instance: CylinderEffectAsset.Instance,
        elapsedTime: TimeInterval,
        cameraAzimuth: Float
    ) -> CylinderEffectAsset.Sample? {
        var elapsedTime = elapsedTime - instance.delay
        guard elapsedTime >= 0 else {
            return nil
        }

        let duration = definition.duration
        if definition.repeats {
            elapsedTime.formTruncatingRemainder(dividingBy: duration)
        }

        var topRadius = definition.topRadius
        var bottomRadius = definition.bottomRadius
        var height = definition.height

        // Animations 1 and 2 finish growing within the first second, then hold.
        switch definition.animation {
        case .growHeight:
            let growDuration = min(duration, 1)
            let progress = Float(min(max(elapsedTime / growDuration, 0), 1))
            height = progress * definition.height
        case .growTopRadius:
            let growDuration = min(duration, 1)
            let progress = Float(min(max(elapsedTime / growDuration, 0), 1))
            topRadius = progress * definition.topRadius
        case .shrinkRadius:
            let progress = Float(min(max(elapsedTime / duration, 0), 1))
            topRadius = (1 - progress) * definition.topRadius
            bottomRadius = (1 - progress) * definition.bottomRadius
            if progress < 0.5 {
                height = progress * 2 * definition.height
            } else {
                height = (1 - progress) * 2 * definition.height
            }
        case .growRadius:
            let progress = Float(min(max(elapsedTime / duration, 0), 1))
            topRadius = progress * definition.topRadius
            bottomRadius = progress * definition.bottomRadius
        case .growThenShrinkHeight:
            let progress = Float(min(max(elapsedTime / duration, 0), 1))
            if progress < 0.5 {
                height = progress * 2 * definition.height
            } else {
                height = (1 - progress) * 2 * definition.height
            }
        case nil:
            break
        }

        var alpha = definition.alpha
        if definition.fades {
            let fadeDuration = duration / 4
            if elapsedTime < fadeDuration {
                alpha = Float(elapsedTime / fadeDuration) * definition.alpha
            } else if elapsedTime > duration - fadeDuration {
                alpha = Float((duration - elapsedTime) / fadeDuration) * definition.alpha
            }
            alpha = min(max(alpha, 0), definition.alpha)
        }

        return CylinderEffectAsset.Sample(
            topRadius: max(topRadius, 0),
            bottomRadius: max(bottomRadius, 0),
            height: max(height, 0),
            color: SIMD4<Float>(definition.color, alpha),
            rotationMatrix: rotationMatrix(elapsedTime: elapsedTime, cameraAzimuth: cameraAzimuth)
        )
    }

    private func rotationMatrix(elapsedTime: TimeInterval, cameraAzimuth: Float) -> simd_float4x4 {
        var matrix = matrix_identity_float4x4

        if definition.rotatesContinuously {
            matrix = matrix_rotate(matrix, Float(elapsedTime) * 250 / 180 * .pi, [0, 1, 0])
        }

        if rotationDegrees.x != 0 {
            matrix = matrix_rotate(matrix, radians(rotationDegrees.x), [1, 0, 0])
        }
        if rotationDegrees.y != 0 {
            matrix = matrix_rotate(matrix, radians(rotationDegrees.y), [0, 1, 0])
        }
        if rotationDegrees.z != 0 {
            matrix = matrix_rotate(matrix, radians(rotationDegrees.z), [0, 0, 1])
        }

        if definition.rotatesWithCamera {
            matrix = matrix_rotate(matrix, cameraAzimuth, [0, 1, 0])
        }

        return matrix
    }
}
