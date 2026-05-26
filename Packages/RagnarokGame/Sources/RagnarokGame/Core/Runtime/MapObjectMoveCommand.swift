//
//  MapObjectMoveCommand.swift
//  RagnarokGame
//
//  Created by Leon Li on 2026/5/26.
//

import simd

public struct MapObjectMoveCommand: Sendable {
    public var objectID: GameObjectID
    public var startPosition: SIMD2<Int>
    public var endPosition: SIMD2<Int>
    public var speed: Int
    public var startedAt: ContinuousClock.Instant

    public init(
        objectID: GameObjectID,
        startPosition: SIMD2<Int>,
        endPosition: SIMD2<Int>,
        speed: Int,
        startedAt: ContinuousClock.Instant
    ) {
        self.objectID = objectID
        self.startPosition = startPosition
        self.endPosition = endPosition
        self.speed = speed
        self.startedAt = startedAt
    }
}
