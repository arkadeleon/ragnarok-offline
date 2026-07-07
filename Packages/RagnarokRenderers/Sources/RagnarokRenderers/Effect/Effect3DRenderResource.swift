//
//  Effect3DRenderResource.swift
//  RagnarokRenderers
//
//  Created by Leon Li on 2026/6/29.
//

import CoreGraphics
import Foundation
import Metal
import RagnarokCore
import RagnarokEffects
import RagnarokRenderAssets
import RagnarokShaders
import simd

public final class Effect3DRenderResource {
    struct Snapshot {
        struct Layer {
            var texture: any MTLTexture
            var size: SIMD2<Float>
            var offset: SIMD2<Float>
            var color: SIMD4<Float>
            var rotationMatrix: simd_float4x4
        }

        var worldPosition: SIMD3<Float>
        var layers: [Snapshot.Layer]
    }

    public let definition: Effect3DDefinition
    public let vertices: [Effect3DVertex]
    public let textures: [(any MTLTexture)?]
    public let frames: [Effect3DAsset.Frame]
    public let duplicateID: Int

    private let positionStart: SIMD3<Float>
    private let positionEnd: SIMD3<Float>
    private let sizeStart: SIMD2<Float>
    private let sizeEnd: SIMD2<Float>
    private let alphaMax: Float
    private let rotationDelay: TimeInterval
    private let baseAngle: Float

    public var rendersBeforeEntities: Bool {
        definition.rendersBeforeEntities
    }

    public init(device: any MTLDevice, asset: Effect3DAsset, duplicateID: Int = 0) {
        self.definition = asset.definition
        self.vertices = [
            Effect3DVertex(position: [-0.5,  0.5], textureCoordinate: [0, 0]),
            Effect3DVertex(position: [ 0.5,  0.5], textureCoordinate: [1, 0]),
            Effect3DVertex(position: [-0.5, -0.5], textureCoordinate: [0, 1]),
            Effect3DVertex(position: [ 0.5,  0.5], textureCoordinate: [1, 0]),
            Effect3DVertex(position: [ 0.5, -0.5], textureCoordinate: [1, 1]),
            Effect3DVertex(position: [-0.5, -0.5], textureCoordinate: [0, 1]),
        ]
        self.textures = asset.images.enumerated().map { index, image in
            MetalTextureFactory.makeTexture(from: image, device: device, label: "effect3D[\(index)]")
        }
        self.frames = asset.frames
        self.duplicateID = duplicateID

        var positionStart = definition.positionStart
        var positionEnd = definition.positionEnd

        let randomPosition = Self.randomVector(in: definition.positionRandomRange)
        positionStart += randomPosition
        positionEnd += randomPosition

        if definition.positionRandomDifferenceRange != .zero {
            positionStart += Self.randomVector(in: definition.positionRandomDifferenceRange)
            positionEnd += Self.randomVector(in: definition.positionRandomDifferenceRange)
        }

        if definition.positionStartRandomRange != .zero {
            positionStart += definition.positionStartRandomMiddle + Self.randomVector(in: definition.positionStartRandomRange)
        }

        if definition.positionEndRandomRange != .zero {
            positionEnd += definition.positionEndRandomMiddle + Self.randomVector(in: definition.positionEndRandomRange)
        }

        positionStart += definition.offset
        positionEnd += definition.offset
        positionStart.z += definition.zOffsetStart
        positionEnd.z += definition.zOffsetEnd

        self.positionStart = positionStart
        self.positionEnd = positionEnd

        var sizeStart = definition.sizeStart
        var sizeEnd = definition.sizeEnd

        if definition.duplicate.sizeDelta != 0 {
            let delta = definition.duplicate.sizeDelta * Float(duplicateID)
            sizeStart += [delta, delta]
            sizeEnd += [delta, delta]
        }

        if definition.sizeRandomRange != .zero {
            let randomSizeOffset: SIMD2<Float> = [
                Float.random(in: -definition.sizeRandomRange.x...definition.sizeRandomRange.x),
                Float.random(in: -definition.sizeRandomRange.y...definition.sizeRandomRange.y),
            ]
            sizeStart += randomSizeOffset
            sizeEnd += randomSizeOffset
        }

        self.sizeStart = sizeStart
        self.sizeEnd = sizeEnd
        self.alphaMax = min(max(definition.alphaMax + definition.duplicate.alphaMaxDelta * Float(duplicateID), 0), 1)
        self.rotationDelay = definition.rotationDelay + definition.duplicate.rotationDelayDelta * TimeInterval(duplicateID)

        var baseAngle = definition.angle
        if definition.rotatesToTarget {
            baseAngle += 90 - degrees(atan2(positionEnd.y - positionStart.y, positionEnd.x - positionStart.x))
        }
        self.baseAngle = baseAngle
    }

    public func isExpired(elapsedTime: TimeInterval) -> Bool {
        guard !definition.repeats else {
            return false
        }

        let elapsedTime = elapsedTime - definition.delay(duplicateID: duplicateID)
        guard elapsedTime >= 0 else {
            return false
        }

        let duration = definition.duration
        return elapsedTime >= duration
    }

    func snapshot(elapsedTime: TimeInterval, worldPosition: SIMD3<Float>, cameraAzimuth: Float) -> Snapshot? {
        guard !frames.isEmpty, var elapsedTime = componentElapsedTime(elapsedTime: elapsedTime) else {
            return nil
        }

        let duration = definition.duration
        if definition.repeats {
            elapsedTime.formTruncatingRemainder(dividingBy: duration)
        }

        let progress = Self.progress(elapsedTime: elapsedTime, duration: duration)
        let frame = frames[frameIndex(elapsedTime: elapsedTime)]
        let position = worldPosition + Self.worldOffset(forMapOffset: animatedPosition(progress: progress))
        let animatedSize = animatedSize(progress: progress)
        let alpha = animatedAlpha(elapsedTime: elapsedTime, progress: progress, duration: duration)
        let color = SIMD4<Float>(definition.color, alpha)

        let layers = frame.layers.compactMap { layer -> Snapshot.Layer? in
            guard textures.indices.contains(layer.imageIndex),
                  let texture = textures[layer.imageIndex] else {
                return nil
            }

            var size = animatedSize * layer.sizeFactor
            if layer.isMirrored {
                size.x = -size.x
            }

            return Snapshot.Layer(
                texture: texture,
                size: size,
                offset: [layer.offset.x, -layer.offset.y],
                color: color * layer.color,
                rotationMatrix: rotationMatrix(
                    elapsedTime: elapsedTime,
                    cameraAzimuth: cameraAzimuth,
                    layerAngle: layer.angle
                )
            )
        }

        guard !layers.isEmpty else {
            return nil
        }

        return Snapshot(worldPosition: position, layers: layers)
    }

    private func componentElapsedTime(elapsedTime: TimeInterval) -> TimeInterval? {
        let elapsedTime = elapsedTime - definition.delay(duplicateID: duplicateID)
        guard elapsedTime >= 0 else {
            return nil
        }
        return elapsedTime
    }

    private func frameIndex(elapsedTime: TimeInterval) -> Int {
        guard frames.count > 1, definition.frameDelay > 0 else {
            return 0
        }

        return Int(elapsedTime / definition.frameDelay) % frames.count
    }

    private func animatedPosition(progress: Float) -> SIMD3<Float> {
        var position: SIMD3<Float>

        if definition.rotatePosition.x > 0 {
            var x = definition.rotatePosition.x * cos(progress * 100 * 3.5 * definition.rotationCount * .pi / 180 - Float(rotationDelay) * .pi / 2)
            if definition.rotatesClockwise {
                x = -x
            }
            position = [x, 0, 0]
        } else {
            position = [
                interpolate(positionStart.x, positionEnd.x, progress: progress, smooth: definition.smoothPositionAxes.x),
                0,
                0,
            ]
        }

        if definition.rotatePosition.y > 0 {
            position.y = definition.rotatePosition.y * sin(progress * 100 * 3.5 * definition.rotationCount * .pi / 180 - Float(rotationDelay) * .pi / 2)
        } else {
            position.y = interpolate(positionStart.y, positionEnd.y, progress: progress, smooth: definition.smoothPositionAxes.y)
        }

        if definition.retreat != 0 {
            let linearX = interpolate(positionStart.x, positionEnd.x, progress: progress, smooth: false)
            let linearY = interpolate(positionStart.y, positionEnd.y, progress: progress, smooth: false)
            let direction = SIMD2<Float>(positionEnd.x - positionStart.x, positionEnd.y - positionStart.y)
            let distance = simd_length(direction)
            if distance > 0.001 {
                let normalized = direction / distance
                let retreat = sin(progress * .pi) * definition.retreat
                position.x = linearX - normalized.x * retreat
                position.y = linearY - normalized.y * retreat
            }
        }

        position.z = interpolate(positionStart.z, positionEnd.z, progress: progress, smooth: definition.smoothPositionAxes.z)
        if definition.arc != 0 {
            position.z += definition.arc * sin(progress * .pi)
        }

        return position
    }

    private func animatedSize(progress: Float) -> SIMD2<Float> {
        [
            interpolate(sizeStart.x, sizeEnd.x, progress: progress, smooth: definition.smoothSize),
            interpolate(sizeStart.y, sizeEnd.y, progress: progress, smooth: definition.smoothSize),
        ]
    }

    private func animatedAlpha(elapsedTime: TimeInterval, progress: Float, duration: TimeInterval?) -> Float {
        var alpha = alphaMax

        if let duration, duration > 0, definition.fadesIn, elapsedTime < duration / 4 {
            alpha = Float(elapsedTime / (duration / 4)) * alphaMax
        } else if let duration, duration > 0, definition.fadesOut, elapsedTime > duration * 0.75 {
            alpha = Float((duration - elapsedTime) / (duration / 4)) * alphaMax
        } else if definition.sparkles {
            alpha = alphaMax * ((cos(progress * 100 * 11 * definition.sparkleCount * .pi / 180) + 1) / 2)
        }

        return min(max(alpha, definition.alphaMin), alphaMax)
    }

    private func rotationMatrix(elapsedTime: TimeInterval, cameraAzimuth: Float, layerAngle: Float) -> simd_float4x4 {
        var angle = baseAngle

        if definition.rotates {
            let progress = Self.progress(elapsedTime: elapsedTime, duration: definition.duration)
            let targetAngle = definition.targetAngle ?? angle
            angle += (targetAngle - angle) * progress
        }

        if definition.rotatesWithCamera {
            angle += degrees(cameraAzimuth)
        }

        if !definition.rotatesToTarget {
            angle += layerAngle
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

    private static func progress(elapsedTime: TimeInterval, duration: TimeInterval?) -> Float {
        guard let duration, duration > 0 else {
            return 0
        }
        return Float(min(max(elapsedTime / duration, 0), 1))
    }

    private static func worldOffset(forMapOffset offset: SIMD3<Float>) -> SIMD3<Float> {
        [offset.x, offset.z, -offset.y]
    }

    private static func randomVector(in range: SIMD3<Float>) -> SIMD3<Float> {
        [
            range.x == 0 ? 0 : Float.random(in: -range.x...range.x),
            range.y == 0 ? 0 : Float.random(in: -range.y...range.y),
            range.z == 0 ? 0 : Float.random(in: -range.z...range.z),
        ]
    }
}
