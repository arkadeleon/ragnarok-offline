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

    /// `onceDuration` is how long the current action takes to play through once, which
    /// only the sprite knows. A `.once` action cannot end without it.
    mutating func update(atTime time: ContinuousClock.Instant, onceDuration: Duration?) {
        let elapsed = startTime.duration(to: time)

        let nextAction: (actionType: SpriteActionType, duration: Duration)? = switch completion {
        case .indefinite:
            nil
        case .after(let duration, let nextActionType):
            (nextActionType, duration)
        case .once(let nextActionType):
            nextActionType == actionType ? nil : onceDuration.map { (nextActionType, $0) }
        }

        if let nextAction, elapsed >= nextAction.duration {
            let overflow = elapsed - nextAction.duration
            actionType = nextAction.actionType
            startTime = time - overflow
            elapsedTime = overflow
            completion = .indefinite
        } else {
            elapsedTime = elapsed
        }
    }
}
