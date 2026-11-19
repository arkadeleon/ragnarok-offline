//
//  TileSelector.swift
//  RagnarokGame
//
//  Created by Leon Li on 2026/8/23.
//

import Foundation
import simd

struct TileSelector {
    let position: SIMD2<Int>
    let showTime: TimeInterval
    let duration: TimeInterval = 0.5

    func isExpired(atTime time: TimeInterval) -> Bool {
        time - showTime >= duration
    }
}
