//
//  MapItemComponent.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2025/4/2.
//

import RealityKit

public struct MapItemComponent: Component {
    public var item: MapItem

    public init(item: MapItem) {
        self.item = item
    }
}
