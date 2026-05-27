//
//  MapObjectMovementPlanner.swift
//  RagnarokGame
//
//  Created by Leon Li on 2026/4/24.
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
        existingMovement: MapObjectMovementState?,
        incomingStartPosition: SIMD2<Int>,
        incomingEndPosition: SIMD2<Int>,
        speed: Int,
        at now: ContinuousClock.Instant
    ) -> MapObjectMovementState {
        let incomingPath = movementPath(from: incomingStartPosition, to: incomingEndPosition)
        let fallbackAnimationElapsedOffset = if let existingMovement {
            existingMovement.animationElapsedOffset + existingMovement.startTime.duration(to: now)
        } else {
            Duration.zero
        }
        let fallbackDuration = movementDuration(path: incomingPath, speed: speed)
        let fallbackMovement = MapObjectMovementState(
            startPosition: incomingStartPosition,
            endPosition: incomingEndPosition,
            path: incomingPath,
            startTime: now,
            duration: fallbackDuration,
            animationElapsedOffset: fallbackAnimationElapsedOffset
        )

        guard let existingMovement,
              let nextPosition = existingMovement.nextPosition(speed: speed, at: now) else {
            return fallbackMovement
        }

        let suffixPath = movementPath(from: nextPosition, to: incomingEndPosition)
        let prefixPath = Array(existingMovement.path.prefix { $0 != nextPosition }) + [nextPosition]
        let fullPath = prefixPath + Array(suffixPath.dropFirst())
        let duration = movementDuration(path: fullPath, speed: speed)

        return MapObjectMovementState(
            startPosition: existingMovement.startPosition,
            endPosition: incomingEndPosition,
            path: fullPath,
            startTime: existingMovement.startTime,
            duration: duration,
            animationElapsedOffset: existingMovement.animationElapsedOffset
        )
    }

    func movementDuration(path: [SIMD2<Int>], speed: Int) -> Duration {
        guard path.count >= 2 else {
            return .zero
        }

        var total: Duration = .zero
        for index in 1..<path.count {
            let direction = SpriteDirection(sourcePosition: path[index - 1], targetPosition: path[index])
            let stepMilliseconds = direction.isDiagonal ? Int((Double(speed) * sqrt(2)).rounded()) : speed
            total += .milliseconds(stepMilliseconds)
        }
        return total
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
