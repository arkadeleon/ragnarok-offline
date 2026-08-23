//
//  CombatTextRenderResource.swift
//  RagnarokGame
//
//  Created by Leon Li on 2026/4/22.
//

import Foundation
import Metal
import RagnarokRendering
import RagnarokShaders
import simd

struct CombatTextRenderResource {
    let texture: any MTLTexture
    let frameWidth: Float
    let frameHeight: Float
    let spriteScale: SIMD2<Float>
    let color: SIMD4<Float>

    /// Where the target stood when the text was created. The text falls back to this
    /// once the target has left the map.
    let startWorldPosition: SIMD3<Float>

    init?(
        device: any MTLDevice,
        combatText: CombatText,
        startWorldPosition: SIMD3<Float>,
        spriteSet: CombatTextSpriteSet
    ) {
        let image = switch combatText.kind {
        case .hpRecovery, .spRecovery, .damage, .combo, .finalCombo:
            spriteSet.digitImage(for: combatText.amount)
        case .miss:
            spriteSet.missImage
        }

        guard let texture = MetalTextureFactory.makeTexture(
            from: image,
            device: device,
            label: "combat-text-\(combatText.id.uuidString)"
        ) else {
            return nil
        }

        let size = image.map {
            SIMD2<Float>(Float($0.width), Float($0.height))
        } ?? SIMD2<Float>(64, 24)

        self.texture = texture
        self.frameWidth = size.x
        self.frameHeight = size.y
        self.spriteScale = spriteSet.scale
        self.startWorldPosition = startWorldPosition
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
        case .combo, .finalCombo:
            [0.9, 0.9, 0.15, 1]
        }
    }

    /// The quad that draws the text, in sprite space around its world position.
    func makeVertices(scale: Float, alpha: Float) -> [SpriteVertex] {
        let halfWidth = frameWidth * spriteScale.x * scale / 2
        let halfHeight = frameHeight * spriteScale.y * scale / 2

        var vertexColor = color
        vertexColor.w *= alpha

        return [
            SpriteVertex(position: [-halfWidth, -halfHeight], textureCoordinate: [0, 1], color: vertexColor),
            SpriteVertex(position: [ halfWidth, -halfHeight], textureCoordinate: [1, 1], color: vertexColor),
            SpriteVertex(position: [-halfWidth,  halfHeight], textureCoordinate: [0, 0], color: vertexColor),
            SpriteVertex(position: [ halfWidth, -halfHeight], textureCoordinate: [1, 1], color: vertexColor),
            SpriteVertex(position: [ halfWidth,  halfHeight], textureCoordinate: [1, 0], color: vertexColor),
            SpriteVertex(position: [-halfWidth,  halfHeight], textureCoordinate: [0, 0], color: vertexColor),
        ]
    }
}
