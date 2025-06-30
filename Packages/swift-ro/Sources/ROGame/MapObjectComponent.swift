//
//  MapObjectComponent.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2025/4/2.
//

import RealityKit
import RONetwork

public struct MapObjectComponent: Component {
    public var mapObject: MapObject
    public var position: SIMD2<Int>

    public init(mapObject: MapObject, position: SIMD2<Int>) {
        self.mapObject = mapObject
        self.position = position
    }
}
