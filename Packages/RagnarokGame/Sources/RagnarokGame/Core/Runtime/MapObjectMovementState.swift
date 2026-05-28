//
//  MapObjectMovementState.swift
//  RagnarokGame
//
//  Created by Leon Li on 2026/3/24.
//

import RagnarokSprite
import simd

public struct MapObjectMovementState: Sendable {
    public let startPosition: SIMD2<Int>
    public let endPosition: SIMD2<Int>
    public let path: [SIMD2<Int>]
    public let startTime: ContinuousClock.Instant
    public let duration: Duration
    public let speed: Int
    public let animationElapsedOffset: Duration

    public private(set) var worldPath: [SIMD3<Float>] = []
    public private(set) var currentPosition: SIMD2<Int>
    public private(set) var worldPosition: SIMD3<Float>?
    public private(set) var direction: SpriteDirection?
    public private(set) var animationElapsedTime: Duration = .zero
    public private(set) var isMoving = false

    public init(
        startPosition: SIMD2<Int>,
        endPosition: SIMD2<Int>,
        path: [SIMD2<Int>],
        startTime: ContinuousClock.Instant,
        duration: Duration,
        speed: Int,
        animationElapsedOffset: Duration
    ) {
        self.startPosition = startPosition
        self.endPosition = endPosition
        self.path = path
        self.startTime = startTime
        self.duration = duration
        self.speed = speed
        self.animationElapsedOffset = animationElapsedOffset
        self.currentPosition = path.first ?? startPosition
    }

    var initialDirection: SpriteDirection {
        if path.count >= 2 {
            return SpriteDirection(sourcePosition: path[0], targetPosition: path[1])
        } else {
            return SpriteDirection(sourcePosition: startPosition, targetPosition: endPosition)
        }
    }

    var finalDirection: SpriteDirection {
        if path.count >= 2 {
            return SpriteDirection(sourcePosition: path[path.count - 2], targetPosition: path[path.count - 1])
        } else {
            return SpriteDirection(sourcePosition: startPosition, targetPosition: endPosition)
        }
    }

    func remainingDuration(at now: ContinuousClock.Instant) -> Duration {
        let elapsed = max(startTime.duration(to: now), .zero)
        return max(duration - elapsed, .zero)
    }

    mutating func updateWorldPath(position: (SIMD2<Int>) -> SIMD3<Float>) {
        worldPath = path.map(position)
    }

    mutating func update(atTime time: ContinuousClock.Instant) {
        guard path.count >= 2, worldPath.count == path.count else {
            currentPosition = path[path.count - 1]
            worldPosition = worldPath[worldPath.count - 1]
            direction = nil
            animationElapsedTime = .zero
            isMoving = false
            return
        }

        let elapsed = startTime.duration(to: time)
        if elapsed <= .zero {
            currentPosition = path[0]
            worldPosition = worldPath[0]
            direction = initialDirection
            animationElapsedTime = animationElapsedOffset
            isMoving = true
            return
        }

        if elapsed >= duration {
            currentPosition = path[path.count - 1]
            worldPosition = worldPath[worldPath.count - 1]
            direction = nil
            animationElapsedTime = .zero
            isMoving = false
            return
        }

        let progress = MapObjectMovementPathProgress(
            path: path,
            speed: speed,
            startTime: startTime,
            duration: duration
        )
        guard let step = progress.activeStep(at: time) else {
            currentPosition = path[path.count - 1]
            worldPosition = worldPath[worldPath.count - 1]
            direction = nil
            animationElapsedTime = .zero
            isMoving = false
            return
        }

        let stepElapsed = step.elapsed - step.accumulated
        let stepSeconds = max(step.stepDuration.timeInterval, .leastNonzeroMagnitude)
        let fraction = Float(min(max(stepElapsed.timeInterval / stepSeconds, 0), 1))
        let source = worldPath[step.index]
        let target = worldPath[step.index + 1]
        let direction = SpriteDirection(
            sourcePosition: path[step.index],
            targetPosition: path[step.index + 1]
        )

        currentPosition = path[step.index]
        worldPosition = mix(source, target, t: fraction)
        self.direction = direction
        animationElapsedTime = elapsed + animationElapsedOffset
        isMoving = true
    }
}

extension MapObjectMovementState {
    func nextPosition(at now: ContinuousClock.Instant) -> SIMD2<Int>? {
        nextStep(at: now)?.position
    }

    func nextStep(at now: ContinuousClock.Instant) -> (index: Int, position: SIMD2<Int>)? {
        guard path.count >= 2 else {
            return nil
        }

        if startTime.duration(to: now) <= .zero {
            return (1, path[1])
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

        let nextIndex = step.index + 1
        return (nextIndex, path[nextIndex])
    }
}

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
