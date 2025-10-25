//
//  WalkingComponent.swift
//  GameCore
//
//  Created by Leon Li on 2025/10/25.
//

import Foundation
import RealityKit

struct WalkingComponent: Component {
    var totalTime: TimeInterval = 0
    var stepTime: TimeInterval = 0

    var path: [SIMD2<Int>]
    var mapGrid: MapGrid
}
