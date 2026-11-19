//
//  MapObjectDeath.swift
//  RagnarokGame
//
//  Created by Leon Li on 2026/8/22.
//

import Foundation

struct MapObjectDeath {
    var startTime: TimeInterval
    var fadeDuration: TimeInterval?

    private(set) var opacity: Float = 1

    mutating func update(atTime time: TimeInterval) {
        guard let fadeDuration, fadeDuration > 0 else {
            opacity = 1
            return
        }
        let progress = Float((time - startTime) / fadeDuration)
        opacity = 1 - min(max(progress, 0), 1)
    }

    func isVanished(atTime time: TimeInterval) -> Bool {
        guard let fadeDuration else {
            return false
        }
        return time - startTime >= fadeDuration
    }
}
