//
//  MapObjectComponent.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2025/4/2.
//

import RealityKit
import RONetwork

public struct MapObjectComponent: Component {
    public var object: MapObject

    public init(object: MapObject) {
        self.object = object
    }
}
