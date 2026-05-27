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
    public var completion: MapObjectAnimationCompletion

    static var defaultPresentation: MapObjectPresentationState {
        MapObjectPresentationState(
            action: .idle,
            direction: .south,
            headDirection: .lookForward,
            startTime: .now,
            completion: .indefinite
        )
    }

    func animation(at now: ContinuousClock.Instant) -> MapObjectAnimationState {
        let elapsed = startTime.duration(to: now)
        if case .after(let duration, let settledAction) = completion, elapsed >= duration {
            return MapObjectAnimationState(
                action: settledAction,
                direction: direction,
                headDirection: headDirection,
                elapsed: elapsed - duration,
                completion: .indefinite
            )
        }

        return MapObjectAnimationState(
            action: action,
            direction: direction,
            headDirection: headDirection,
            elapsed: elapsed,
            completion: completion
        )
    }
}
