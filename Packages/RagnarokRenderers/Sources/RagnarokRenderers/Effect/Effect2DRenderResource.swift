//
//  Effect2DRenderResource.swift
//  RagnarokRenderers
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

public final class Effect2DRenderResource {
    struct Sample {
        var worldPosition: SIMD3<Float>
        var size: SIMD2<Float>
        var offset: SIMD2<Float>
        var color: SIMD4<Float>
        var rotationMatrix: simd_float4x4
    }

    public let definition: Effect2DDefinition
    public let vertices: [Effect2DVertex]
    public let texture: (any MTLTexture)?
    public let duplicateID: Int

    private let duration: TimeInterval
    private let positionStart: SIMD3<Float>
    private let positionEnd: SIMD3<Float>
    private let sizeStart: SIMD2<Float>
    private let sizeEnd: SIMD2<Float>
    private let alphaMax: Float
    private let baseAngle: Float
    private let targetAngle: Float

    public var rendersBeforeEntities: Bool {
        definition.rendersBeforeEntities
    }

    public init(device: any MTLDevice, asset: Effect2DAsset, duplicateID: Int = 0) {
        self.definition = asset.definition
        self.vertices = [
            Effect2DVertex(position: [-0.5,  0.5], textureCoordinate: [0, 0]),
            Effect2DVertex(position: [ 0.5,  0.5], textureCoordinate: [1, 0]),
            Effect2DVertex(position: [-0.5, -0.5], textureCoordinate: [0, 1]),
            Effect2DVertex(position: [ 0.5,  0.5], textureCoordinate: [1, 0]),
            Effect2DVertex(position: [ 0.5, -0.5], textureCoordinate: [1, 1]),
            Effect2DVertex(position: [-0.5, -0.5], textureCoordinate: [0, 1]),
        ]
        self.texture = MetalTextureFactory.makeTexture(from: asset.textureImage, device: device, label: "effect2D")
        self.duplicateID = duplicateID

        let instance = asset.instance(forDuplicateID: duplicateID)
        self.duration = instance.duration
        self.positionStart = instance.positionStart
        self.positionEnd = instance.positionEnd
        self.sizeStart = instance.sizeStart
        self.sizeEnd = instance.sizeEnd
        self.baseAngle = instance.baseAngle
        self.targetAngle = instance.targetAngle

        self.alphaMax = min(max(definition.alphaMax, 0), 1)
    }

    public func isExpired(elapsedTime: TimeInterval) -> Bool {
        guard !definition.repeats else {
            return false
        }

        let elapsedTime = elapsedTime - definition.delay(duplicateID: duplicateID)
        guard elapsedTime >= 0 else {
            return false
        }

        return elapsedTime >= duration
    }

    func sample(elapsedTime: TimeInterval, worldPosition: SIMD3<Float>, cameraAzimuth: Float) -> Sample? {
        var elapsedTime = elapsedTime - definition.delay(duplicateID: duplicateID)
        guard elapsedTime >= 0 else {
            return nil
        }

        if definition.repeats {
            elapsedTime.formTruncatingRemainder(dividingBy: duration)
        }

        let progress = Self.progress(elapsedTime: elapsedTime, duration: duration)
        let mapOffset = animatedPosition(progress: progress)

        // Rotate the map-plane offset with the camera so the 2D pattern stays screen-aligned.
        let rotatedMapOffset: SIMD3<Float> = [
            mapOffset.x * cos(cameraAzimuth) - mapOffset.y * sin(cameraAzimuth),
            mapOffset.y * cos(cameraAzimuth) + mapOffset.x * sin(cameraAzimuth),
            mapOffset.z,
        ]
        let position = worldPosition + Self.worldOffset(forMapOffset: rotatedMapOffset)

        let offset: SIMD2<Float> = [
            interpolate(definition.offsetStart.x, definition.offsetEnd.x, progress: progress, smooth: false),
            -interpolate(definition.offsetStart.y, definition.offsetEnd.y, progress: progress, smooth: false),
        ]

        let size: SIMD2<Float> = [
            interpolate(sizeStart.x, sizeEnd.x, progress: progress, smooth: definition.smoothSize),
            interpolate(sizeStart.y, sizeEnd.y, progress: progress, smooth: definition.smoothSize),
        ]

        let alpha = animatedAlpha(elapsedTime: elapsedTime)
        let color = SIMD4<Float>(definition.color, alpha)

        return Sample(
            worldPosition: position,
            size: size,
            offset: offset,
            color: color,
            rotationMatrix: rotationMatrix(progress: progress)
        )
    }

    private func animatedPosition(progress: Float) -> SIMD3<Float> {
        [
            interpolate(positionStart.x, positionEnd.x, progress: progress, smooth: definition.smoothPositionAxes.x),
            interpolate(positionStart.y, positionEnd.y, progress: progress, smooth: definition.smoothPositionAxes.y),
            interpolate(positionStart.z, positionEnd.z, progress: progress, smooth: definition.smoothPositionAxes.z),
        ]
    }

    private func animatedAlpha(elapsedTime: TimeInterval) -> Float {
        var alpha = alphaMax

        if duration > 0, definition.fadesIn, elapsedTime < duration / 4 {
            alpha = Float(elapsedTime / (duration / 4)) * alphaMax
        } else if duration > 0, definition.fadesOut, elapsedTime > duration * 0.75 {
            alpha = Float((duration - elapsedTime) / (duration / 4)) * alphaMax
        }

        return min(max(alpha, 0), 1)
    }

    private func rotationMatrix(progress: Float) -> simd_float4x4 {
        var angle = baseAngle

        if definition.rotates {
            angle += (targetAngle - baseAngle) * progress
        }

        var matrix = matrix_identity_float4x4
        matrix = matrix_rotate(matrix, radians(-angle), [0, 0, 1])
        return matrix
    }

    private func interpolate(_ start: Float, _ end: Float, progress: Float, smooth: Bool) -> Float {
        guard start != end else {
            return start
        }

        let t = smooth ? log10(progress * 9 + 1) : progress
        return start + (end - start) * t
    }

    private static func progress(elapsedTime: TimeInterval, duration: TimeInterval) -> Float {
        guard duration > 0 else {
            return 0
        }
        return Float(min(max(elapsedTime / duration, 0), 1))
    }

    private static func worldOffset(forMapOffset offset: SIMD3<Float>) -> SIMD3<Float> {
        [offset.x, offset.z, -offset.y]
    }
}
