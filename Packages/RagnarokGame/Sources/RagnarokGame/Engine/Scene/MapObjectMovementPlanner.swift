//
//  MapObjectMovementPlanner.swift
//  RagnarokGame
//
//  Created by Leon Li on 2026/5/30.
//

import Foundation
import simd

struct MapObjectMovementPlanner {
    func replan(
        existingMovement: MapObjectMovement?,
        currentPosition: SIMD2<Int>,
        incomingStartTime: TimeInterval,
        incomingStartPosition: SIMD2<Int>,
        incomingEndPosition: SIMD2<Int>,
        speed: Int,
        pathFinder: PathFinder,
        atTime currentTime: TimeInterval
    ) -> MapObjectMovement {
        let incomingPath = movementPath(from: incomingStartPosition, to: incomingEndPosition, pathFinder: pathFinder)
        let incomingDuration = movementDuration(path: incomingPath, speed: speed)
        let arrivalTime = startTime(incomingStartTime, duration: incomingDuration, atTime: currentTime) + incomingDuration

        var origin = MapObjectMovement.Location(position: currentPosition, point: SIMD2<Float>(currentPosition))
        var animationElapsedOffset: TimeInterval = 0
        if let existingMovement {
            if let location = existingMovement.location(atTime: currentTime) {
                origin = location
                animationElapsedOffset = existingMovement.animationElapsedOffset + (currentTime - existingMovement.startTime)
            } else {
                let endPosition = existingMovement.endPosition
                origin = MapObjectMovement.Location(position: endPosition, point: SIMD2<Float>(endPosition))
            }
        }

        var waypoints = incomingPath
        let startOffset = abs(SIMD2<Float>(incomingStartPosition) - origin.point)
        if max(startOffset.x, startOffset.y) > 1 {
            let nearestPosition = SIMD2<Int>(origin.point.rounded(.toNearestOrAwayFromZero))
            let nearestOffset = incomingStartPosition &- nearestPosition
            let isNearStart = max(abs(nearestOffset.x), abs(nearestOffset.y)) <= 16
            let nearestPath = isNearStart ? pathFinder.findPath(from: nearestPosition, to: incomingEndPosition) : []
            if nearestPath.isEmpty {
                origin = MapObjectMovement.Location(position: incomingStartPosition, point: SIMD2<Float>(incomingStartPosition))
            } else {
                waypoints = nearestPath.count > 1 ? Array(nearestPath.dropFirst()) : nearestPath
            }
        } else {
            while waypoints.count >= 2 {
                let sourcePoint = SIMD2<Float>(waypoints[0])
                let targetPoint = SIMD2<Float>(waypoints[1])
                guard simd_dot(origin.point - sourcePoint, targetPoint - sourcePoint) > 0 else {
                    break
                }
                waypoints.removeFirst()
            }
        }

        if let firstWaypoint = waypoints.first, origin.point == SIMD2<Float>(firstWaypoint) {
            origin = MapObjectMovement.Location(position: firstWaypoint, point: origin.point)
            waypoints.removeFirst()
        }

        let stepDurations = fixedStepDurations(
            origin: origin,
            waypoints: waypoints,
            speed: speed,
            arrivalTime: arrivalTime,
            atTime: currentTime
        )

        return MapObjectMovement(
            origin: origin,
            waypoints: waypoints,
            stepDurations: stepDurations,
            startTime: currentTime,
            animationElapsedOffset: animationElapsedOffset
        )
    }

    /// Returns a short walk from where the object is at `time` to `position`, the cell where the server stopped it.
    /// Returns `nil` if there is no walk or it is over, or if `position` is where the object already is or more than 1 cell away.
    func stop(
        existingMovement: MapObjectMovement?,
        on position: SIMD2<Int>,
        speed: Int,
        atTime time: TimeInterval
    ) -> MapObjectMovement? {
        guard let existingMovement, let origin = existingMovement.location(atTime: time) else {
            return nil
        }

        let delta = abs(SIMD2<Float>(position) - origin.point)
        guard delta != .zero && max(delta.x, delta.y) <= 1 else {
            return nil
        }

        return MapObjectMovement(
            origin: MapObjectMovement.Location(position: position, point: origin.point),
            waypoints: [position],
            stepDurations: [stepDuration(from: origin.point, to: position, speed: speed)],
            startTime: time,
            animationElapsedOffset: existingMovement.animationElapsedOffset + (time - existingMovement.startTime)
        )
    }

    func movementDuration(path: [SIMD2<Int>], speed: Int) -> TimeInterval {
        guard path.count >= 2 else {
            return 0
        }

        var total: TimeInterval = 0
        for index in 1..<path.count {
            total += stepDuration(from: path[index - 1], to: path[index], speed: speed)
        }
        return total
    }

    private func startTime(
        _ incomingStartTime: TimeInterval,
        duration: TimeInterval,
        atTime currentTime: TimeInterval
    ) -> TimeInterval {
        let elapsedTime = currentTime - incomingStartTime
        guard elapsedTime > 0 && elapsedTime <= duration * 4 else {
            return currentTime
        }

        return currentTime - min(elapsedTime, duration)
    }

    private func fixedStepDurations(
        origin: MapObjectMovement.Location,
        waypoints: [SIMD2<Int>],
        speed: Int,
        arrivalTime: TimeInterval,
        atTime currentTime: TimeInterval
    ) -> [TimeInterval] {
        guard !waypoints.isEmpty else {
            return []
        }

        let stepDurations = waypoints.indices.map { index in
            if index == 0 {
                stepDuration(from: origin.point, to: waypoints[0], speed: speed)
            } else {
                stepDuration(from: waypoints[index - 1], to: waypoints[index], speed: speed)
            }
        }

        let totalDuration = stepDurations.reduce(0, +)
        let difference = min(max((arrivalTime - currentTime) - totalDuration, -2.5), 2.5)
        let adjustment = difference / TimeInterval(stepDurations.count)

        return stepDurations.map { stepDuration in
            max(stepDuration + adjustment, 0.01)
        }
    }

    private func movementPath(from startPosition: SIMD2<Int>, to endPosition: SIMD2<Int>, pathFinder: PathFinder) -> [SIMD2<Int>] {
        let path = pathFinder.findPath(from: startPosition, to: endPosition)
        if !path.isEmpty {
            return path
        }

        if startPosition == endPosition {
            return [startPosition]
        } else {
            return fallbackMovementPath(from: startPosition, to: endPosition)
        }
    }

    private func fallbackMovementPath(from startPosition: SIMD2<Int>, to endPosition: SIMD2<Int>) -> [SIMD2<Int>] {
        var path = [startPosition]
        var currentPosition = startPosition

        while currentPosition != endPosition {
            let delta = endPosition &- currentPosition
            currentPosition.x += delta.x.signum()
            currentPosition.y += delta.y.signum()
            path.append(currentPosition)
        }

        return path
    }
}
