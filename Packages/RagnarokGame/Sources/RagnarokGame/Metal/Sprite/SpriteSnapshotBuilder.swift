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
        items: [GameObjectID : MetalMapItem],
        scene: MetalMapScene
    ) -> [GameObjectID : SpriteSnapshot] {
        let now = ContinuousClock.now

        var snapshots: [GameObjectID : SpriteSnapshot] = [:]

        for object in scene.objectRegistry.objects.values {
            object.animationController.update(at: now)
            object.movementController.update(at: now)
            if let movement = object.movementController.movement {
                object.gridPosition = movement.currentPosition
            }
            let worldPosition: SIMD3<Float>
            if let movement = object.movementController.movement,
               movement.isMoving,
               let movementWorldPosition = movement.worldPosition {
                worldPosition = movementWorldPosition
            } else {
                worldPosition = scene.mapGrid.worldPosition(for: object.gridPosition)
            }
            object.presentation.worldPosition = worldPosition
            snapshots[object.objectID] = snapshot(for: object, worldPosition: worldPosition, scene: scene)
        }

        for (objectID, item) in items {
            snapshots[objectID] = snapshot(for: item, scene: scene)
        }

        return snapshots
    }

    private func snapshot(for object: MetalMapObject, worldPosition: SIMD3<Float>, scene: MetalMapScene) -> SpriteSnapshot {
        let availableActionTypes = SpriteActionType.availableActionTypes(forJobID: object.job)

        var animation = object.animationController.animation
        if let movement = object.movementController.movement, movement.isMoving {
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

    private func snapshot(for item: MetalMapItem, scene: MetalMapScene) -> SpriteSnapshot {
        SpriteSnapshot(
            objectID: item.objectID,
            worldPosition: scene.mapGrid.worldPosition(for: item.gridPosition),
            isVisible: true,
            content: .mapItem(itemID: item.itemID)
        )
    }
}
