//
//  MapObjectCast.swift
//  RagnarokGame
//
//  Created by Leon Li on 2026/8/27.
//

import Foundation

struct MapObjectCast {
    var startTime: ContinuousClock.Instant
    var duration: Duration
    var spellEffectObjectID: UUID?

    func progress(at time: ContinuousClock.Instant) -> Float {
        guard duration > .zero else {
            return 1
        }
        let progress = Float(startTime.duration(to: time) / duration)
        return min(max(progress, 0), 1)
    }

    func isFinished(at time: ContinuousClock.Instant) -> Bool {
        startTime.duration(to: time) >= duration
    }
}
