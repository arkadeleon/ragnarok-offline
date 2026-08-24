//
//  MapSceneRuntime.swift
//  RagnarokGame
//
//  Created by Leon Li on 2026/8/24.
//

import Foundation
import simd

@MainActor
final class MapSceneRuntime {
    let scene: MapScene
    let renderResources: MapSceneRenderResources

    init(scene: MapScene, renderResources: MapSceneRenderResources) {
        self.scene = scene
        self.renderResources = renderResources
    }

    func makeRenderSnapshot(at now: ContinuousClock.Instant) -> MapSceneRenderSnapshot {
        var worldPositions: [GameObjectID : SIMD3<Float>] = [:]
        worldPositions.reserveCapacity(scene.objects.count + scene.items.count)

        for object in scene.objects.values {
            worldPositions[object.objectID] = scene.worldPosition(for: object)
        }

        for item in scene.items.values {
            worldPositions[item.objectID] = scene.mapGrid.worldPosition(for: item.gridPosition)
        }

        renderResources.synchronizeSprites(
            objects: scene.objects,
            items: scene.items,
            worldPositions: worldPositions,
            camera: scene.cameraState
        )

        var snapshot = MapSceneRenderSnapshot(fog: scene.fog)

        snapshot.world = renderResources.world
        snapshot.spriteDrawables = renderResources.spriteDrawables

        if let tileSelector = scene.tileSelector,
           let tileSelectorTexture = renderResources.tileSelectorTexture,
           !tileSelector.isExpired(at: now),
           scene.mapGrid.contains(tileSelector.position) {
            snapshot.tileSelector = MapSceneRenderSnapshot.TileSelector(
                position: tileSelector.position,
                cell: scene.mapGrid[tileSelector.position],
                texture: tileSelectorTexture
            )
        }

        snapshot.effects = scene.effects.values
            .compactMap { effect in
                guard let resourceGroup = renderResources.effectResource(for: effect.id) else {
                    return nil
                }
                return MapSceneRenderSnapshot.Effect(
                    resourceGroup: resourceGroup,
                    attachedWorldPosition: effect.targetObjectID.flatMap { worldPositions[$0] }
                )
            }
            .sorted {
                $0.resourceGroup.creationTime < $1.resourceGroup.creationTime
            }

        snapshot.gauges = scene.gaugeObjectIDs.compactMap { objectID in
            guard let object = scene.objects[objectID],
                  object.effectState != .cloak,
                  let worldPosition = worldPositions[objectID] else {
                return nil
            }
            let vertices = Gauge(object: object).makeVertices()
            guard !vertices.isEmpty else {
                return nil
            }
            return MapSceneRenderSnapshot.Gauge(
                vertices: vertices,
                worldPosition: worldPosition + [0, 0, -0.8]
            )
        }

        // A target shows one combo text at a time: the newest one that has started
        // hides the ones before it.
        let comboTexts = scene.combatTexts.values
            .filter { $0.kind.isCombo && $0.startTime <= now }
            .map { ($0.target.objectID, $0) }
        let latestComboTexts = Dictionary(
            comboTexts,
            uniquingKeysWith: { $0.startTime > $1.startTime ? $0 : $1 }
        )

        snapshot.combatTexts = scene.combatTexts.values
            .filter { combatText in
                if combatText.kind.isCombo, let latestComboText = latestComboTexts[combatText.target.objectID] {
                    return combatText.id == latestComboText.id
                } else {
                    return true
                }
            }
            .sorted {
                $0.creationTime < $1.creationTime
            }
            .compactMap { combatText in
                guard let resource = renderResources.combatTextResource(for: combatText.id) else {
                    return nil
                }

                let anchor = worldPositions[combatText.target.objectID] ?? resource.startWorldPosition
                guard let animation = combatText.animation(
                    at: now,
                    anchor: anchor,
                    cameraAzimuth: scene.cameraState.azimuth
                ) else {
                    return nil
                }

                return MapSceneRenderSnapshot.CombatText(
                    vertices: resource.makeVertices(scale: animation.scale, alpha: animation.alpha),
                    worldPosition: animation.worldPosition,
                    texture: resource.texture
                )
            }

        return snapshot
    }
}
