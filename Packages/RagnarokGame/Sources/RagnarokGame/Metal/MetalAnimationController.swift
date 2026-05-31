//
//  MetalAnimationController.swift
//  RagnarokGame
//
//  Created by Leon Li on 2026/5/30.
//

import RagnarokSprite

@MainActor
public final class MetalAnimationController {
    public private(set) var animation: MetalAnimation

    init(direction: SpriteDirection, headDirection: SpriteHeadDirection, at time: ContinuousClock.Instant = .now) {
        animation = MetalAnimation(
            action: .idle,
            direction: direction,
            headDirection: headDirection,
            startTime: time,
            completion: .indefinite
        )
    }

    func perform(_ action: SpriteActionType, completion: MetalAnimationCompletion, at time: ContinuousClock.Instant = .now) {
        animation.action = action
        animation.startTime = time
        animation.elapsedTime = .zero
        animation.completion = completion
    }

    func turn(direction: SpriteDirection, headDirection: SpriteHeadDirection) {
        animation.direction = direction
        animation.headDirection = headDirection
    }

    func setDirection(_ direction: SpriteDirection) {
        animation.direction = direction
    }

    func update(at time: ContinuousClock.Instant) {
        animation.update(atTime: time)
    }
}
