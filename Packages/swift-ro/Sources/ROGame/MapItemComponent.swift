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

    public init(mapItem: MapItem) {
        self.mapItem = mapItem
    }
}
