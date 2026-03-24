//
//  MapObjectMovementState.swift
//  RagnarokGame
//
//  Created by Leon Li on 2026/3/24.
//

import RagnarokSprite
import simd

public struct MapObjectMovementState: Sendable {
    public var from: SIMD2<Int>
    public var to: SIMD2<Int>
    public var path: [SIMD2<Int>]
    public var startedAt: ContinuousClock.Instant
    public var duration: Duration
    public var direction: CharacterDirection

    public init(
        from: SIMD2<Int>,
        to: SIMD2<Int>,
        path: [SIMD2<Int>],
        startedAt: ContinuousClock.Instant,
        duration: Duration,
        direction: CharacterDirection
    ) {
        self.from = from
        self.to = to
        self.path = path
        self.startedAt = startedAt
        self.duration = duration
        self.direction = direction
    }
}
