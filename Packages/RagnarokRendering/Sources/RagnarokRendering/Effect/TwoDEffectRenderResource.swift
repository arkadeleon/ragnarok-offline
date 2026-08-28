//
//  TwoDEffectRenderResource.swift
//  RagnarokRendering
//
//  Created by Leon Li on 2026/7/9.
//

import CoreGraphics
import Foundation
import Metal
import RagnarokCore
import RagnarokEffects
import RagnarokRenderAssets
import RagnarokShaders
import simd

public final class TwoDEffectRenderResource {
    public struct Sample: Sendable {
        public var worldPosition: SIMD3<Float>
        public var size: SIMD2<Float>
        public var offset: SIMD2<Float>
        public var color: SIMD4<Float>
        public var rotationMatrix: simd_float4x4
    }

    public let effect: TwoDEffect
    public let instance: TwoDEffect.Instance
    public let vertices: [TwoDEffectVertex]
    public let texture: (any MTLTexture)?
    public let duration: TimeInterval

    public var definition: TwoDEffectDefinition {
        effect.definition
    }

    public var rendersBeforeEntities: Bool {
        definition.rendersBeforeEntities
    }

    public init(
        device: any MTLDevice,
        effect: TwoDEffect,
        instance: TwoDEffect.Instance,
        textureImage: CGImage,
        duration: TimeInterval? = nil
    ) {
        self.effect = effect
        self.instance = instance

        self.vertices = [
            TwoDEffectVertex(position: [-0.5,  0.5], textureCoordinate: [0, 0]),
            TwoDEffectVertex(position: [ 0.5,  0.5], textureCoordinate: [1, 0]),
            TwoDEffectVertex(position: [-0.5, -0.5], textureCoordinate: [0, 1]),
            TwoDEffectVertex(position: [ 0.5,  0.5], textureCoordinate: [1, 0]),
            TwoDEffectVertex(position: [ 0.5, -0.5], textureCoordinate: [1, 1]),
            TwoDEffectVertex(position: [-0.5, -0.5], textureCoordinate: [0, 1]),
        ]

        self.texture = MetalTextureFactory.makeTexture(from: textureImage, device: device, label: "2DEffect")

        self.duration = duration ?? instance.duration
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
        cameraAzimuth: Float
    ) -> TwoDEffectRenderResource.Sample? {
        guard let elapsedTime = activeElapsedTime(elapsedTime) else {
            return nil
        }

        let progress = progress(elapsedTime: elapsedTime, duration: duration)

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
        let alpha = fadeAlpha(elapsedTime: elapsedTime, duration: duration, alphaMax: alphaMax) ?? alphaMax

        var angle = instance.baseAngle
        if definition.rotates {
            angle += (instance.targetAngle - instance.baseAngle) * progress
        }

        return TwoDEffectRenderResource.Sample(
            worldPosition: worldPosition + rotatedMapOffset,
            size: size,
            offset: [screenOffset.x, -screenOffset.y],
            color: SIMD4<Float>(definition.color, min(max(alpha, 0), 1)),
            rotationMatrix: rotationMatrix(clockwiseDegrees: angle)
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
