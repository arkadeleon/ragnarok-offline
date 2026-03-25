//
//  MapObjectPresentationEvaluator.swift
//  RagnarokGame
//
//  Created by Leon Li on 2026/3/25.
//

import RagnarokModels
import RagnarokSprite
import simd

enum MapObjectPresentationEvaluator {
    struct MovementSample {
        var worldPosition: SIMD3<Float>
        var direction: CharacterDirection
        var totalElapsed: Duration
        var isMoving: Bool
    }

    struct PresentationSample {
        var worldPosition: SIMD3<Float>
        var action: CharacterActionType
        var direction: CharacterDirection
        var animationElapsed: Duration
    }

    static func makePresentationTimeline(
        for state: MapObjectState,
        position: (SIMD2<Int>) -> SIMD3<Float>
    ) -> MapObjectPresentationTimeline? {
        guard let movementState = state.movement, movementState.path.count >= 2 else {
            return nil
        }

        return MapObjectPresentationTimeline(
            gridPath: movementState.path,
            worldPath: movementState.path.map(position),
            stepDurations: stepDurations(for: movementState.path, speed: state.object.speed),
            startedAt: movementState.startedAt,
            duration: movementState.duration,
            direction: movementState.direction
        )
    }

    static func resolvedPresentation(
        for state: MapObjectState,
        now: ContinuousClock.Instant,
        position: (SIMD2<Int>) -> SIMD3<Float>
    ) -> PresentationSample {
        let logicalWorldPosition = position(state.gridPosition)
        let timeline = makePresentationTimeline(for: state, position: position)
        return resolvedPresentation(
            logicalWorldPosition: logicalWorldPosition,
            timeline: timeline,
            presentation: state.presentation,
            mapObject: state.object,
            now: now
        )
    }

    static func resolvedPresentation(
        logicalWorldPosition: SIMD3<Float>,
        timeline: MapObjectPresentationTimeline?,
        presentation: MapObjectPresentationState,
        mapObject: MapObject,
        now: ContinuousClock.Instant
    ) -> PresentationSample {
        let timelineSample = timelineSample(
            logicalWorldPosition: logicalWorldPosition,
            timeline: timeline,
            now: now
        )
        let worldPosition = timelineSample?.worldPosition ?? logicalWorldPosition

        if let timelineSample, timelineSample.isMoving {
            return PresentationSample(
                worldPosition: worldPosition,
                action: .walk,
                direction: timelineSample.direction,
                animationElapsed: timelineSample.totalElapsed
            )
        }

        let elapsed = presentation.startedAt.duration(to: now)
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

    static func stepDurations(for path: [SIMD2<Int>], speed: Int) -> [Duration] {
        guard path.count >= 2 else {
            return []
        }

        return (1..<path.count).map { index in
            let direction = CharacterDirection(sourcePosition: path[index - 1], targetPosition: path[index])
            let stepMilliseconds = direction.isDiagonal ? Int((Double(speed) * sqrt(2)).rounded()) : speed
            return .milliseconds(stepMilliseconds)
        }
    }

    static func settledAction(after action: CharacterActionType, for mapObject: MapObject) -> CharacterActionType {
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

    private static func timelineSample(
        logicalWorldPosition: SIMD3<Float>,
        timeline: MapObjectPresentationTimeline?,
        now: ContinuousClock.Instant
    ) -> MovementSample? {
        guard let timeline,
              timeline.worldPath.count >= 2,
              timeline.gridPath.count == timeline.worldPath.count,
              timeline.stepDurations.count == timeline.worldPath.count - 1 else {
            return nil
        }

        let elapsed = timeline.startedAt.duration(to: now)
        if elapsed <= .zero {
            return MovementSample(
                worldPosition: timeline.worldPath[0],
                direction: timeline.direction,
                totalElapsed: .zero,
                isMoving: true
            )
        }

        if elapsed >= timeline.duration {
            return MovementSample(
                worldPosition: timeline.worldPath.last ?? logicalWorldPosition,
                direction: timeline.direction,
                totalElapsed: timeline.duration,
                isMoving: false
            )
        }

        var accumulated: Duration = .zero
        for index in timeline.stepDurations.indices {
            let stepDuration = timeline.stepDurations[index]
            let nextAccumulated = accumulated + stepDuration

            if elapsed < nextAccumulated {
                let stepElapsed = elapsed - accumulated
                let stepSeconds = max(stepDuration.timeInterval, .leastNonzeroMagnitude)
                let fraction = Float(min(max(stepElapsed.timeInterval / stepSeconds, 0), 1))
                let source = timeline.worldPath[index]
                let target = timeline.worldPath[index + 1]
                let direction = CharacterDirection(
                    sourcePosition: timeline.gridPath[index],
                    targetPosition: timeline.gridPath[index + 1]
                )

                return MovementSample(
                    worldPosition: mix(source, target, t: fraction),
                    direction: direction,
                    totalElapsed: elapsed,
                    isMoving: true
                )
            }

            accumulated = nextAccumulated
        }

        return MovementSample(
            worldPosition: timeline.worldPath.last ?? logicalWorldPosition,
            direction: timeline.direction,
            totalElapsed: timeline.duration,
            isMoving: false
        )
    }
}
