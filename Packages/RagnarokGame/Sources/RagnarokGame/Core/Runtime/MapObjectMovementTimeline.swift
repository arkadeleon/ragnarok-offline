//
//  MapObjectMovementTimeline.swift
//  RagnarokGame
//
//  Created by Leon Li on 2026/3/25.
//

import RagnarokModels
import RagnarokSprite
import simd

struct MapObjectMovementTimeline {
    struct MovementSample {
        var worldPosition: SIMD3<Float>
        var direction: SpriteDirection
        var totalElapsed: Duration
        var isMoving: Bool
    }

    private let gridPath: [SIMD2<Int>]
    private let worldPath: [SIMD3<Float>]
    private let stepDurations: [Duration]
    private let startTime: ContinuousClock.Instant
    private let duration: Duration
    private let direction: SpriteDirection
    private let animationElapsedOffset: Duration

    init?(for state: MapObjectState, position: (SIMD2<Int>) -> SIMD3<Float>) {
        guard let movementState = state.movement, movementState.path.count >= 2 else {
            return nil
        }

        let path = movementState.path
        let stepDurations: [Duration] = (1..<path.count).map { index in
            let direction = SpriteDirection(sourcePosition: path[index - 1], targetPosition: path[index])
            let stepMilliseconds = direction.isDiagonal ? Int((Double(state.object.speed) * sqrt(2)).rounded()) : state.object.speed
            return .milliseconds(stepMilliseconds)
        }

        self.gridPath = path
        self.worldPath = path.map(position)
        self.stepDurations = stepDurations
        self.startTime = movementState.startTime
        self.duration = movementState.duration
        self.direction = movementState.direction
        self.animationElapsedOffset = movementState.animationElapsedOffset
    }

    func sample(at now: ContinuousClock.Instant, logicalWorldPosition: SIMD3<Float>) -> MovementSample? {
        guard worldPath.count >= 2,
              gridPath.count == worldPath.count,
              stepDurations.count == worldPath.count - 1 else {
            return nil
        }

        let elapsed = startTime.duration(to: now)
        if elapsed <= .zero {
            return MovementSample(
                worldPosition: worldPath[0],
                direction: direction,
                totalElapsed: animationElapsedOffset,
                isMoving: true
            )
        }

        if elapsed >= duration {
            return MovementSample(
                worldPosition: worldPath.last ?? logicalWorldPosition,
                direction: direction,
                totalElapsed: duration,
                isMoving: false
            )
        }

        var accumulated: Duration = .zero
        for index in stepDurations.indices {
            let stepDuration = stepDurations[index]
            let nextAccumulated = accumulated + stepDuration

            if elapsed < nextAccumulated {
                let stepElapsed = elapsed - accumulated
                let stepSeconds = max(stepDuration.timeInterval, .leastNonzeroMagnitude)
                let fraction = Float(min(max(stepElapsed.timeInterval / stepSeconds, 0), 1))
                let source = worldPath[index]
                let target = worldPath[index + 1]
                let direction = SpriteDirection(
                    sourcePosition: gridPath[index],
                    targetPosition: gridPath[index + 1]
                )

                return MovementSample(
                    worldPosition: mix(source, target, t: fraction),
                    direction: direction,
                    totalElapsed: elapsed + animationElapsedOffset,
                    isMoving: true
                )
            }

            accumulated = nextAccumulated
        }

        return MovementSample(
            worldPosition: worldPath.last ?? logicalWorldPosition,
            direction: direction,
            totalElapsed: duration,
            isMoving: false
        )
    }
}
