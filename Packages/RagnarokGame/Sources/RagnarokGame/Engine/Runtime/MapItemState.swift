//
//  MapItemState.swift
//  RagnarokGame
//
//  Created by Leon Li on 2026/3/20.
//

import RagnarokModels
import simd

public struct MapItemState: Identifiable, Sendable {
    public let id: UInt32
    public var item: MapItem
    public var gridPosition: SIMD2<Int>

    public init(id: UInt32, item: MapItem, gridPosition: SIMD2<Int>) {
        self.id = id
        self.item = item
        self.gridPosition = gridPosition
    }
}
