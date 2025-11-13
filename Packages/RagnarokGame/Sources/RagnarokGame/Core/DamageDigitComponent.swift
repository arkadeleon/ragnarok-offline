//
//  DamageDigitComponent.swift
//  RagnarokGame
//
//  Created by Leon Li on 2025/11/13.
//

import Foundation
import RealityKit

struct DamageDigitComponent: Component {
    var digits: String

    var duration: TimeInterval
    var delay: TimeInterval
    var elapsedTime: TimeInterval = 0

    var startPosition: SIMD3<Float>
}
