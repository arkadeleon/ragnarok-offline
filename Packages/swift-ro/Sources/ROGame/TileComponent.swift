//
//  TileComponent.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2025/3/18.
//

import RealityKit

public struct TileComponent: Component {
    public var position: SIMD2<Int>

    public init(position: SIMD2<Int>) {
        self.position = position
    }
}
