//
//  MapObjectMovement.swift
//  RagnarokGame
//
//  Created by Leon Li on 2026/5/30.
//

import RagnarokSprite
import simd

public struct MapObjectMovement: Sendable {
    public struct Step: Sendable {
        public let sourcePosition: SIMD2<Int>
        public let targetPosition: SIMD2<Int>
        public let fraction: Float
    }

    public let startPosition: SIMD2<Int>
    public let endPosition: SIMD2<Int>
    public let path: [SIMD2<Int>]
    public let startTime: ContinuousClock.Instant
    public let duration: Duration
    public let speed: Int
    public let animationElapsedOffset: Duration

    public private(set) var currentPosition: SIMD2<Int>
    public private(set) var currentStep: MapObjectMovement.Step?
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
            SpriteDirection(sourcePosition: path[0], targetPosition: path[1])
        } else {
            SpriteDirection(sourcePosition: startPosition, targetPosition: endPosition)
        }
    }

    var finalDirection: SpriteDirection {
        if path.count >= 2 {
            SpriteDirection(sourcePosition: path[path.count - 2], targetPosition: path[path.count - 1])
        } else {
            SpriteDirection(sourcePosition: startPosition, targetPosition: endPosition)
        }
    }

    func remainingDuration(at now: ContinuousClock.Instant) -> Duration {
        let elapsed = max(startTime.duration(to: now), .zero)
        return max(duration - elapsed, .zero)
    }

    mutating func update(atTime time: ContinuousClock.Instant) {
        guard path.count >= 2 else {
            finish()
            return
        }

        let elapsed = startTime.duration(to: time)
        if elapsed <= .zero {
            currentPosition = path[0]
            currentStep = nil
            direction = initialDirection
            animationElapsedTime = animationElapsedOffset
            isMoving = true
            return
        }

        if elapsed >= duration {
            finish()
            return
        }

        let progress = MovementPathProgress(
            path: path,
            speed: speed,
            startTime: startTime,
            duration: duration
        )
        guard let step = progress.activeStep(at: time) else {
            finish()
            return
        }

        let stepElapsed = step.elapsed - step.accumulated
        let stepSeconds = max(step.stepDuration.timeInterval, .leastNonzeroMagnitude)
        let fraction = Float(min(max(stepElapsed.timeInterval / stepSeconds, 0), 1))
        let sourcePosition = path[step.index]
        let targetPosition = path[step.index + 1]

        currentPosition = sourcePosition
        currentStep = MapObjectMovement.Step(
            sourcePosition: sourcePosition,
            targetPosition: targetPosition,
            fraction: fraction
        )
        direction = SpriteDirection(sourcePosition: sourcePosition, targetPosition: targetPosition)
        animationElapsedTime = elapsed + animationElapsedOffset
        isMoving = true
    }

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

        let progress = MovementPathProgress(
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

    private mutating func finish() {
        currentPosition = path.last ?? startPosition
        currentStep = nil
        direction = nil
        animationElapsedTime = .zero
        isMoving = false
    }
}

private struct MovementPathProgress {
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

    func activeStep(at now: ContinuousClock.Instant) -> MovementPathProgress.ActiveStep? {
        let elapsed = startTime.duration(to: now)
        guard elapsed > .zero, elapsed < duration else {
            return nil
        }

        var accumulated: Duration = .zero
        for index in stepDurations.indices {
            let stepDuration = stepDurations[index]
            let nextAccumulated = accumulated + stepDuration

            if elapsed < nextAccumulated {
                return MovementPathProgress.ActiveStep(
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
