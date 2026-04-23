//
//  DamageEffectRenderResource.swift
//  RagnarokGame
//
//  Created by Leon Li on 2026/4/22.
//

import Foundation
import Metal
import RagnarokMetalRendering
import simd

@MainActor
final class DamageEffectRenderResource {
    struct ResolvedTarget {
        var startPosition: SIMD3<Float>
        var isPlayerTarget: Bool
    }

    enum EffectKind {
        case miss
        case damage
    }

    let id: UUID
    let creationTime: ContinuousClock.Instant
    let kind: EffectKind
    let delay: Duration
    let duration: Duration
    let startPosition: SIMD3<Float>
    let texture: (any MTLTexture)?
    let frameWidth: Float
    let frameHeight: Float
    let spriteScale: SIMD2<Float>
    let color: SIMD4<Float>

    init(
        device: any MTLDevice,
        effect: MapDamageEffect,
        resolvedTarget: ResolvedTarget,
        spriteSet: DamageEffectSpriteSet
    ) {
        let image = spriteSet.image(for: effect.amount)
        let texture = MetalTextureFactory.makeTexture(
            from: image,
            device: device,
            label: "damage-effect-\(effect.id.uuidString)"
        )

        let size = image.map {
            SIMD2<Float>(Float($0.width), Float($0.height))
        } ?? SIMD2<Float>(64, 24)

        self.id = effect.id
        self.creationTime = effect.creationTime
        self.kind = effect.amount == 0 ? .miss : .damage
        self.delay = effect.delay
        self.duration = effect.amount == 0 ? .milliseconds(800) : .milliseconds(1500)
        self.startPosition = resolvedTarget.startPosition
        self.texture = texture
        self.frameWidth = size.x
        self.frameHeight = size.y
        self.spriteScale = spriteSet.scale
        self.color = if resolvedTarget.isPlayerTarget {
            [1, 0, 0, 1]
        } else {
            [1, 1, 1, 1]
        }
    }
}
