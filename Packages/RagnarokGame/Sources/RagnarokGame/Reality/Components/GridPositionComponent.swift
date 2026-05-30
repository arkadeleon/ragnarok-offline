//
//  GridPositionComponent.swift
//  RagnarokGame
//
//  Created by Leon Li on 2026/5/30.
//

import RealityKit
import simd

struct GridPositionComponent: Component {
    var position: SIMD2<Int>

    init(position: SIMD2<Int>) {
        self.position = position
    }
}
