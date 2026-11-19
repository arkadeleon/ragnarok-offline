//
//  MapObjectMovement.swift
//  RagnarokGame
//
//  Created by Leon Li on 2026/5/30.
//

import Foundation
import RagnarokSprite
import simd

/// The time the server takes to walk one cell. A diagonal step takes `speed * 14 / 10`, the same as on the server.
func stepDuration(from sourcePosition: SIMD2<Int>, to targetPosition: SIMD2<Int>, speed: Int) -> TimeInterval {
    let direction = SpriteDirection(sourcePosition: sourcePosition, targetPosition: targetPosition)
    return TimeInterval(direction.isDiagonal ? speed * 14 / 10 : speed) / 1000
}

/// The time it takes to walk from a point to a cell. The point can be between two cells.
func stepDuration(from sourcePoint: SIMD2<Float>, to targetPosition: SIMD2<Int>, speed: Int) -> TimeInterval {
    let sourcePosition = SIMD2<Int>(sourcePoint)
    if SIMD2<Float>(sourcePosition) == sourcePoint {
        return stepDuration(from: sourcePosition, to: targetPosition, speed: speed)
    }

    let distance = simd_distance(sourcePoint, SIMD2<Float>(targetPosition))
    return TimeInterval(distance) * TimeInterval(speed) / 1000
}

struct MapObjectMovement: Sendable {
    struct Location: Sendable {
        /// The cell the object is leaving. Like on the server, the object is not in the next cell until it gets there.
        let position: SIMD2<Int>

        /// The exact position on the grid. It can be between two cells.
        let point: SIMD2<Float>
    }

    private struct Step {
        /// The index of the waypoint the object is walking to.
        let index: Int
        let source: MapObjectMovement.Location
        let targetPosition: SIMD2<Int>

        /// How much of the step is done, from 0 to 1.
        let fraction: Float
    }

    let origin: MapObjectMovement.Location
    let waypoints: [SIMD2<Int>]

    let stepDurations: [TimeInterval]
    let startTime: TimeInterval
    let animationElapsedOffset: TimeInterval

    private(set) var currentLocation: MapObjectMovement.Location
    private(set) var direction: SpriteDirection?
    private(set) var animationElapsedTime: TimeInterval = 0
    private(set) var isMoving = false

    var endPosition: SIMD2<Int> {
        waypoints.last ?? origin.position
    }

    var duration: TimeInterval {
        stepDurations.reduce(0, +)
    }

    var finalDirection: SpriteDirection? {
        guard let targetPosition = waypoints.last else {
            return nil
        }

        let sourcePoint = waypoints.count >= 2 ? SIMD2<Float>(waypoints[waypoints.count - 2]) : origin.point
        return SpriteDirection(sourcePosition: sourcePoint, targetPosition: SIMD2<Float>(targetPosition))
    }

    init(
        origin: MapObjectMovement.Location,
        waypoints: [SIMD2<Int>],
        stepDurations: [TimeInterval],
        startTime: TimeInterval,
        animationElapsedOffset: TimeInterval
    ) {
        self.origin = origin
        self.waypoints = waypoints
        self.stepDurations = stepDurations
        self.startTime = startTime
        self.animationElapsedOffset = animationElapsedOffset
        self.currentLocation = origin
    }

    /// Returns this walk, but ending at `position`. The timing of each step stays the same.
    /// Returns `nil` if the object does not walk into `position` after `time`.
    func truncated(to position: SIMD2<Int>, atTime time: TimeInterval) -> MapObjectMovement? {
        guard let step = step(atTime: time), let index = waypoints[step.index...].firstIndex(of: position) else {
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

    mutating func update(atTime time: TimeInterval) {
        if let step = step(atTime: time) {
            let point = mix(step.source.point, SIMD2<Float>(step.targetPosition), t: step.fraction)
            currentLocation = MapObjectMovement.Location(position: step.source.position, point: point)
            direction = SpriteDirection(sourcePosition: step.source.point, targetPosition: SIMD2<Float>(step.targetPosition))
            animationElapsedTime = max(time - startTime, 0) + animationElapsedOffset
            isMoving = true
        } else {
            currentLocation = MapObjectMovement.Location(position: endPosition, point: SIMD2<Float>(endPosition))
            direction = nil
            animationElapsedTime = 0
            isMoving = false
        }
    }

    func location(atTime time: TimeInterval) -> MapObjectMovement.Location? {
        guard let step = step(atTime: time) else {
            return nil
        }

        let point = mix(step.source.point, SIMD2<Float>(step.targetPosition), t: step.fraction)
        return MapObjectMovement.Location(position: step.source.position, point: point)
    }

    /// The cells the object has not reached yet, starting with the cell it is walking to.
    func upcomingPositions(atTime time: TimeInterval) -> ArraySlice<SIMD2<Int>> {
        guard let step = step(atTime: time) else {
            return []
        }

        return waypoints[step.index...]
    }

    func remainingDuration(atTime time: TimeInterval) -> TimeInterval {
        let elapsedTime = max(time - startTime, 0)
        return max(duration - elapsedTime, 0)
    }

    private func step(atTime time: TimeInterval) -> MapObjectMovement.Step? {
        let elapsedTime = time - startTime
        guard !waypoints.isEmpty, elapsedTime < duration else {
            return nil
        }

        var index = 0
        var fraction: Float = 0
        if elapsedTime > 0 {
            var accumulatedTime: TimeInterval = 0
            while index < stepDurations.count && elapsedTime >= accumulatedTime + stepDurations[index] {
                accumulatedTime += stepDurations[index]
                index += 1
            }
            guard index < stepDurations.count else {
                return nil
            }
            fraction = Float((elapsedTime - accumulatedTime) / stepDurations[index])
        }

        let source = if index == 0 {
            origin
        } else {
            MapObjectMovement.Location(position: waypoints[index - 1], point: SIMD2<Float>(waypoints[index - 1]))
        }

        return MapObjectMovement.Step(index: index, source: source, targetPosition: waypoints[index], fraction: fraction)
    }
}
