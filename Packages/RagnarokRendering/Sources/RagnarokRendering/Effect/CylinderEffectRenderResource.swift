//
//  CylinderEffectRenderResource.swift
//  RagnarokRendering
//
//  Created by Leon Li on 2026/6/25.
//

import Foundation
import Metal
import RagnarokEffects
import RagnarokRenderAssets
import RagnarokShaders
import simd

public final class CylinderEffectRenderResource {
    public let animation: CylinderEffectAnimation
    public let vertices: [CylinderEffectVertex]
    public let texture: (any MTLTexture)?

    public var definition: CylinderEffectDefinition {
        animation.effect.definition
    }

    public var rendersBeforeEntities: Bool {
        definition.rendersBeforeEntities
    }

    public init(
        device: any MTLDevice,
        effect: CylinderEffect,
        instance: CylinderEffect.Instance,
        asset: CylinderEffectAsset,
        duration: TimeInterval? = nil
    ) {
        let definition = effect.definition

        self.animation = CylinderEffectAnimation(effect: effect, instance: instance, duration: duration)
        self.vertices = Self.makeVertices(
            totalCircleSides: definition.totalCircleSides,
            visibleCircleSides: definition.visibleCircleSides,
            textureRepeatX: definition.textureRepeatX
        )
        self.texture = MetalTextureFactory.makeTexture(from: asset.textureImage, device: device, label: "cylinderEffect")
    }

    public func isExpired(elapsedTime: TimeInterval) -> Bool {
        animation.isExpired(elapsedTime: elapsedTime)
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
