//
//  MapObjectComponent.swift
//  RagnarokGame
//
//  Created by Leon Li on 2026/5/30.
//

import RagnarokModels
import RealityKit

struct MapObjectComponent: Component {
    var object: MapObject

    init(object: MapObject) {
        self.object = object
    }
}
