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
    public var startTime: ContinuousClock.Instant
    public var duration: Duration?

    public init(
        action: CharacterActionType,
        direction: CharacterDirection,
        startTime: ContinuousClock.Instant,
        duration: Duration? = nil
    ) {
        self.action = action
        self.direction = direction
        self.startTime = startTime
        self.duration = duration
    }
}
