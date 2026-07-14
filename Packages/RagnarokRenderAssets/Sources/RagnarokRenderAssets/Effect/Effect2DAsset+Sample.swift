//
//  Effect2DAsset+Sample.swift
//  RagnarokRenderAssets
//
//  Created by Leon Li on 2026/7/10.
//

import Foundation
import RagnarokCore
import RagnarokEffects
import simd

extension Effect2DAsset {
    public struct Sample: Sendable {
        public var worldPosition: SIMD3<Float>
        public var size: SIMD2<Float>
        public var offset: SIMD2<Float>
        public var color: SIMD4<Float>
        public var rotationMatrix: simd_float4x4
    }

    public func isExpired(instance: Effect2DAsset.Instance, elapsedTime: TimeInterval) -> Bool {
        guard !definition.repeats else {
            return false
        }

        let elapsedTime = elapsedTime - instance.delay
        return elapsedTime >= 0 && elapsedTime >= instance.duration
    }

    public func sample(
        instance: Effect2DAsset.Instance,
        elapsedTime: TimeInterval,
        worldPosition: SIMD3<Float>,
        cameraAzimuth: Float
    ) -> Effect2DAsset.Sample? {
        guard let elapsedTime = activeElapsedTime(elapsedTime, instance: instance) else {
            return nil
        }

        let progress = progress(elapsedTime: elapsedTime, duration: instance.duration)

        let mapOffset = interpolate(
            instance.positionStart,
            instance.positionEnd,
            progress: progress,
            smoothAxes: definition.smoothPositionAxes
        )

        // Rotate the map-plane offset with the camera so the 2D pattern stays screen-aligned.
        let rotatedMapOffset: SIMD3<Float> = [
            mapOffset.x * cos(cameraAzimuth) - mapOffset.y * sin(cameraAzimuth),
            mapOffset.y * cos(cameraAzimuth) + mapOffset.x * sin(cameraAzimuth),
            mapOffset.z,
        ]

        let screenOffset = interpolate(
            definition.offsetStart,
            definition.offsetEnd,
            progress: progress,
            smooth: false
        )

        let size = interpolate(
            instance.sizeStart,
            instance.sizeEnd,
            progress: progress,
            smooth: definition.smoothSize
        )

        let alphaMax = min(max(definition.alphaMax, 0), 1)
        let alpha = fadeAlpha(elapsedTime: elapsedTime, duration: instance.duration, alphaMax: alphaMax) ?? alphaMax

        var angle = instance.baseAngle
        if definition.rotates {
            angle += (instance.targetAngle - instance.baseAngle) * progress
        }

        return Effect2DAsset.Sample(
            worldPosition: worldPosition + rotatedMapOffset,
            size: size,
            offset: [screenOffset.x, -screenOffset.y],
            color: SIMD4<Float>(definition.color, min(max(alpha, 0), 1)),
            rotationMatrix: rotationMatrix(clockwiseDegrees: angle)
        )
    }

    private func activeElapsedTime(_ elapsedTime: TimeInterval, instance: Effect2DAsset.Instance) -> TimeInterval? {
        var elapsedTime = elapsedTime - instance.delay
        guard elapsedTime >= 0 else {
            return nil
        }

        if definition.repeats {
            elapsedTime.formTruncatingRemainder(dividingBy: instance.duration)
        }
        return elapsedTime
    }

    private func progress(elapsedTime: TimeInterval, duration: TimeInterval) -> Float {
        guard duration > 0 else {
            return 0
        }
        return Float(min(max(elapsedTime / duration, 0), 1))
    }

    // Fading in occupies the first quarter of the duration, fading out the last quarter;
    // nil outside both windows.
    private func fadeAlpha(elapsedTime: TimeInterval, duration: TimeInterval, alphaMax: Float) -> Float? {
        guard duration > 0 else {
            return nil
        }

        if definition.fadesIn, elapsedTime < duration / 4 {
            return Float(elapsedTime / (duration / 4)) * alphaMax
        }
        if definition.fadesOut, elapsedTime > duration * 0.75 {
            return Float((duration - elapsedTime) / (duration / 4)) * alphaMax
        }
        return nil
    }

    private func interpolate(_ start: Float, _ end: Float, progress: Float, smooth: Bool) -> Float {
        guard start != end else {
            return start
        }

        let t = smooth ? log10(progress * 9 + 1) : progress
        return start + (end - start) * t
    }

    private func interpolate(_ start: SIMD2<Float>, _ end: SIMD2<Float>, progress: Float, smooth: Bool) -> SIMD2<Float> {
        [
            interpolate(start.x, end.x, progress: progress, smooth: smooth),
            interpolate(start.y, end.y, progress: progress, smooth: smooth),
        ]
    }

    private func interpolate(_ start: SIMD3<Float>, _ end: SIMD3<Float>, progress: Float, smoothAxes: EffectAxes) -> SIMD3<Float> {
        [
            interpolate(start.x, end.x, progress: progress, smooth: smoothAxes.x),
            interpolate(start.y, end.y, progress: progress, smooth: smoothAxes.y),
            interpolate(start.z, end.z, progress: progress, smooth: smoothAxes.z),
        ]
    }

    private func rotationMatrix(clockwiseDegrees angle: Float) -> simd_float4x4 {
        matrix_rotate(matrix_identity_float4x4, radians(-angle), [0, 0, 1])
    }
}
