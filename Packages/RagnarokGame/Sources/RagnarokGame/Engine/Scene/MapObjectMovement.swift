//
//  MapObjectMovement.swift
//  RagnarokGame
//
//  Created by Leon Li on 2026/5/30.
//

import RagnarokSprite
import simd

/// The time the server takes to walk one cell. A diagonal step takes `speed * 14 / 10`, the same as on the server.
func stepDuration(from sourcePosition: SIMD2<Int>, to targetPosition: SIMD2<Int>, speed: Int) -> Duration {
    let direction = SpriteDirection(sourcePosition: sourcePosition, targetPosition: targetPosition)
    return .milliseconds(direction.isDiagonal ? speed * 14 / 10 : speed)
}

/// The time it takes to walk from a point to a cell. The point can be between two cells.
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
        /// The cell the object is leaving. Like on the server, the object is not in the next cell until it gets there.
        public let position: SIMD2<Int>

        /// The exact position on the grid. It can be between two cells.
        public let point: SIMD2<Float>
    }

    private struct Step {
        /// The index of the waypoint the object is walking to.
        let index: Int
        let source: MapObjectMovement.Location
        let targetPosition: SIMD2<Int>

        /// How much of the step is done, from 0 to 1.
        let fraction: Float
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

    var finalDirection: SpriteDirection? {
        guard let targetPosition = waypoints.last else {
            return nil
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

        let point = mix(step.source.point, SIMD2<Float>(step.targetPosition), t: step.fraction)
        return MapObjectMovement.Location(position: step.source.position, point: point)
    }

    /// Returns a short walk from where the object is at `time` to `position`, the cell where the server stopped it.
    /// Returns `nil` if the walk is over, or if `position` is where the object already is or more than 1 cell away.
    func stopped(on position: SIMD2<Int>, speed: Int, at time: ContinuousClock.Instant) -> MapObjectMovement? {
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

    /// Returns this walk, but ending at `position`. The timing of each step stays the same.
    /// Returns `nil` if the object does not walk into `position` after `time`.
    func truncated(to position: SIMD2<Int>, at time: ContinuousClock.Instant) -> MapObjectMovement? {
        guard let step = step(at: time), let index = waypoints[step.index...].firstIndex(of: position) else {
            return nil
        }

        return MapObjectMovement(
            origin: origin,
            waypoints: Array(waypoints[...index]),
            stepDurations: Array(stepDurations[...index]),
            startTime: startTime,
            animationElapsedOffset: animationElapsedOffset
        )
    }

    /// The cells the object has not reached yet, starting with the cell it is walking to.
    func upcomingPositions(at time: ContinuousClock.Instant) -> ArraySlice<SIMD2<Int>> {
        guard let step = step(at: time) else {
            return []
        }

        return waypoints[step.index...]
    }

    func nextPosition(at time: ContinuousClock.Instant) -> SIMD2<Int>? {
        step(at: time)?.targetPosition
    }

    mutating func update(at time: ContinuousClock.Instant) {
        if let step = step(at: time) {
            let point = mix(step.source.point, SIMD2<Float>(step.targetPosition), t: step.fraction)
            currentLocation = MapObjectMovement.Location(position: step.source.position, point: point)
            direction = SpriteDirection(sourcePosition: step.source.point, targetPosition: SIMD2<Float>(step.targetPosition))
            animationElapsedTime = max(startTime.duration(to: time), .zero) + animationElapsedOffset
            isMoving = true
        } else {
            currentLocation = MapObjectMovement.Location(position: endPosition, point: SIMD2<Float>(endPosition))
            direction = nil
            animationElapsedTime = .zero
            isMoving = false
        }
    }

    private func step(at time: ContinuousClock.Instant) -> MapObjectMovement.Step? {
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

        let source = if index == 0 {
            origin
        } else {
            MapObjectMovement.Location(position: waypoints[index - 1], point: SIMD2<Float>(waypoints[index - 1]))
        }

        return MapObjectMovement.Step(index: index, source: source, targetPosition: waypoints[index], fraction: fraction)
    }
}
