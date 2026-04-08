//
//  SpriteSnapshotEvaluator.swift
//  RagnarokGame
//
//  Created by Leon Li on 2026/3/25.
//

import Foundation
import RagnarokModels
import RagnarokSprite
import simd

@MainActor
final class SpriteSnapshotEvaluator {
    func evaluate(
        player: MapObjectState,
        objects: [GameObjectID : MapObjectState],
        items: [GameObjectID : MapItemState],
        scene: MapScene
    ) -> [GameObjectID : SpriteSnapshot] {
        let now = ContinuousClock.now
        var snapshots: [GameObjectID : SpriteSnapshot] = [:]

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
            snapshots[itemID] = SpriteSnapshot(
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
    ) -> SpriteSnapshot {
        let presentationSample = MapObjectPresentationEvaluator.resolvedPresentation(
            for: state,
            now: now,
            position: { scene.position(for: $0) }
        )

        let visualAnimationKey = SpriteAnimationKey(
            action: presentationSample.action,
            direction: presentationSample.direction.adjustedForCameraAzimuth(scene.cameraState.azimuth)
        )

        return SpriteSnapshot(
            objectID: state.id,
            worldPosition: presentationSample.worldPosition,
            isVisible: state.isVisible,
            content: .mapObject(
                mapObject: state.object,
                animationKey: sanitizedAnimationKey(visualAnimationKey, for: state.object),
                animationElapsed: presentationSample.animationElapsed
            )
        )
    }

    private func sanitizedAnimationKey(
        _ key: SpriteAnimationKey,
        for mapObject: MapObject
    ) -> SpriteAnimationKey {
        let availableActionTypes = CharacterActionType.availableActionTypes(forJobID: mapObject.job)
        guard availableActionTypes.contains(key.action) else {
            return SpriteAnimationKey(action: .idle, direction: key.direction)
        }
        return key
    }
}
