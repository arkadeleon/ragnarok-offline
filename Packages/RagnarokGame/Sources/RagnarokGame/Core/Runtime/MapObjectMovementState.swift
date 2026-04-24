//
//  MapObjectMovementState.swift
//  RagnarokGame
//
//  Created by Leon Li on 2026/3/24.
//

import RagnarokSprite
import simd

public struct MapObjectMovementState: Sendable {
    public var startPosition: SIMD2<Int>
    public var endPosition: SIMD2<Int>
    public var path: [SIMD2<Int>]
    public var startTime: ContinuousClock.Instant
    public var duration: Duration
    public var animationElapsedOffset: Duration

    var initialDirection: SpriteDirection {
        if path.count >= 2 {
            return SpriteDirection(sourcePosition: path[0], targetPosition: path[1])
        } else {
            return SpriteDirection(sourcePosition: startPosition, targetPosition: endPosition)
        }
    }

    var finalDirection: SpriteDirection {
        if path.count >= 2 {
            return SpriteDirection(sourcePosition: path[path.count - 2], targetPosition: path[path.count - 1])
        } else {
            return SpriteDirection(sourcePosition: startPosition, targetPosition: endPosition)
        }
    }

    func remainingDuration(at now: ContinuousClock.Instant) -> Duration {
        let elapsed = max(startTime.duration(to: now), .zero)
        return max(duration - elapsed, .zero)
    }
}
