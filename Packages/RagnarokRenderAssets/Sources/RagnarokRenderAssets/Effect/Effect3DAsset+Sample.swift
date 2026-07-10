//
//  Effect3DAsset+Sample.swift
//  RagnarokRenderAssets
//
//  Created by Leon Li on 2026/7/10.
//

import Foundation
import RagnarokCore
import RagnarokEffects
import simd

extension Effect3DAsset {
    public struct Sample: Sendable {
        public struct Layer: Sendable {
            public var imageIndex: Int
            public var size: SIMD2<Float>
            public var offset: SIMD2<Float>
            public var color: SIMD4<Float>
            public var rotationMatrix: simd_float4x4
        }

        public var worldPosition: SIMD3<Float>
        public var layers: [Effect3DAsset.Sample.Layer]
    }

    public func isExpired(forDuplicateID duplicateID: Int, elapsedTime: TimeInterval) -> Bool {
        guard !definition.repeats else {
            return false
        }

        let elapsedTime = elapsedTime - definition.delay(duplicateID: duplicateID)
        return elapsedTime >= 0 && elapsedTime >= definition.duration
    }

    public func sample(
        forDuplicateID duplicateID: Int,
        elapsedTime: TimeInterval,
        worldPosition: SIMD3<Float>,
        cameraAzimuth: Float
    ) -> Effect3DAsset.Sample? {
        guard !frames.isEmpty else {
            return nil
        }

        guard let elapsedTime = activeElapsedTime(elapsedTime, forDuplicateID: duplicateID) else {
            return nil
        }

        let instance = instance(forDuplicateID: duplicateID)
        let progress = progress(elapsedTime: elapsedTime)
        let frame = frames[frameIndex(elapsedTime: elapsedTime)]
        let mapOffset = animatedPosition(instance: instance, duplicateID: duplicateID, progress: progress)

        let size = interpolate(
            instance.sizeStart,
            instance.sizeEnd,
            progress: progress,
            smooth: definition.smoothSize
        )

        let alpha = animatedAlpha(forDuplicateID: duplicateID, elapsedTime: elapsedTime, progress: progress)
        let color = SIMD4<Float>(definition.color, alpha)

        let layers = frame.layers.compactMap { layer -> Effect3DAsset.Sample.Layer? in
            guard images.indices.contains(layer.imageIndex) else {
                return nil
            }

            var layerSize = size * layer.sizeFactor
            if layer.isMirrored {
                layerSize.x = -layerSize.x
            }

            return Effect3DAsset.Sample.Layer(
                imageIndex: layer.imageIndex,
                size: layerSize,
                offset: [layer.offset.x, -layer.offset.y],
                color: color * layer.color,
                rotationMatrix: rotationMatrix(
                    instance: instance,
                    progress: progress,
                    cameraAzimuth: cameraAzimuth,
                    layerAngle: layer.angle
                )
            )
        }

        guard !layers.isEmpty else {
            return nil
        }

        return Effect3DAsset.Sample(
            worldPosition: worldPosition + worldOffset(forMapOffset: mapOffset),
            layers: layers
        )
    }

    private func activeElapsedTime(_ elapsedTime: TimeInterval, forDuplicateID duplicateID: Int) -> TimeInterval? {
        var elapsedTime = elapsedTime - definition.delay(duplicateID: duplicateID)
        guard elapsedTime >= 0 else {
            return nil
        }

        if definition.repeats {
            elapsedTime.formTruncatingRemainder(dividingBy: definition.duration)
        }
        return elapsedTime
    }

    private func progress(elapsedTime: TimeInterval) -> Float {
        guard definition.duration > 0 else {
            return 0
        }
        return Float(min(max(elapsedTime / definition.duration, 0), 1))
    }

    private func frameIndex(elapsedTime: TimeInterval) -> Int {
        guard frames.count > 1, definition.frameDelay > 0 else {
            return 0
        }

        return Int(elapsedTime / definition.frameDelay) % frames.count
    }

    private func animatedPosition(instance: Instance, duplicateID: Int, progress: Float) -> SIMD3<Float> {
        let rotationDelay = definition.rotationDelay + definition.duplicate.rotationDelayDelta * TimeInterval(duplicateID)
        let rotationPhase = progress * 100 * 3.5 * definition.rotationCount * .pi / 180 - Float(rotationDelay) * .pi / 2

        var position = interpolate(
            instance.positionStart,
            instance.positionEnd,
            progress: progress,
            smoothAxes: definition.smoothPositionAxes
        )

        if definition.rotatePosition.x > 0 {
            position.x = definition.rotatePosition.x * cos(rotationPhase)
            if definition.rotatesClockwise {
                position.x = -position.x
            }
        }
        if definition.rotatePosition.y > 0 {
            position.y = definition.rotatePosition.y * sin(rotationPhase)
        }

        if definition.retreat != 0 {
            let direction = SIMD2<Float>(
                instance.positionEnd.x - instance.positionStart.x,
                instance.positionEnd.y - instance.positionStart.y
            )
            let distance = simd_length(direction)
            if distance > 0.001 {
                let normalized = direction / distance
                let retreat = sin(progress * .pi) * definition.retreat
                position.x = interpolate(instance.positionStart.x, instance.positionEnd.x, progress: progress, smooth: false) - normalized.x * retreat
                position.y = interpolate(instance.positionStart.y, instance.positionEnd.y, progress: progress, smooth: false) - normalized.y * retreat
            }
        }

        if definition.arc != 0 {
            position.z += definition.arc * sin(progress * .pi)
        }

        return position
    }

    private func animatedAlpha(forDuplicateID duplicateID: Int, elapsedTime: TimeInterval, progress: Float) -> Float {
        let alphaMax = min(max(definition.alphaMax + definition.duplicate.alphaMaxDelta * Float(duplicateID), 0), 1)
        var alpha = alphaMax

        if let fadeAlpha = fadeAlpha(elapsedTime: elapsedTime, alphaMax: alphaMax) {
            alpha = fadeAlpha
        } else if definition.sparkles {
            alpha = alphaMax * ((cos(progress * 100 * 11 * sparkleCount * .pi / 180) + 1) / 2)
        }

        return min(max(alpha, definition.alphaMin), alphaMax)
    }

    // Fading in occupies the first quarter of the duration, fading out the last quarter;
    // nil outside both windows.
    private func fadeAlpha(elapsedTime: TimeInterval, alphaMax: Float) -> Float? {
        let duration = definition.duration
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

    private func rotationMatrix(instance: Instance, progress: Float, cameraAzimuth: Float, layerAngle: Float) -> simd_float4x4 {
        var angle = instance.baseAngle

        if definition.rotates {
            let targetAngle = definition.targetAngle ?? angle
            angle += (targetAngle - angle) * progress
        }

        if definition.rotatesWithCamera {
            angle += degrees(cameraAzimuth)
        }

        if !definition.rotatesToTarget {
            angle += layerAngle
        }

        return rotationMatrix(clockwiseDegrees: angle)
    }

    private func rotationMatrix(clockwiseDegrees angle: Float) -> simd_float4x4 {
        matrix_rotate(matrix_identity_float4x4, radians(-angle), [0, 0, 1])
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

    private func worldOffset(forMapOffset offset: SIMD3<Float>) -> SIMD3<Float> {
        [offset.x, offset.z, -offset.y]
    }
}
