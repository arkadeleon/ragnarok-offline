//
//  CombatTextRenderResource.swift
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
final class CombatTextRenderResource {
    struct Snapshot {
        var vertices: [SpriteVertex]
        var worldPosition: SIMD3<Float>
        var texture: any MTLTexture
    }

    let combatText: MapCombatText
    let startPosition: SIMD3<Float>
    let texture: (any MTLTexture)?
    let frameWidth: Float
    let frameHeight: Float
    let spriteScale: SIMD2<Float>
    let color: SIMD4<Float>

    init(
        device: any MTLDevice,
        combatText: MapCombatText,
        startPosition: SIMD3<Float>,
        spriteSet: CombatTextSpriteSet
    ) {
        let image = switch combatText.kind {
        case .miss:
            spriteSet.missImage
        case .damage, .hpRecovery, .spRecovery:
            spriteSet.digitImage(for: combatText.amount)
        }
        let texture = MetalTextureFactory.makeTexture(
            from: image,
            device: device,
            label: "combat-text-\(combatText.id.uuidString)"
        )

        let size = image.map {
            SIMD2<Float>(Float($0.width), Float($0.height))
        } ?? SIMD2<Float>(64, 24)

        self.combatText = combatText
        self.startPosition = startPosition
        self.texture = texture
        self.frameWidth = size.x
        self.frameHeight = size.y
        self.spriteScale = spriteSet.scale
        self.color = switch combatText.kind {
        case .hpRecovery:
            [0, 1, 0, 1]
        case .spRecovery:
            [0.13, 0.19, 0.75, 1]
        case .miss, .damage:
            if combatText.target.isPlayer {
                [1, 0, 0, 1]
            } else {
                [1, 1, 1, 1]
            }
        }
    }

    func snapshot(at now: ContinuousClock.Instant) -> Snapshot? {
        guard let texture else {
            return nil
        }

        let elapsed = now - combatText.creationTime
        guard elapsed >= combatText.delay else {
            return nil
        }

        let animationElapsed = elapsed - combatText.delay
        let t = Float(animationElapsed.timeInterval / combatText.duration.timeInterval)
        guard t >= 0, t < 1 else {
            return nil
        }

        let scale: Float
        let worldPosition: SIMD3<Float>
        switch combatText.kind {
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
        case .hpRecovery, .spRecovery:
            scale = max((1 - t * 2) * 3, 0.8)
            worldPosition = [
                startPosition.x,
                startPosition.y + 2 + (t < 0.4 ? 0 : (t - 0.4) * 5),
                startPosition.z,
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

    func isExpired(at now: ContinuousClock.Instant) -> Bool {
        now - combatText.creationTime > combatText.delay + combatText.duration + .seconds(1)
    }
}
