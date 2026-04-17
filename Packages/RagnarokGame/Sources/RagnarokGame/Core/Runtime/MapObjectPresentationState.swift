//
//  MapObjectPresentationState.swift
//  RagnarokGame
//
//  Created by Leon Li on 2026/3/24.
//

import RagnarokSprite

public struct MapObjectPresentationState: Sendable {
    public var action: SpriteActionType
    public var direction: SpriteDirection
    public var headDirection: SpriteHeadDirection
    public var startTime: ContinuousClock.Instant
    public var duration: Duration?

    public init(
        action: SpriteActionType,
        direction: SpriteDirection,
        headDirection: SpriteHeadDirection,
        startTime: ContinuousClock.Instant,
        duration: Duration? = nil
    ) {
        self.action = action
        self.direction = direction
        self.headDirection = headDirection
        self.startTime = startTime
        self.duration = duration
    }
}
