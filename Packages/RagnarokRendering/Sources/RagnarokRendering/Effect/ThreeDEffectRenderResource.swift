//
//  ThreeDEffectRenderResource.swift
//  RagnarokRendering
//
//  Created by Leon Li on 2026/6/29.
//

import Foundation
import Metal
import RagnarokCore
import RagnarokEffects
import RagnarokRenderAssets
import RagnarokShaders
import simd

public final class ThreeDEffectRenderResource {
    public struct Sample: Sendable {
        public struct Layer: Sendable {
            public var imageIndex: Int
            public var size: SIMD2<Float>
            public var offset: SIMD2<Float>
            public var color: SIMD4<Float>
            public var rotationMatrix: simd_float4x4
        }

        public var worldPosition: SIMD3<Float>
        public var layers: [ThreeDEffectRenderResource.Sample.Layer]
    }

    public let effect: ThreeDEffect
    public let instance: ThreeDEffect.Instance
    public let vertices: [ThreeDEffectVertex]
    public let frames: [ThreeDAnimation.Frame]
    public let frameDelay: TimeInterval
    public let textures: [(any MTLTexture)?]
    public let duration: TimeInterval

    public var definition: ThreeDEffectDefinition {
        effect.definition
    }

    public var rendersBeforeEntities: Bool {
        definition.rendersBeforeEntities
    }

    public init(
        device: any MTLDevice,
        effect: ThreeDEffect,
        instance: ThreeDEffect.Instance,
        animation: ThreeDAnimation,
        duration: TimeInterval? = nil
    ) {
        let definition = effect.definition

        self.effect = effect
        self.instance = instance

        self.vertices = [
            ThreeDEffectVertex(position: [-0.5,  0.5], textureCoordinate: [0, 0]),
            ThreeDEffectVertex(position: [ 0.5,  0.5], textureCoordinate: [1, 0]),
            ThreeDEffectVertex(position: [-0.5, -0.5], textureCoordinate: [0, 1]),
            ThreeDEffectVertex(position: [ 0.5,  0.5], textureCoordinate: [1, 0]),
            ThreeDEffectVertex(position: [ 0.5, -0.5], textureCoordinate: [1, 1]),
            ThreeDEffectVertex(position: [-0.5, -0.5], textureCoordinate: [0, 1]),
        ]

        self.frames = animation.frames

        // A sprite's own interval wins over the definition's, unless the
        // definition asks for a specific sprite frame delay.
        if definition.spriteFrameDelay > 0 {
            self.frameDelay = definition.spriteFrameDelay
        } else if let frameInterval = animation.frameInterval {
            self.frameDelay = frameInterval
        } else {
            self.frameDelay = definition.frameDelay
        }

        self.textures = animation.images.enumerated().map { index, image in
            MetalTextureFactory.makeTexture(from: image, device: device, label: "3DEffect[\(index)]")
        }

        self.duration = duration ?? definition.duration
    }

    public func isExpired(elapsedTime: TimeInterval) -> Bool {
        guard !definition.repeats else {
            return false
        }

        let elapsedTime = elapsedTime - instance.delay
        return elapsedTime >= 0 && elapsedTime >= duration
    }

    public func sample(
        atElapsedTime elapsedTime: TimeInterval,
        worldPosition: SIMD3<Float>,
        sourceWorldPosition: SIMD3<Float>?,
        targetWorldPosition: SIMD3<Float>,
        cameraAzimuth: Float
    ) -> ThreeDEffectRenderResource.Sample? {
        guard !frames.isEmpty else {
            return nil
        }

        guard let elapsedTime = activeElapsedTime(elapsedTime) else {
            return nil
        }

        let progress = progress(elapsedTime: elapsedTime)
        let frame = frames[frameIndex(elapsedTime: elapsedTime)]
        let (positionStart, positionEnd) = movementPositions(
            sourceWorldPosition: sourceWorldPosition,
            targetWorldPosition: targetWorldPosition
        )
        let mapOffset = animatedPosition(
            positionStart: positionStart,
            positionEnd: positionEnd,
            progress: progress
        )

        let size = interpolate(
            instance.sizeStart,
            instance.sizeEnd,
            progress: progress,
            smooth: definition.smoothSize
        )

        let alpha = animatedAlpha(elapsedTime: elapsedTime, progress: progress)
        let color = SIMD4<Float>(definition.color, alpha)

        let layers = frame.layers.map { layer -> ThreeDEffectRenderResource.Sample.Layer in
            var layerSize = size * layer.sizeFactor
            if layer.isMirrored {
                layerSize.x = -layerSize.x
            }

            return ThreeDEffectRenderResource.Sample.Layer(
                imageIndex: layer.imageIndex,
                size: layerSize,
                offset: [layer.offset.x, -layer.offset.y],
                color: color * layer.color,
                rotationMatrix: rotationMatrix(
                    positionStart: positionStart,
                    positionEnd: positionEnd,
                    progress: progress,
                    cameraAzimuth: cameraAzimuth,
                    layerAngle: layer.angle
                )
            )
        }

        guard !layers.isEmpty else {
            return nil
        }

        return ThreeDEffectRenderResource.Sample(
            worldPosition: worldPosition + mapOffset,
            layers: layers
        )
    }

    private func activeElapsedTime(_ elapsedTime: TimeInterval) -> TimeInterval? {
        var elapsedTime = elapsedTime - instance.delay
        guard elapsedTime >= 0 else {
            return nil
        }

        if definition.repeats {
            elapsedTime.formTruncatingRemainder(dividingBy: duration)
        }
        return elapsedTime
    }

    private func progress(elapsedTime: TimeInterval) -> Float {
        guard duration > 0 else {
            return 0
        }
        return Float(min(max(elapsedTime / duration, 0), 1))
    }

    private func frameIndex(elapsedTime: TimeInterval) -> Int {
        guard frames.count > 1, frameDelay > 0 else {
            return 0
        }

        return Int(elapsedTime / frameDelay) % frames.count
    }

    private func movementPositions(
        sourceWorldPosition: SIMD3<Float>?,
        targetWorldPosition: SIMD3<Float>
    ) -> (start: SIMD3<Float>, end: SIMD3<Float>) {
        var positionStart = instance.positionStart
        var positionEnd = instance.positionEnd

        // Resolve both movement endpoints relative to the effect's target
        // position. Use a deterministic fallback when no source is available.
        let sourceWorldPosition = sourceWorldPosition ?? targetWorldPosition + [-5, 5, 0]
        let sourceOffset = sourceWorldPosition - targetWorldPosition

        if definition.movesFromSource {
            positionStart = sourceOffset + instance.movementPositionStart
            positionEnd = instance.movementPositionEnd
        } else if definition.movesToSource {
            positionStart = instance.movementPositionStart
            positionEnd = sourceOffset + instance.movementPositionEnd
        }

        return (positionStart, positionEnd)
    }

    private func animatedPosition(
        positionStart: SIMD3<Float>,
        positionEnd: SIMD3<Float>,
        progress: Float
    ) -> SIMD3<Float> {
        let rotationDelay = definition.rotationDelay + definition.duplicate.rotationDelayDelta * TimeInterval(instance.duplicateID)
        let rotationPhase = progress * 100 * 3.5 * definition.rotationCount * .pi / 180 - Float(rotationDelay) * .pi / 2

        var position = interpolate(
            positionStart,
            positionEnd,
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

        if instance.retreat != 0 {
            let direction = SIMD2<Float>(
                positionEnd.x - positionStart.x,
                positionEnd.y - positionStart.y
            )
            let distance = simd_length(direction)
            if distance > 0.001 {
                let normalized = direction / distance
                let retreat = sin(progress * .pi) * instance.retreat
                position.x = interpolate(positionStart.x, positionEnd.x, progress: progress, smooth: false) - normalized.x * retreat
                position.y = interpolate(positionStart.y, positionEnd.y, progress: progress, smooth: false) - normalized.y * retreat
            }
        }

        if instance.arc != 0 {
            position.z += instance.arc * sin(progress * .pi)
        }

        return position
    }

    private func animatedAlpha(elapsedTime: TimeInterval, progress: Float) -> Float {
        let alphaMax = min(max(definition.alphaMax + definition.duplicate.alphaMaxDelta * Float(instance.duplicateID), 0), 1)
        var alpha = alphaMax

        if let fadeAlpha = fadeAlpha(elapsedTime: elapsedTime, alphaMax: alphaMax) {
            alpha = fadeAlpha
        } else if definition.sparkles {
            alpha = alphaMax * ((cos(progress * 100 * 11 * instance.sparkleCount * .pi / 180) + 1) / 2)
        }

        return min(max(alpha, definition.alphaMin), alphaMax)
    }

    // Fading in occupies the first quarter of the duration, fading out the last quarter;
    // nil outside both windows.
    private func fadeAlpha(elapsedTime: TimeInterval, alphaMax: Float) -> Float? {
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

    private func rotationMatrix(
        positionStart: SIMD3<Float>,
        positionEnd: SIMD3<Float>,
        progress: Float,
        cameraAzimuth: Float,
        layerAngle: Float
    ) -> simd_float4x4 {
        var angle = instance.baseAngle

        if definition.rotatesToTarget {
            angle += 90 - degrees(atan2(positionEnd.y - positionStart.y, positionEnd.x - positionStart.x))
        }

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
}
