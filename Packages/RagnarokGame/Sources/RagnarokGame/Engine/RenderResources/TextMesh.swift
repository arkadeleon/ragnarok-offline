//
//  TextMesh.swift
//  RagnarokGame
//
//  Created by Leon Li on 2026/10/15.
//

import RagnarokShaders
import simd

struct TextMesh {
    let vertices: [SpriteVertex]

    /// One quad of `size` points, centered on x with its top edge at `top`.
    init(size: SIMD2<Float>, top: Float) {
        let left = -size.x / 2
        let right = size.x / 2
        let bottom = top - size.y
        let color = SIMD4<Float>(1, 1, 1, 1)

        vertices = [
            SpriteVertex(position: [left, bottom], textureCoordinate: [0, 1], color: color),
            SpriteVertex(position: [right, bottom], textureCoordinate: [1, 1], color: color),
            SpriteVertex(position: [left, top], textureCoordinate: [0, 0], color: color),
            SpriteVertex(position: [right, bottom], textureCoordinate: [1, 1], color: color),
            SpriteVertex(position: [right, top], textureCoordinate: [1, 0], color: color),
            SpriteVertex(position: [left, top], textureCoordinate: [0, 0], color: color),
        ]
    }
}
