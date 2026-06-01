//
//  MapObjectAnimationState.swift
//  RagnarokGame
//
//  Created by Leon Li on 2026/3/24.
//

import RagnarokSprite

struct MapObjectAnimationState: Sendable {
    var action: SpriteActionType
    var direction: SpriteDirection
    var headDirection: SpriteHeadDirection
    var startTime: ContinuousClock.Instant
    var elapsedTime: Duration = .zero
    var completion: MapObjectAnimationCompletion

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
