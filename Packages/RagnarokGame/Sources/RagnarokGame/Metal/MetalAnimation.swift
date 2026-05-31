//
//  MetalAnimation.swift
//  RagnarokGame
//
//  Created by Leon Li on 2026/5/30.
//

import RagnarokSprite

public struct MetalAnimation: Sendable {
    public var action: SpriteActionType
    public var direction: SpriteDirection
    public var headDirection: SpriteHeadDirection
    public var startTime: ContinuousClock.Instant
    public var elapsedTime: Duration = .zero
    public var completion: MetalAnimationCompletion

    public init(
        action: SpriteActionType,
        direction: SpriteDirection,
        headDirection: SpriteHeadDirection,
        startTime: ContinuousClock.Instant,
        completion: MetalAnimationCompletion
    ) {
        self.action = action
        self.direction = direction
        self.headDirection = headDirection
        self.startTime = startTime
        self.completion = completion
    }

    mutating func update(atTime time: ContinuousClock.Instant) {
        let elapsed = startTime.duration(to: time)
        if case .after(let duration, let settledAction) = completion, elapsed >= duration {
            let overflow = elapsed - duration
            action = settledAction
            startTime = time - overflow
            elapsedTime = overflow
            completion = .indefinite
        } else {
            elapsedTime = elapsed
        }
    }
}
