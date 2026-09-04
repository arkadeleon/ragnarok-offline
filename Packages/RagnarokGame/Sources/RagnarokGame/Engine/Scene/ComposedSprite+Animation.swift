//
//  ComposedSprite+Animation.swift
//  RagnarokGame
//
//  Created by Leon Li on 2026/9/4.
//

import RagnarokFileFormats
import RagnarokSprite

extension ComposedSprite {
    /// How long the slowest part takes to play the action through once.
    func duration(
        forActionType actionType: SpriteActionType,
        direction: SpriteDirection,
        headDirection: SpriteHeadDirection,
        attackDelay: Duration
    ) -> Duration? {
        let actionIndex = actionType.calculateActionIndex(forJobID: configuration.job.rawValue, direction: direction)

        var duration: Duration?
        for part in parts {
            let partActionIndex = (part.semantic == .shadow ? 0 : actionIndex)
            guard let partAction = part.sprite.act.action(at: partActionIndex), !partAction.frames.isEmpty else {
                continue
            }

            let frameRange = part.frameRange(
                action: partAction,
                actionType: actionType,
                headDirection: headDirection
            )
            guard !frameRange.isEmpty else {
                continue
            }

            let frameInterval = part.frameInterval(
                action: partAction,
                actionType: actionType,
                frameCount: frameRange.count,
                attackDelay: attackDelay
            )
            duration = max(duration ?? .zero, frameInterval * frameRange.count)
        }

        return duration
    }

    /// Which frame of the action the main part has reached after `elapsedTime`, counted
    /// from the start without wrapping. A looping action keeps counting past its last
    /// frame, so frame 0 of the second loop is a different number from frame 0 of the first.
    func mainFrameIndex(
        forActionType actionType: SpriteActionType,
        direction: SpriteDirection,
        headDirection: SpriteHeadDirection,
        elapsedTime: Duration,
        attackDelay: Duration
    ) -> Int? {
        let actionIndex = actionType.calculateActionIndex(forJobID: configuration.job.rawValue, direction: direction)

        guard let mainPart,
              let mainAction = mainPart.sprite.act.action(at: actionIndex), !mainAction.frames.isEmpty else {
            return nil
        }

        let frameRange = mainPart.frameRange(
            action: mainAction,
            actionType: actionType,
            headDirection: headDirection
        )
        guard !frameRange.isEmpty else {
            return nil
        }

        let frameInterval = mainPart.frameInterval(
            action: mainAction,
            actionType: actionType,
            frameCount: frameRange.count,
            attackDelay: attackDelay
        )
        return Int(elapsedTime / frameInterval)
    }

    /// The sound the main part carries on the frame it has reached, if that frame has one.
    ///
    /// `frameIndex` is the unwrapped count, so this wraps it the same way the renderer does.
    func mainFrameSound(
        forActionType actionType: SpriteActionType,
        direction: SpriteDirection,
        headDirection: SpriteHeadDirection,
        frameIndex: Int
    ) -> String? {
        let actionIndex = actionType.calculateActionIndex(forJobID: configuration.job.rawValue, direction: direction)

        guard let mainPart,
              let mainAction = mainPart.sprite.act.action(at: actionIndex), !mainAction.frames.isEmpty else {
            return nil
        }

        let frameRange = mainPart.frameRange(
            action: mainAction,
            actionType: actionType,
            headDirection: headDirection
        )
        guard !frameRange.isEmpty else {
            return nil
        }

        let localFrameIndex: Int
        if actionType.repeats {
            localFrameIndex = frameIndex % frameRange.count
        } else {
            guard frameIndex < frameRange.count else {
                return nil
            }
            localFrameIndex = frameIndex
        }

        let soundIndex = Int(mainAction.frames[frameRange.lowerBound + localFrameIndex].soundIndex)
        guard mainPart.sprite.act.sounds.indices.contains(soundIndex) else {
            return nil
        }

        return mainPart.sprite.act.sounds[soundIndex]
    }
}

extension ComposedSprite.Part {
    func frameInterval(
        action: ACT.Action,
        actionType: SpriteActionType,
        frameCount: Int,
        attackDelay: Duration
    ) -> Duration {
        if actionType.isAttack {
            attackDelay / frameCount
        } else {
            .seconds(Double(action.frameInterval))
        }
    }
}

extension SpriteActionType {
    var repeats: Bool {
        switch self {
        case .idle, .walk, .sit, .readyToAttack, .freeze, .freeze2:
            true
        case .pickup, .attack1, .hurt, .die, .attack2, .attack3, .skill:
            false
        }
    }
}
