//
//  GridPositionComponent.swift
//  RagnarokGame
//
//  Created by Leon Li on 2025/9/23.
//

import RealityKit

struct GridPositionComponent: Component {
    var gridPosition: SIMD2<Int>
}

extension Entity {
    var gridPosition: SIMD2<Int> {
        components[GridPositionComponent.self]?.gridPosition ?? [Int(position.x), Int(position.y)]
    }
}
