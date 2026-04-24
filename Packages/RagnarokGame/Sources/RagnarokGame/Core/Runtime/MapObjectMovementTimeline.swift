//
//  MapObjectMovementTimeline.swift
//  RagnarokGame
//
//  Created by Leon Li on 2026/3/25.
//

import RagnarokModels
import RagnarokSprite
import simd

private struct MapObjectMovementPathProgress {
    struct ActiveStep {
        var index: Int
        var elapsed: Duration
        var accumulated: Duration
        var stepDuration: Duration
    }

    let stepDurations: [Duration]
    let startTime: ContinuousClock.Instant
    let duration: Duration

    init(
        path: [SIMD2<Int>],
        speed: Int,
        startTime: ContinuousClock.Instant,
        duration: Duration
    ) {
        self.stepDurations = (1..<path.count).map { index in
            let direction = SpriteDirection(sourcePosition: path[index - 1], targetPosition: path[index])
            let stepMilliseconds = direction.isDiagonal ? Int((Double(speed) * sqrt(2)).rounded()) : speed
            return .milliseconds(stepMilliseconds)
        }
        self.startTime = startTime
        self.duration = duration
    }

    func activeStep(at now: ContinuousClock.Instant) -> ActiveStep? {
        let elapsed = startTime.duration(to: now)
        guard elapsed > .zero, elapsed < duration else {
            return nil
        }

        var accumulated: Duration = .zero
        for index in stepDurations.indices {
            let stepDuration = stepDurations[index]
            let nextAccumulated = accumulated + stepDuration

            if elapsed < nextAccumulated {
                return ActiveStep(
                    index: index,
                    elapsed: elapsed,
                    accumulated: accumulated,
                    stepDuration: stepDuration
                )
            }

            accumulated = nextAccumulated
        }

        return nil
    }
}

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
    private let initialDirection: SpriteDirection
    private let finalDirection: SpriteDirection
    private let animationElapsedOffset: Duration
    private let progress: MapObjectMovementPathProgress

    init?(for state: MapObjectState, position: (SIMD2<Int>) -> SIMD3<Float>) {
        guard let movement = state.movement, movement.path.count >= 2 else {
            return nil
        }

        let path = movement.path
        let progress = MapObjectMovementPathProgress(
            path: path,
            speed: state.object.speed,
            startTime: movement.startTime,
            duration: movement.duration
        )

        self.gridPath = path
        self.worldPath = path.map(position)
        self.stepDurations = progress.stepDurations
        self.startTime = movement.startTime
        self.duration = movement.duration
        self.initialDirection = movement.initialDirection
        self.finalDirection = movement.finalDirection
        self.animationElapsedOffset = movement.animationElapsedOffset
        self.progress = progress
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
                direction: initialDirection,
                totalElapsed: animationElapsedOffset,
                isMoving: true
            )
        }

        if elapsed >= duration {
            return MovementSample(
                worldPosition: worldPath.last ?? logicalWorldPosition,
                direction: finalDirection,
                totalElapsed: duration,
                isMoving: false
            )
        }

        if let step = progress.activeStep(at: now) {
            let stepElapsed = step.elapsed - step.accumulated
            let stepSeconds = max(step.stepDuration.timeInterval, .leastNonzeroMagnitude)
            let fraction = Float(min(max(stepElapsed.timeInterval / stepSeconds, 0), 1))
            let source = worldPath[step.index]
            let target = worldPath[step.index + 1]
            let direction = SpriteDirection(
                sourcePosition: gridPath[step.index],
                targetPosition: gridPath[step.index + 1]
            )

            return MovementSample(
                worldPosition: mix(source, target, t: fraction),
                direction: direction,
                totalElapsed: elapsed + animationElapsedOffset,
                isMoving: true
            )
        }

        return MovementSample(
            worldPosition: worldPath.last ?? logicalWorldPosition,
            direction: finalDirection,
            totalElapsed: duration,
            isMoving: false
        )
    }
}

extension MapObjectMovementState {
    func nextPosition(speed: Int, at now: ContinuousClock.Instant) -> SIMD2<Int>? {
        guard path.count >= 2 else {
            return nil
        }

        if startTime.duration(to: now) <= .zero {
            return path[1]
        }

        let progress = MapObjectMovementPathProgress(
            path: path,
            speed: speed,
            startTime: startTime,
            duration: duration,
        )
        guard let step = progress.activeStep(at: now) else {
            return nil
        }

        return path[step.index + 1]
    }
}
