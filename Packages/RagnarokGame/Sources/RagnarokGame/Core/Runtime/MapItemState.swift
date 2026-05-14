//
//  MapItemState.swift
//  RagnarokGame
//
//  Created by Leon Li on 2026/3/20.
//

import RagnarokModels
import simd

public struct MapItemState: Identifiable, Sendable {
    public let id: GameObjectID
    public var itemID: Int
    public var gridPosition: SIMD2<Int>

    public init(item: MapItem, gridPosition: SIMD2<Int>) {
        self.id = item.objectID
        self.itemID = Int(item.itemID)
        self.gridPosition = gridPosition
    }
}
