//
//  MapObjectMovement.swift
//  RagnarokGame
//
//  Created by Leon Li on 2026/5/30.
//

import RagnarokSprite
import simd

/// How long the server takes to walk one cell. Diagonal steps take `speed * 14 / 10`, matching the server.
func stepDuration(from sourcePosition: SIMD2<Int>, to targetPosition: SIMD2<Int>, speed: Int) -> Duration {
    let direction = SpriteDirection(sourcePosition: sourcePosition, targetPosition: targetPosition)
    return .milliseconds(direction.isDiagonal ? speed * 14 / 10 : speed)
}

/// How long it takes to walk from a point that may lie between cells to a cell.
func stepDuration(from sourcePoint: SIMD2<Float>, to targetPosition: SIMD2<Int>, speed: Int) -> Duration {
    let sourcePosition = SIMD2<Int>(sourcePoint)
    if SIMD2<Float>(sourcePosition) == sourcePoint {
        return stepDuration(from: sourcePosition, to: targetPosition, speed: speed)
    }

    let distance = simd_distance(sourcePoint, SIMD2<Float>(targetPosition))
    return .milliseconds(Double(distance) * Double(speed))
}

public struct MapObjectMovement: Sendable {
    public struct Location: Sendable {
        /// The cell being left. Like the server, an object only enters a cell when it arrives.
        public let position: SIMD2<Int>

        /// The exact position in grid coordinates.
        public let point: SIMD2<Float>
    }

    public let origin: MapObjectMovement.Location
    public let waypoints: [SIMD2<Int>]

    public let stepDurations: [Duration]
    public let startTime: ContinuousClock.Instant
    public let duration: Duration
    public let animationElapsedOffset: Duration

    public private(set) var currentLocation: MapObjectMovement.Location
    public private(set) var direction: SpriteDirection?
    public private(set) var animationElapsedTime: Duration = .zero
    public private(set) var isMoving = false

    public var currentPosition: SIMD2<Int> {
        currentLocation.position
    }

    public var endPosition: SIMD2<Int> {
        waypoints.last ?? origin.position
    }

    var finalDirection: SpriteDirection {
        guard let targetPosition = waypoints.last else {
            return .south
        }

        let sourcePoint = waypoints.count >= 2 ? SIMD2<Float>(waypoints[waypoints.count - 2]) : origin.point
        return SpriteDirection(sourcePosition: sourcePoint, targetPosition: SIMD2<Float>(targetPosition))
    }

    public init(
        origin: MapObjectMovement.Location,
        waypoints: [SIMD2<Int>],
        stepDurations: [Duration],
        startTime: ContinuousClock.Instant,
        animationElapsedOffset: Duration
    ) {
        self.origin = origin
        self.waypoints = waypoints
        self.stepDurations = stepDurations
        self.startTime = startTime
        self.duration = stepDurations.reduce(.zero, +)
        self.animationElapsedOffset = animationElapsedOffset
        self.currentLocation = origin
    }

    func remainingDuration(at now: ContinuousClock.Instant) -> Duration {
        let elapsed = max(startTime.duration(to: now), .zero)
        return max(duration - elapsed, .zero)
    }

    func location(at time: ContinuousClock.Instant) -> MapObjectMovement.Location? {
        guard let step = step(at: time) else {
            return nil
        }

        let point = mix(step.sourcePoint, SIMD2<Float>(step.targetPosition), t: step.fraction)
        return MapObjectMovement.Location(position: step.sourcePosition, point: point)
    }

    /// A short walk to the position the server stopped at, or `nil` if it is more than one cell away.
    func stopped(at position: SIMD2<Int>, speed: Int, at time: ContinuousClock.Instant) -> MapObjectMovement? {
        guard let origin = location(at: time) else {
            return nil
        }

        let delta = abs(SIMD2<Float>(position) - origin.point)
        guard delta != .zero && max(delta.x, delta.y) <= 1 else {
            return nil
        }

        return MapObjectMovement(
            origin: origin,
            waypoints: [position],
            stepDurations: [stepDuration(from: origin.point, to: position, speed: speed)],
            startTime: time,
            animationElapsedOffset: animationElapsedOffset + startTime.duration(to: time)
        )
    }

    func nextPosition(at time: ContinuousClock.Instant) -> SIMD2<Int>? {
        step(at: time)?.targetPosition
    }

    mutating func update(atTime time: ContinuousClock.Instant) {
        guard let step = step(at: time), let location = location(at: time) else {
            currentLocation = MapObjectMovement.Location(position: endPosition, point: SIMD2<Float>(endPosition))
            direction = nil
            animationElapsedTime = .zero
            isMoving = false
            return
        }

        currentLocation = location
        direction = SpriteDirection(sourcePosition: step.sourcePoint, targetPosition: SIMD2<Float>(step.targetPosition))
        animationElapsedTime = max(startTime.duration(to: time), .zero) + animationElapsedOffset
        isMoving = true
    }

    private func step(at time: ContinuousClock.Instant) -> (sourcePosition: SIMD2<Int>, sourcePoint: SIMD2<Float>, targetPosition: SIMD2<Int>, fraction: Float)? {
        let elapsed = startTime.duration(to: time)
        guard !waypoints.isEmpty, elapsed < duration else {
            return nil
        }

        var index = 0
        var fraction: Float = 0
        if elapsed > .zero {
            var accumulated: Duration = .zero
            while index < stepDurations.count && elapsed >= accumulated + stepDurations[index] {
                accumulated += stepDurations[index]
                index += 1
            }
            guard index < stepDurations.count else {
                return nil
            }
            fraction = Float((elapsed - accumulated) / stepDurations[index])
        }

        if index == 0 {
            return (origin.position, origin.point, waypoints[0], fraction)
        } else {
            return (waypoints[index - 1], SIMD2<Float>(waypoints[index - 1]), waypoints[index], fraction)
        }
    }
}
