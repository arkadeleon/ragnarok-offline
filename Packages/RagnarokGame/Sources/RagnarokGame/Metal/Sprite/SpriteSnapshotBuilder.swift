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
    private let sampler = MapObjectPresentationSampler()

    func build(
        objects: [GameObjectID : MapSceneObject],
        movements: [GameObjectID : MapObjectMovementState],
        presentations: [GameObjectID : MapObjectPresentationState],
        items: [GameObjectID : MapSceneItem],
        scene: MapScene
    ) -> [GameObjectID : SpriteSnapshot] {
        let now = ContinuousClock.now

        var snapshots: [GameObjectID : SpriteSnapshot] = [:]

        for (objectID, object) in objects {
            let presentation = presentations[objectID] ?? .defaultPresentation
            snapshots[objectID] = snapshot(for: object, movement: movements[objectID], presentation: presentation, now: now, scene: scene)
        }

        for (objectID, item) in items {
            snapshots[objectID] = snapshot(for: item, scene: scene)
        }

        return snapshots
    }

    private func snapshot(for object: MapSceneObject, movement: MapObjectMovementState?, presentation: MapObjectPresentationState, now: ContinuousClock.Instant, scene: MapScene) -> SpriteSnapshot {
        let presentationSample = sampler.sample(
            for: object,
            movement: movement,
            presentation: presentation,
            position: { scene.mapGrid.worldPosition(for: $0) },
            now: now
        )

        let availableActionTypes = SpriteActionType.availableActionTypes(forJobID: object.job)

        var animation = presentationSample.animation
        animation.direction = animation.direction.adjustedForCameraAzimuth(scene.cameraState.azimuth)
        if !availableActionTypes.contains(animation.action) {
            animation.action = .idle
        }

        return SpriteSnapshot(
            objectID: object.objectID,
            worldPosition: presentationSample.worldPosition,
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
