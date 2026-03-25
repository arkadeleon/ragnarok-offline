//
//  SpriteBillboardSnapshotEvaluator.swift
//  RagnarokGame
//
//  Created by Leon Li on 2026/3/25.
//

#if os(iOS) || os(macOS)

import Foundation
import RagnarokModels
import RagnarokSprite
import simd

@MainActor
final class SpriteBillboardSnapshotEvaluator {
    private struct MovementSample {
        var worldPosition: SIMD3<Float>
        var direction: CharacterDirection
        var totalElapsed: Duration
        var isMoving: Bool
    }

    func evaluate(
        player: MapObjectState,
        objects: [UInt32 : MapObjectState],
        items: [UInt32 : MapItemState],
        scene: MapScene
    ) -> [UInt32 : SpriteBillboardSnapshot] {
        let now = ContinuousClock.now
        var snapshots: [UInt32 : SpriteBillboardSnapshot] = [:]

        snapshots[player.id] = snapshot(
            for: player,
            now: now,
            scene: scene
        )

        for (objectID, objectState) in objects {
            snapshots[objectID] = snapshot(
                for: objectState,
                now: now,
                scene: scene
            )
        }

        for (itemID, itemState) in items {
            snapshots[itemID] = SpriteBillboardSnapshot(
                objectID: itemID,
                worldPosition: scene.position(for: itemState.gridPosition),
                isVisible: true,
                content: .item(itemState.item)
            )
        }

        return snapshots
    }

    private func snapshot(
        for state: MapObjectState,
        now: ContinuousClock.Instant,
        scene: MapScene
    ) -> SpriteBillboardSnapshot {
        let movementSample = movementSample(for: state, now: now, scene: scene)
        let worldPosition = movementSample?.worldPosition ?? scene.position(for: state.gridPosition)
        let (requestedAnimationKey, animationElapsed) = resolvedAnimation(
            for: state,
            movementSample: movementSample,
            now: now
        )

        let visualAnimationKey = SpriteBillboardAnimationKey(
            action: requestedAnimationKey.action,
            direction: requestedAnimationKey.direction.adjustedForCameraAzimuth(scene.cameraState.azimuth)
        )

        return SpriteBillboardSnapshot(
            objectID: state.id,
            worldPosition: worldPosition,
            isVisible: state.isVisible,
            content: .mapObject(
                mapObject: state.object,
                animationKey: sanitizedAnimationKey(visualAnimationKey, for: state.object),
                animationElapsed: animationElapsed
            )
        )
    }

    private func resolvedAnimation(
        for state: MapObjectState,
        movementSample: MovementSample?,
        now: ContinuousClock.Instant
    ) -> (SpriteBillboardAnimationKey, Duration) {
        if let movementSample, movementSample.isMoving {
            return (
                SpriteBillboardAnimationKey(action: .walk, direction: movementSample.direction),
                movementSample.totalElapsed
            )
        }

        let presentation = state.presentation
        let elapsed = presentation.startedAt.duration(to: now)
        if let duration = presentation.duration, elapsed >= duration {
            let settledAction = settledAction(
                after: presentation.action,
                for: state.object
            )
            return (
                SpriteBillboardAnimationKey(action: settledAction, direction: presentation.direction),
                elapsed - duration
            )
        }

        return (
            SpriteBillboardAnimationKey(action: presentation.action, direction: presentation.direction),
            elapsed
        )
    }

    private func sanitizedAnimationKey(
        _ key: SpriteBillboardAnimationKey,
        for mapObject: MapObject
    ) -> SpriteBillboardAnimationKey {
        let availableActionTypes = CharacterActionType.availableActionTypes(forJobID: mapObject.job)
        guard availableActionTypes.contains(key.action) else {
            return SpriteBillboardAnimationKey(action: .idle, direction: key.direction)
        }
        return key
    }

    private func settledAction(
        after action: CharacterActionType,
        for mapObject: MapObject
    ) -> CharacterActionType {
        switch action {
        case .sit:
            return .sit
        case .attack1, .attack2, .attack3, .skill:
            let availableActionTypes = CharacterActionType.availableActionTypes(forJobID: mapObject.job)
            return availableActionTypes.contains(.readyToAttack) ? .readyToAttack : .idle
        case .freeze, .freeze2, .die:
            return action
        case .idle, .walk, .pickup, .readyToAttack, .hurt:
            return .idle
        }
    }

    private func movementSample(
        for state: MapObjectState,
        now: ContinuousClock.Instant,
        scene: MapScene
    ) -> MovementSample? {
        guard let movement = state.movement, movement.path.count >= 2 else {
            return nil
        }

        let elapsed = movement.startedAt.duration(to: now)
        if elapsed <= .zero {
            return MovementSample(
                worldPosition: scene.position(for: movement.path[0]),
                direction: movement.direction,
                totalElapsed: .zero,
                isMoving: true
            )
        }

        if elapsed >= movement.duration {
            return MovementSample(
                worldPosition: scene.position(for: movement.to),
                direction: movement.direction,
                totalElapsed: movement.duration,
                isMoving: false
            )
        }

        var accumulated: Duration = .zero
        for index in 1..<movement.path.count {
            let source = movement.path[index - 1]
            let target = movement.path[index]
            let direction = CharacterDirection(sourcePosition: source, targetPosition: target)
            let stepDuration = duration(forStepFrom: source, to: target, speed: state.object.speed)
            let nextAccumulated = accumulated + stepDuration

            if elapsed < nextAccumulated {
                let stepElapsed = elapsed - accumulated
                let stepSeconds = max(seconds(stepDuration), .leastNonzeroMagnitude)
                let fraction = Float(min(max(seconds(stepElapsed) / stepSeconds, 0), 1))
                let sourceWorldPosition = scene.position(for: source)
                let targetWorldPosition = scene.position(for: target)

                return MovementSample(
                    worldPosition: mix(sourceWorldPosition, targetWorldPosition, t: fraction),
                    direction: direction,
                    totalElapsed: elapsed,
                    isMoving: true
                )
            }

            accumulated = nextAccumulated
        }

        return MovementSample(
            worldPosition: scene.position(for: movement.to),
            direction: movement.direction,
            totalElapsed: movement.duration,
            isMoving: false
        )
    }

    private func duration(
        forStepFrom source: SIMD2<Int>,
        to target: SIMD2<Int>,
        speed: Int
    ) -> Duration {
        let direction = CharacterDirection(sourcePosition: source, targetPosition: target)
        let stepMilliseconds = direction.isDiagonal ? Int((Double(speed) * sqrt(2)).rounded()) : speed
        return .milliseconds(stepMilliseconds)
    }

    private func seconds(_ duration: Duration) -> Double {
        let components = duration.components
        return Double(components.seconds) + Double(components.attoseconds) / 1_000_000_000_000_000_000
    }
}

#endif
