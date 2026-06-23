//
//  SpriteObject.swift
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

class SpriteObject {
    let objectID: GameObjectID

    var gridPosition: SIMD2<Int>
    var worldPosition: SIMD3<Float>

    var drawables: [SpriteLayerDrawable] = []

    init(
        objectID: GameObjectID,
        gridPosition: SIMD2<Int>,
        worldPosition: SIMD3<Float>
    ) {
        self.objectID = objectID
        self.gridPosition = gridPosition
        self.worldPosition = worldPosition
    }
}
