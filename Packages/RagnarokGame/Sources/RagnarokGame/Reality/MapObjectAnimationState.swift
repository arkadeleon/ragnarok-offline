//
//  MapObjectAnimationState.swift
//  RagnarokGame
//
//  Created by Leon Li on 2026/3/24.
//

import RagnarokSprite

public struct MapObjectAnimationState: Sendable {
    public var action: SpriteActionType
    public var direction: SpriteDirection
    public var headDirection: SpriteHeadDirection
    public var startTime: ContinuousClock.Instant
    public var elapsedTime: Duration = .zero
    public var completion: MapObjectAnimationCompletion

    static var defaultAnimation: MapObjectAnimationState {
        MapObjectAnimationState(
            action: .idle,
            direction: .south,
            headDirection: .lookForward,
            startTime: .now,
            completion: .indefinite
        )
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
