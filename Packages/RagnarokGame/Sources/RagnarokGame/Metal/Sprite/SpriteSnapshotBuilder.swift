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
        player: MapObjectState,
        objects: [GameObjectID : MapObjectState],
        items: [GameObjectID : MapItemState],
        scene: MapScene
    ) -> [GameObjectID : SpriteSnapshot] {
        let now = ContinuousClock.now

        var snapshots: [GameObjectID : SpriteSnapshot] = [:]

        snapshots[player.id] = snapshot(for: player, now: now, scene: scene)
        for (objectID, objectState) in objects {
            snapshots[objectID] = snapshot(for: objectState, now: now, scene: scene)
        }

        for (itemID, itemState) in items {
            snapshots[itemID] = snapshot(for: itemState, scene: scene)
        }

        return snapshots
    }

    private func snapshot(for state: MapObjectState, now: ContinuousClock.Instant, scene: MapScene) -> SpriteSnapshot {
        let presentationSample = sampler.sample(
            for: state,
            position: { scene.mapGrid.worldPosition(for: $0) },
            now: now
        )

        let availableActionTypes = SpriteActionType.availableActionTypes(forJobID: state.object.job)

        var animation = presentationSample.animation
        animation.direction = animation.direction.adjustedForCameraAzimuth(scene.cameraState.azimuth)
        if !availableActionTypes.contains(animation.action) {
            animation.action = .idle
        }

        return SpriteSnapshot(
            objectID: state.id,
            worldPosition: presentationSample.worldPosition,
            isVisible: state.isVisible,
            content: .mapObject(mapObject: state.object, animation: animation)
        )
    }

    private func snapshot(for state: MapItemState, scene: MapScene) -> SpriteSnapshot {
        SpriteSnapshot(
            objectID: state.id,
            worldPosition: scene.mapGrid.worldPosition(for: state.gridPosition),
            isVisible: true,
            content: .item(state.item)
        )
    }
}
