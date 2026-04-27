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
        existingSpeed: Int?,
        incomingStartPosition: SIMD2<Int>,
        incomingEndPosition: SIMD2<Int>,
        incomingSpeed: Int,
        at now: ContinuousClock.Instant
    ) -> MapObjectMovementState {
        let incomingPath = findPath(incomingStartPosition, incomingEndPosition)
        let fallbackAnimationElapsedOffset = if let existingMovement {
            existingMovement.animationElapsedOffset + existingMovement.startTime.duration(to: now)
        } else {
            Duration.zero
        }
        let fallbackDuration = movementDuration(path: incomingPath, speed: incomingSpeed)
        let fallbackMovement = MapObjectMovementState(
            startPosition: incomingStartPosition,
            endPosition: incomingEndPosition,
            path: incomingPath,
            startTime: now,
            duration: fallbackDuration,
            animationElapsedOffset: fallbackAnimationElapsedOffset
        )

        guard let existingMovement,
              let existingSpeed,
              let nextPosition = existingMovement.nextPosition(speed: existingSpeed, at: now) else {
            return fallbackMovement
        }

        let suffixPath = findPath(nextPosition, incomingEndPosition)
        guard !suffixPath.isEmpty else {
            return fallbackMovement
        }

        let prefixPath = Array(existingMovement.path.prefix { $0 != nextPosition }) + [nextPosition]
        let fullPath = prefixPath + Array(suffixPath.dropFirst())
        let duration = movementDuration(path: fullPath, speed: incomingSpeed)

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
        var total: Duration = .zero
        for index in 1..<path.count {
            let direction = SpriteDirection(sourcePosition: path[index - 1], targetPosition: path[index])
            let stepMilliseconds = direction.isDiagonal ? Int((Double(speed) * sqrt(2)).rounded()) : speed
            total += .milliseconds(stepMilliseconds)
        }
        return total
    }
}
