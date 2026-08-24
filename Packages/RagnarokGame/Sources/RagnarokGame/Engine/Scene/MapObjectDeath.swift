//
//  MapObjectDeath.swift
//  RagnarokGame
//
//  Created by Leon Li on 2026/8/22.
//

struct MapObjectDeath {
    var startTime: ContinuousClock.Instant
    var fadeDuration: Duration?

    private(set) var opacity: Float = 1

    mutating func update(at time: ContinuousClock.Instant) {
        guard let fadeDuration, fadeDuration > .zero else {
            opacity = 1
            return
        }
        let progress = Float(startTime.duration(to: time) / fadeDuration)
        opacity = 1 - min(max(progress, 0), 1)
    }

    func isVanished(at time: ContinuousClock.Instant) -> Bool {
        guard let fadeDuration else {
            return false
        }
        return startTime.duration(to: time) >= fadeDuration
    }
}
