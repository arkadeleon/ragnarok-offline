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
    public var direction: SpriteDirection
    public var animationElapsedOffset: Duration
}

extension MapObjectMovementState {
    func remainingDuration(at now: ContinuousClock.Instant) -> Duration {
        let elapsed = max(startTime.duration(to: now), .zero)
        return max(duration - elapsed, .zero)
    }
}
