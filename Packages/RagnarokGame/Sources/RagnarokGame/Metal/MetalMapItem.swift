//
//  MetalMapItem.swift
//  RagnarokGame
//
//  Created by Leon Li on 2026/5/30.
//

import RagnarokModels
import simd

final class MetalMapItem {
    let objectID: GameObjectID
    let itemID: Int
    let gridPosition: SIMD2<Int>

    init(item: MapItem, gridPosition: SIMD2<Int>) {
        objectID = item.objectID
        itemID = Int(item.itemID)
        self.gridPosition = gridPosition
    }
}
