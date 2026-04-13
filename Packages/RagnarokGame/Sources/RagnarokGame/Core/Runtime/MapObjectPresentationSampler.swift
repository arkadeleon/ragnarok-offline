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
        var action: CharacterActionType
        var direction: CharacterDirection
        var animationElapsed: Duration
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
            mapObject: state.object,
            now: now
        )
    }

    func sample(
        logicalWorldPosition: SIMD3<Float>,
        timeline: MapObjectMovementTimeline?,
        presentation: MapObjectPresentationState,
        mapObject: MapObject,
        now: ContinuousClock.Instant
    ) -> PresentationSample {
        let movementSample = timeline?.sample(at: now, logicalWorldPosition: logicalWorldPosition)
        let worldPosition = movementSample?.worldPosition ?? logicalWorldPosition

        if let movementSample, movementSample.isMoving {
            return PresentationSample(
                worldPosition: worldPosition,
                action: .walk,
                direction: movementSample.direction,
                animationElapsed: movementSample.totalElapsed
            )
        }

        let elapsed = presentation.startTime.duration(to: now)
        if let duration = presentation.duration, elapsed >= duration {
            return PresentationSample(
                worldPosition: worldPosition,
                action: settledAction(after: presentation.action, for: mapObject),
                direction: presentation.direction,
                animationElapsed: elapsed - duration
            )
        }

        return PresentationSample(
            worldPosition: worldPosition,
            action: presentation.action,
            direction: presentation.direction,
            animationElapsed: elapsed
        )
    }

    private func settledAction(after action: CharacterActionType, for mapObject: MapObject) -> CharacterActionType {
        switch action {
        case .sit:
            return .sit
        case .attack1, .attack2, .attack3, .skill:
            let availableActionTypes = CharacterActionType.availableActionTypes(forJobID: mapObject.job)
            return availableActionTypes.contains(.readyToAttack) ? .readyToAttack : .idle
        case .freeze, .freeze2, .die:
            return action
        case .idle, .walk, .pickup, .readyToAttack, .hurt:
            return .idle
        }
    }
}
