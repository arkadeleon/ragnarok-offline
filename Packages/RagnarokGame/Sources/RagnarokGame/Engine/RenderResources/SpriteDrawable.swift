//
//  SpriteDrawable.swift
//  RagnarokGame
//
//  Created by Leon Li on 2026/6/23.
//

import Metal
import RagnarokModels
import RagnarokShaders
import simd

struct SpriteDrawable {
    struct Layer {
        var vertices: [SpriteVertex]
        var texture: any MTLTexture
    }

    let objectID: GameObjectID
    var worldPosition: SIMD3<Float>
    var shadow: Float
    var isVisible: Bool
    var layers: [SpriteDrawable.Layer]
}
