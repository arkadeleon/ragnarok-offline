//
//  MapItemComponent.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2025/4/2.
//

import RealityKit
import RONetwork

public struct MapItemComponent: Component {
    public var mapItem: MapItem
    public var position: SIMD2<Int>

    public init(mapItem: MapItem, position: SIMD2<Int>) {
        self.mapItem = mapItem
        self.position = position
    }
}
