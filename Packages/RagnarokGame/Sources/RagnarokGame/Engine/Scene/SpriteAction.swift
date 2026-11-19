//
//  SpriteAction.swift
//  RagnarokGame
//
//  Created by Leon Li on 2026/5/30.
//

import Foundation
import RagnarokSprite

struct SpriteAction: Sendable {
    enum Completion: Sendable, Equatable {
        case indefinite
        case after(TimeInterval, nextActionType: SpriteActionType)
        case once(nextActionType: SpriteActionType)
    }

    var actionType: SpriteActionType
    var direction: SpriteDirection
    var headDirection: SpriteHeadDirection
    var startTime: TimeInterval
    var elapsedTime: TimeInterval = 0
    var completion: SpriteAction.Completion

    init(
        actionType: SpriteActionType,
        direction: SpriteDirection,
        headDirection: SpriteHeadDirection,
        startTime: TimeInterval,
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
    mutating func update(atTime time: TimeInterval, onceDuration: TimeInterval?) {
        let elapsed = time - startTime

        let nextAction: (actionType: SpriteActionType, duration: TimeInterval)? = switch completion {
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
