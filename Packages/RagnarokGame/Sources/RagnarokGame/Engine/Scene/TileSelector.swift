//
//  TileSelector.swift
//  RagnarokGame
//
//  Created by Leon Li on 2026/8/23.
//

import simd

struct TileSelector {
    let position: SIMD2<Int>
    let showTime: ContinuousClock.Instant
    let duration: Duration = .milliseconds(500)

    func isExpired(at time: ContinuousClock.Instant) -> Bool {
        showTime.duration(to: time) >= duration
    }
}
