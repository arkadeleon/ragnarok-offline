//
//  MapItemComponent.swift
//  RagnarokGame
//
//  Created by Leon Li on 2026/5/30.
//

import RagnarokModels
import RealityKit

struct MapItemComponent: Component {
    var item: MapItem

    init(item: MapItem) {
        self.item = item
    }
}
