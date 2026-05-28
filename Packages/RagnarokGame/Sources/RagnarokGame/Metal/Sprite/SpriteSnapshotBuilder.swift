//
//  SpriteSnapshotBuilder.swift
//  RagnarokGame
//
//  Created by Leon Li on 2026/3/25.
//

import Foundation
import RagnarokModels
import RagnarokSprite

@MainActor
final class SpriteSnapshotBuilder {
    func build(
        objects: inout [GameObjectID : MetalMapObjectState],
        items: [GameObjectID : MapSceneItem],
        scene: MapScene
    ) -> [GameObjectID : SpriteSnapshot] {
        let now = ContinuousClock.now

        var snapshots: [GameObjectID : SpriteSnapshot] = [:]

        for objectID in Array(objects.keys) {
            guard var objectState = objects[objectID] else {
                continue
            }

            objectState.animation.update(atTime: now)
            if var movement = objectState.movement {
                movement.update(atTime: now)
                objectState.gridPosition = movement.currentPosition
                objectState.movement = movement
            }
            snapshots[objectID] = snapshot(for: objectState, now: now, scene: scene)
            objects[objectID] = objectState
        }

        for (objectID, item) in items {
            snapshots[objectID] = snapshot(for: item, scene: scene)
        }

        return snapshots
    }

    private func snapshot(for objectState: MetalMapObjectState, now: ContinuousClock.Instant, scene: MapScene) -> SpriteSnapshot {
        let object = objectState.object
        let movement = objectState.movement
        let worldPosition = if let movement, movement.isMoving, let movementWorldPosition = movement.worldPosition {
            movementWorldPosition
        } else {
            scene.mapGrid.worldPosition(for: objectState.gridPosition)
        }

        let availableActionTypes = SpriteActionType.availableActionTypes(forJobID: object.job)

        var animation = objectState.animation
        if let movement, movement.isMoving {
            animation.action = .walk
            animation.direction = movement.direction ?? animation.direction
            animation.elapsedTime = movement.animationElapsedTime
            animation.completion = .indefinite
        }
        animation.direction = animation.direction.adjustedForCameraAzimuth(scene.cameraState.azimuth)
        if !availableActionTypes.contains(animation.action) {
            animation.action = .idle
        }

        return SpriteSnapshot(
            objectID: object.objectID,
            worldPosition: worldPosition,
            isVisible: object.effectState != .cloak,
            content: .mapObject(configuration: ComposedSprite.Configuration(object: object), animation: animation)
        )
    }

    private func snapshot(for item: MapSceneItem, scene: MapScene) -> SpriteSnapshot {
        SpriteSnapshot(
            objectID: item.objectID,
            worldPosition: scene.mapGrid.worldPosition(for: item.gridPosition),
            isVisible: true,
            content: .mapItem(itemID: item.itemID)
        )
    }
}
