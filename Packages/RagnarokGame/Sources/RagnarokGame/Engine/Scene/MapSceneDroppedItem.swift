//
//  MapSceneDroppedItem.swift
//  RagnarokGame
//
//  Created by Leon Li on 2026/5/30.
//

import RagnarokModels
import RagnarokSprite
import simd

final class MapSceneDroppedItem {
    let objectID: GameObjectID
    let itemID: Int

    var gridPosition: SIMD2<Int>
    var worldPosition: SIMD3<Float>

    var sprite: SpriteResource?

    init(item: DroppedItem, gridPosition: SIMD2<Int>, worldPosition: SIMD3<Float>) {
        objectID = item.objectID
        itemID = Int(item.itemID)

        self.gridPosition = gridPosition
        self.worldPosition = worldPosition
    }
}
