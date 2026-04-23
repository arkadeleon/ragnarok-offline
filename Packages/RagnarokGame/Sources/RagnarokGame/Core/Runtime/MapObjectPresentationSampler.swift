//
//  MapObjectPresentationSampler.swift
//  RagnarokGame
//
//  Created by Leon Li on 2026/3/25.
//

import RagnarokModels
import RagnarokSprite
import simd

struct MapObjectPresentationSampler {
    struct PresentationSample {
        var worldPosition: SIMD3<Float>
        var animation: MapObjectAnimationState
    }

    func sample(
        for state: MapObjectState,
        position: (SIMD2<Int>) -> SIMD3<Float>,
        now: ContinuousClock.Instant
    ) -> PresentationSample {
        let logicalWorldPosition = position(state.gridPosition)
        let timeline = MapObjectMovementTimeline(for: state, position: position)
        return sample(
            logicalWorldPosition: logicalWorldPosition,
            timeline: timeline,
            presentation: state.presentation,
            now: now
        )
    }

    func sample(
        logicalWorldPosition: SIMD3<Float>,
        timeline: MapObjectMovementTimeline?,
        presentation: MapObjectPresentationState,
        now: ContinuousClock.Instant
    ) -> PresentationSample {
        let movementSample = timeline?.sample(at: now, logicalWorldPosition: logicalWorldPosition)
        let worldPosition = movementSample?.worldPosition ?? logicalWorldPosition

        if let movementSample, movementSample.isMoving {
            let animation = MapObjectAnimationState(
                action: .walk,
                direction: movementSample.direction,
                headDirection: presentation.headDirection,
                elapsed: movementSample.totalElapsed,
                completion: .indefinite
            )
            return PresentationSample(
                worldPosition: worldPosition,
                animation: animation
            )
        }

        let elapsed = presentation.startTime.duration(to: now)
        if case .after(let duration, let settledAction) = presentation.completion, elapsed >= duration {
            let animation = MapObjectAnimationState(
                action: settledAction,
                direction: presentation.direction,
                headDirection: presentation.headDirection,
                elapsed: elapsed - duration,
                completion: .indefinite
            )
            return PresentationSample(
                worldPosition: worldPosition,
                animation: animation
            )
        }

        let animation = MapObjectAnimationState(
            action: presentation.action,
            direction: presentation.direction,
            headDirection: presentation.headDirection,
            elapsed: elapsed,
            completion: presentation.completion
        )
        return PresentationSample(
            worldPosition: worldPosition,
            animation: animation
        )
    }
}
