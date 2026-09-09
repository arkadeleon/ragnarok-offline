//
//  CombatTextMesh.swift
//  RagnarokGame
//
//  Created by Leon Li on 2026/9/8.
//

import RagnarokShaders
import simd

struct CombatTextMesh {
    let vertices: [SpriteVertex]

    init(
        for combatText: CombatText,
        glyphSet: CombatTextGlyphSet,
        scale: Float,
        alpha: Float
    ) {
        let geometries: [CombatTextGlyphGeometry]
        let spacing: Float
        switch combatText.kind {
        case .hpRecovery, .spRecovery, .damage, .combo, .finalCombo:
            geometries = glyphSet.geometries(for: combatText.amount)
            spacing = 2
        case .miss:
            geometries = glyphSet[.miss].map { [$0] } ?? []
            spacing = 0
        }

        guard !geometries.isEmpty else {
            vertices = []
            return
        }

        var color: SIMD4<Float> = switch combatText.kind {
        case .hpRecovery:
            [0, 1, 0, 1]
        case .spRecovery:
            [0.13, 0.19, 0.75, 1]
        case .miss, .damage:
            combatText.target.isPlayer ? [1, 0, 0, 1] : [1, 1, 1, 1]
        case .combo, .finalCombo:
            [0.9, 0.9, 0.15, 1]
        }
        color.w *= alpha

        var vertices: [SpriteVertex] = []
        vertices.reserveCapacity(geometries.count * 6)

        let width = geometries.reduce(0) { $0 + $1.size.x + spacing }
        var left = -width / 2
        for geometry in geometries {
            let right = left + geometry.size.x
            let bottom = -geometry.size.y / 2
            let top = geometry.size.y / 2

            let minPosition = SIMD2(left, bottom) * scale
            let maxPosition = SIMD2(right, top) * scale
            let minTextureCoordinate = geometry.minTextureCoordinate
            let maxTextureCoordinate = geometry.maxTextureCoordinate

            vertices += [
                SpriteVertex(position: [minPosition.x, minPosition.y], textureCoordinate: [minTextureCoordinate.x, maxTextureCoordinate.y], color: color),
                SpriteVertex(position: [maxPosition.x, minPosition.y], textureCoordinate: [maxTextureCoordinate.x, maxTextureCoordinate.y], color: color),
                SpriteVertex(position: [minPosition.x, maxPosition.y], textureCoordinate: [minTextureCoordinate.x, minTextureCoordinate.y], color: color),
                SpriteVertex(position: [maxPosition.x, minPosition.y], textureCoordinate: [maxTextureCoordinate.x, maxTextureCoordinate.y], color: color),
                SpriteVertex(position: [maxPosition.x, maxPosition.y], textureCoordinate: [maxTextureCoordinate.x, minTextureCoordinate.y], color: color),
                SpriteVertex(position: [minPosition.x, maxPosition.y], textureCoordinate: [minTextureCoordinate.x, minTextureCoordinate.y], color: color),
            ]

            left = right + spacing
        }

        self.vertices = vertices
    }
}
