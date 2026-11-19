//
//  MapObjectCast.swift
//  RagnarokGame
//
//  Created by Leon Li on 2026/8/27.
//

import Foundation

struct MapObjectCast {
    var startTime: TimeInterval
    var duration: TimeInterval

    func progress(atTime time: TimeInterval) -> Float {
        guard duration > 0 else {
            return 1
        }
        let progress = Float((time - startTime) / duration)
        return min(max(progress, 0), 1)
    }

    func isFinished(atTime time: TimeInterval) -> Bool {
        time - startTime >= duration
    }
}
