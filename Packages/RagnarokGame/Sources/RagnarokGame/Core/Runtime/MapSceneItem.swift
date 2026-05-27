//
//  MapSceneItem.swift
//  RagnarokGame
//
//  Created by Leon Li on 2026/3/20.
//

import RagnarokModels
import simd

public struct MapSceneItem: Sendable {
    public let objectID: GameObjectID
    public let itemID: Int
    public let gridPosition: SIMD2<Int>

    public init(item: MapItem, gridPosition: SIMD2<Int>) {
        self.objectID = item.objectID
        self.itemID = Int(item.itemID)
        self.gridPosition = gridPosition
    }
}
