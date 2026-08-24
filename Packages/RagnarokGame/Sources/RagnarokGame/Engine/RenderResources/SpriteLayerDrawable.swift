//
//  SpriteLayerDrawable.swift
//  RagnarokGame
//
//  Created by Leon Li on 2026/6/23.
//

import Metal
import RagnarokModels
import RagnarokShaders
import simd

struct SpriteLayerDrawable {
    let objectID: GameObjectID
    var vertices: [SpriteVertex]
    var texture: any MTLTexture
    var worldPosition: SIMD3<Float>
    var isVisible: Bool
}
