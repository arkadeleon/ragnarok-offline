//
//  DamageEffectRenderResource.swift
//  RagnarokGame
//
//  Created by Leon Li on 2026/4/22.
//

import Foundation
import Metal
import RagnarokMetalRendering
import RagnarokShaders
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

    struct Snapshot {
        var vertices: [SpriteVertex]
        var worldPosition: SIMD3<Float>
        var texture: any MTLTexture
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

    func snapshot(at now: ContinuousClock.Instant) -> Snapshot? {
        guard let texture else {
            return nil
        }

        let elapsed = now - creationTime
        guard elapsed >= delay else {
            return nil
        }

        let t = Float((elapsed - delay).timeInterval / duration.timeInterval)
        guard t >= 0, t < 1 else {
            return nil
        }

        let scale: Float
        let worldPosition: SIMD3<Float>
        switch kind {
        case .miss:
            scale = 0.5
            worldPosition = [
                startPosition.x,
                startPosition.y + 3.5 + 7 * t,
                startPosition.z,
            ]
        case .damage:
            scale = 4 * (1 - t)
            worldPosition = [
                startPosition.x + 4 * t,
                startPosition.y + 2 + sin(-.pi / 2 + (.pi * (0.5 + 1.5 * t))) * 5,
                startPosition.z - 4 * t,
            ]
        }

        guard scale > 0 else {
            return nil
        }

        let halfW = frameWidth * spriteScale.x * scale / 2
        let halfH = frameHeight * spriteScale.y * scale / 2
        var vertexColor = color
        vertexColor.w *= 1 - t

        let vertices: [SpriteVertex] = [
            SpriteVertex(position: [-halfW, -halfH], textureCoordinate: [0, 1], color: vertexColor),
            SpriteVertex(position: [ halfW, -halfH], textureCoordinate: [1, 1], color: vertexColor),
            SpriteVertex(position: [-halfW,  halfH], textureCoordinate: [0, 0], color: vertexColor),
            SpriteVertex(position: [ halfW, -halfH], textureCoordinate: [1, 1], color: vertexColor),
            SpriteVertex(position: [ halfW,  halfH], textureCoordinate: [1, 0], color: vertexColor),
            SpriteVertex(position: [-halfW,  halfH], textureCoordinate: [0, 0], color: vertexColor),
        ]

        return Snapshot(vertices: vertices, worldPosition: worldPosition, texture: texture)
    }
}
