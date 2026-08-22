//
//  MapSceneDroppedItem.swift
//  RagnarokGame
//
//  Created by Leon Li on 2026/5/30.
//

import RagnarokModels
import simd

final class MapSceneDroppedItem {
    let objectID: GameObjectID
    let itemID: Int

    var gridPosition: SIMD2<Int>

    init(item: DroppedItem, gridPosition: SIMD2<Int>) {
        objectID = item.objectID
        itemID = Int(item.itemID)

        self.gridPosition = gridPosition
    }
}
