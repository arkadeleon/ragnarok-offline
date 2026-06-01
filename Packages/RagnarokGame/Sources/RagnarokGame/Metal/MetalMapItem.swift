//
//  MetalMapItem.swift
//  RagnarokGame
//
//  Created by Leon Li on 2026/5/30.
//

import RagnarokModels
import simd

@MainActor
public final class MetalMapItem {
    public let objectID: GameObjectID
    public let itemID: Int
    public let gridPosition: SIMD2<Int>

    init(item: MapItem, gridPosition: SIMD2<Int>) {
        objectID = item.objectID
        itemID = Int(item.itemID)
        self.gridPosition = gridPosition
    }
}
