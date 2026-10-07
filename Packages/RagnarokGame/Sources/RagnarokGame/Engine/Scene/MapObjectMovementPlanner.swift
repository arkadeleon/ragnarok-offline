//
//  MapObjectMovementPlanner.swift
//  RagnarokGame
//
//  Created by Leon Li on 2026/5/30.
//

import RagnarokSprite
import simd

struct MapObjectMovementPlanner {
    private let findPath: (SIMD2<Int>, SIMD2<Int>) -> [SIMD2<Int>]

    init(pathFinder: PathFinder) {
        self.init { startPosition, endPosition in
            pathFinder.findPath(from: startPosition, to: endPosition)
        }
    }

    init(findPath: @escaping (SIMD2<Int>, SIMD2<Int>) -> [SIMD2<Int>]) {
        self.findPath = findPath
    }

    func replan(
        existingMovement: MapObjectMovement?,
        incomingStartTime: ContinuousClock.Instant,
        incomingStartPosition: SIMD2<Int>,
        incomingEndPosition: SIMD2<Int>,
        speed: Int,
        at now: ContinuousClock.Instant
    ) -> MapObjectMovement {
        let incomingPath = movementPath(from: incomingStartPosition, to: incomingEndPosition)
        let fallbackAnimationElapsedOffset = if let existingMovement {
            existingMovement.animationElapsedOffset + existingMovement.startTime.duration(to: now)
        } else {
            Duration.zero
        }
        let fallbackDuration = movementDuration(path: incomingPath, speed: speed)
        let fallbackMovement = MapObjectMovement(
            startPosition: incomingStartPosition,
            endPosition: incomingEndPosition,
            path: incomingPath,
            startTime: startTime(incomingStartTime, duration: fallbackDuration, at: now),
            duration: fallbackDuration,
            speed: speed,
            animationElapsedOffset: fallbackAnimationElapsedOffset
        )

        guard let existingMovement else {
            return fallbackMovement
        }

        guard let nextStep = existingMovement.nextStep(at: now) else {
            return fallbackMovement
        }

        let nextPosition = nextStep.position
        let suffixPath = movementPath(from: nextPosition, to: incomingEndPosition)
        let prefixPath = Array(existingMovement.path.prefix(nextStep.index + 1))
        let fullPath = prefixPath + Array(suffixPath.dropFirst())
        let duration = movementDuration(path: fullPath, speed: speed)

        return MapObjectMovement(
            startPosition: existingMovement.startPosition,
            endPosition: incomingEndPosition,
            path: fullPath,
            startTime: existingMovement.startTime,
            duration: duration,
            speed: speed,
            animationElapsedOffset: existingMovement.animationElapsedOffset
        )
    }

    func movementDuration(path: [SIMD2<Int>], speed: Int) -> Duration {
        guard path.count >= 2 else {
            return .zero
        }

        var total: Duration = .zero
        for index in 1..<path.count {
            total += stepDuration(from: path[index - 1], to: path[index], speed: speed)
        }
        return total
    }

    private func startTime(
        _ incomingStartTime: ContinuousClock.Instant,
        duration: Duration,
        at now: ContinuousClock.Instant
    ) -> ContinuousClock.Instant {
        let elapsed = incomingStartTime.duration(to: now)
        guard elapsed > .zero && elapsed <= duration * 4 else {
            return now
        }

        return now - min(elapsed, duration)
    }

    private func movementPath(from startPosition: SIMD2<Int>, to endPosition: SIMD2<Int>) -> [SIMD2<Int>] {
        let path = findPath(startPosition, endPosition)
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
