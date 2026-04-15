//
//  MapObjectPresentationState.swift
//  RagnarokGame
//
//  Created by Leon Li on 2026/3/24.
//

import RagnarokSprite

public struct MapObjectPresentationState: Sendable {
    public var action: CharacterActionType
    public var direction: CharacterDirection
    public var headDirection: CharacterHeadDirection
    public var startTime: ContinuousClock.Instant
    public var duration: Duration?

    public init(
        action: CharacterActionType,
        direction: CharacterDirection,
        headDirection: CharacterHeadDirection,
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
