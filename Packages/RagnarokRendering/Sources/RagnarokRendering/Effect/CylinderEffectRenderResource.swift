//
//  CylinderEffectRenderResource.swift
//  RagnarokRendering
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
    public struct Sample: Sendable {
        public var topRadius: Float
        public var bottomRadius: Float
        public var height: Float
        public var color: SIMD4<Float>
        public var positionOffset: SIMD3<Float>
        public var rotationMatrix: simd_float4x4
    }

    public let effect: CylinderEffect
    public let instance: CylinderEffect.Instance
    public let vertices: [CylinderEffectVertex]
    public let texture: (any MTLTexture)?

    public var definition: CylinderEffectDefinition {
        effect.definition
    }

    public var rendersBeforeEntities: Bool {
        effect.definition.rendersBeforeEntities
    }

    public init(device: any MTLDevice, effect: CylinderEffect, instance: CylinderEffect.Instance, asset: CylinderEffectAsset) {
        let definition = effect.definition

        self.effect = effect
        self.instance = instance
        self.vertices = Self.makeVertices(
            totalCircleSides: definition.totalCircleSides,
            visibleCircleSides: definition.visibleCircleSides,
            textureRepeatX: definition.textureRepeatX
        )
        self.texture = MetalTextureFactory.makeTexture(from: asset.textureImage, device: device, label: "cylinderEffect")
    }

    public func isExpired(elapsedTime: TimeInterval) -> Bool {
        guard !definition.repeats else {
            return false
        }

        let elapsedTime = elapsedTime - instance.delay
        guard elapsedTime >= 0 else {
            return false
        }

        return elapsedTime >= definition.duration
    }

    func sample(
        forElapsedTime elapsedTime: TimeInterval,
        cameraAzimuth: Float,
        cameraElevation: Float
    ) -> CylinderEffectRenderResource.Sample? {
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

        return CylinderEffectRenderResource.Sample(
            topRadius: max(topRadius, 0),
            bottomRadius: max(bottomRadius, 0),
            height: max(height, 0),
            color: SIMD4<Float>(definition.color, alpha),
            positionOffset: positionOffset(
                cameraAzimuth: cameraAzimuth,
                cameraElevation: cameraElevation
            ),
            rotationMatrix: rotationMatrix(
                elapsedTime: elapsedTime,
                cameraAzimuth: cameraAzimuth,
                cameraElevation: cameraElevation
            )
        )
    }

    // The offset is (map x, map y, altitude); render space is (x, altitude, -y).
    private func positionOffset(cameraAzimuth: Float, cameraElevation: Float) -> SIMD3<Float> {
        let offset = definition.positionOffset
        let renderSpaceOffset = SIMD3<Float>(offset.x, offset.z, -offset.y)

        guard definition.fixedPerspective else {
            return renderSpaceOffset
        }

        let matrix = cameraFacingMatrix(cameraAzimuth: cameraAzimuth, cameraElevation: cameraElevation)
        let rotatedOffset = matrix * SIMD4<Float>(renderSpaceOffset, 0)
        return SIMD3<Float>(rotatedOffset.x, rotatedOffset.y, rotatedOffset.z)
    }

    private func rotationMatrix(
        elapsedTime: TimeInterval,
        cameraAzimuth: Float,
        cameraElevation: Float
    ) -> simd_float4x4 {
        // The shader applies this as `matrix * position`, so the rotations are
        // appended in reverse of the order they take effect.
        var matrix = matrix_identity_float4x4

        if definition.rotatesWithCamera || definition.fixedPerspective {
            matrix = matrix * cameraFacingMatrix(
                cameraAzimuth: cameraAzimuth,
                cameraElevation: cameraElevation
            )
        }

        let rotationDegrees = instance.rotationDegrees
        if rotationDegrees.z != 0 {
            matrix = matrix_rotate(matrix, radians(rotationDegrees.z), [0, 0, 1])
        }
        if rotationDegrees.y != 0 {
            matrix = matrix_rotate(matrix, radians(rotationDegrees.y), [0, 1, 0])
        }
        if rotationDegrees.x != 0 {
            matrix = matrix_rotate(matrix, radians(rotationDegrees.x), [1, 0, 0])
        }

        if definition.rotatesContinuously {
            matrix = matrix_rotate(matrix, Float(elapsedTime) * 250 / 180 * .pi, [0, 1, 0])
        }

        return matrix
    }

    private func cameraFacingMatrix(cameraAzimuth: Float, cameraElevation: Float) -> simd_float4x4 {
        var matrix = matrix_identity_float4x4
        matrix = matrix_rotate(matrix, -cameraAzimuth, [0, 1, 0])
        if definition.fixedPerspective {
            matrix = matrix_rotate(matrix, -cameraElevation, [1, 0, 0])
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
