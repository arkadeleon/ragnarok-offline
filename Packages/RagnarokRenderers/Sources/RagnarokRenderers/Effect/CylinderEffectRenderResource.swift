//
//  CylinderEffectRenderResource.swift
//  RagnarokRenderers
//
//  Created by Leon Li on 2026/6/25.
//

import Foundation
import Metal
import RagnarokCore
import RagnarokEffects
import RagnarokRenderAssets
import RagnarokShaders
import simd

public final class CylinderEffectRenderResource {
    struct Snapshot {
        var topRadius: Float
        var bottomRadius: Float
        var height: Float
        var color: SIMD4<Float>
        var rotationMatrix: simd_float4x4
    }

    public let definition: CylinderEffectDefinition
    public let vertices: [CylinderEffectVertex]
    public let texture: (any MTLTexture)?

    public let worldPosition: SIMD3<Float>
    public let duplicateID: Int

    public var rendersBeforeEntities: Bool {
        definition.rendersBeforeEntities
    }

    public init(
        device: any MTLDevice,
        asset: CylinderEffectAsset,
        worldPosition: SIMD3<Float>,
        duplicateID: Int = 0
    ) {
        self.definition = asset.definition
        self.vertices = Self.makeVertices(
            totalCircleSides: definition.totalCircleSides,
            visibleCircleSides: definition.visibleCircleSides,
            textureRepeatX: definition.textureRepeatX
        )
        self.texture = MetalTextureFactory.makeTexture(from: asset.textureImage, device: device, label: "cylinderEffect")
        self.worldPosition = worldPosition
        self.duplicateID = duplicateID
    }

    public func isExpired(elapsedTime: TimeInterval) -> Bool {
        guard !definition.repeats, let duration = definition.duration else {
            return false
        }

        let elapsedTime = elapsedTime - definition.delay(duplicateID: duplicateID)
        guard elapsedTime >= 0 else {
            return false
        }

        return elapsedTime >= duration
    }

    func snapshot(elapsedTime: TimeInterval, cameraAzimuth: Float) -> Snapshot? {
        guard var elapsedTime = componentElapsedTime(elapsedTime: elapsedTime) else {
            return nil
        }

        if definition.repeats, let duration = definition.duration, duration > 0 {
            elapsedTime.formTruncatingRemainder(dividingBy: duration)
        }

        var topRadius = definition.topRadius
        var bottomRadius = definition.bottomRadius
        var height = definition.height

        if let duration = definition.duration, duration > 0 {
            let progress = Float(min(max(elapsedTime / duration, 0), 1))
            switch definition.animation {
            case .growHeight:
                height = progress * definition.height
            case .growTopRadius:
                topRadius = progress * definition.topRadius
            case .shrinkRadius:
                topRadius = (1 - progress) * definition.topRadius
                bottomRadius = (1 - progress) * definition.bottomRadius
                if progress < 0.5 {
                    height = progress * 2 * definition.height
                } else {
                    height = (1 - progress) * 2 * definition.height
                }
            case .growRadius:
                topRadius = progress * definition.topRadius
                bottomRadius = progress * definition.bottomRadius
            case .growThenShrinkHeight:
                if progress < 0.5 {
                    height = progress * 2 * definition.height
                } else {
                    height = (1 - progress) * 2 * definition.height
                }
            case nil:
                break
            }
        }

        var alpha = definition.alpha
        if definition.fades, let duration = definition.duration, duration > 0 {
            let fadeDuration = duration / 4
            if elapsedTime < fadeDuration {
                alpha = Float(elapsedTime / fadeDuration) * definition.alpha
            } else if elapsedTime > duration - fadeDuration {
                alpha = Float((duration - elapsedTime) / fadeDuration) * definition.alpha
            }
            alpha = min(max(alpha, 0), definition.alpha)
        }

        return Snapshot(
            topRadius: max(topRadius, 0),
            bottomRadius: max(bottomRadius, 0),
            height: max(height, 0),
            color: SIMD4<Float>(definition.color, alpha),
            rotationMatrix: rotationMatrix(elapsedTime: elapsedTime, cameraAzimuth: cameraAzimuth)
        )
    }

    private func componentElapsedTime(elapsedTime: TimeInterval) -> TimeInterval? {
        let elapsedTime = elapsedTime - definition.delay(duplicateID: duplicateID)
        guard elapsedTime >= 0 else {
            return nil
        }
        return elapsedTime
    }

    private func rotationMatrix(elapsedTime: TimeInterval, cameraAzimuth: Float) -> simd_float4x4 {
        var matrix = matrix_identity_float4x4

        if definition.rotatesContinuously {
            matrix = matrix_rotate(matrix, Float(elapsedTime) * 250 / 180 * .pi, [0, 1, 0])
        }

        let rotationDegrees = definition.rotationDegrees
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

    private static func makeVertices(
        totalCircleSides: Int,
        visibleCircleSides: Int,
        textureRepeatX: Float
    ) -> [CylinderEffectVertex] {
        let totalCircleSides = max(totalCircleSides, 3)
        let visibleCircleSides = max(min(visibleCircleSides, totalCircleSides), 1)

        func vertex(side: Int, top: Bool) -> CylinderEffectVertex {
            let circleFraction = Float(side) / Float(totalCircleSides)
            let angle = circleFraction * 2 * Float.pi
            let textureU = circleFraction * Float(totalCircleSides) / Float(visibleCircleSides) * textureRepeatX
            return CylinderEffectVertex(
                position: [sin(angle), cos(angle), top ? 1 : 0],
                textureCoordinate: [textureU, top ? 0 : 1]
            )
        }

        var vertices: [CylinderEffectVertex] = []
        vertices.reserveCapacity(visibleCircleSides * 6)

        for side in 0..<visibleCircleSides {
            let bottom0 = vertex(side: side, top: false)
            let top0 = vertex(side: side, top: true)
            let bottom1 = vertex(side: side + 1, top: false)
            let top1 = vertex(side: side + 1, top: true)

            vertices.append(bottom0)
            vertices.append(top0)
            vertices.append(bottom1)
            vertices.append(top0)
            vertices.append(bottom1)
            vertices.append(top1)
        }

        return vertices
    }
}
