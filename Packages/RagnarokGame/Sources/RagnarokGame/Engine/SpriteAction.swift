//
//  SpriteAction.swift
//  RagnarokGame
//
//  Created by Leon Li on 2026/5/30.
//

import RagnarokSprite

struct SpriteAction: Sendable {
    enum Completion: Sendable, Equatable {
        case indefinite
        case after(Duration, nextActionType: SpriteActionType)
        case once(nextActionType: SpriteActionType)
    }

    var actionType: SpriteActionType
    var direction: SpriteDirection
    var headDirection: SpriteHeadDirection
    var startTime: ContinuousClock.Instant
    var elapsedTime: Duration = .zero
    var completion: SpriteAction.Completion

    init(
        actionType: SpriteActionType,
        direction: SpriteDirection,
        headDirection: SpriteHeadDirection,
        startTime: ContinuousClock.Instant,
        completion: SpriteAction.Completion
    ) {
        self.actionType = actionType
        self.direction = direction
        self.headDirection = headDirection
        self.startTime = startTime
        self.completion = completion
    }

    mutating func update(atTime time: ContinuousClock.Instant) {
        let elapsed = startTime.duration(to: time)
        if case .after(let duration, let nextActionType) = completion, elapsed >= duration {
            let overflow = elapsed - duration
            actionType = nextActionType
            startTime = time - overflow
            elapsedTime = overflow
            completion = .indefinite
        } else {
            elapsedTime = elapsed
        }
    }
}
