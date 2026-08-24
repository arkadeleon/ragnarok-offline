//
//  MapSceneRenderResources.swift
//  RagnarokGame
//
//  Created by Leon Li on 2026/8/24.
//

import CoreGraphics
import Foundation
import Metal
import RagnarokRenderAssets
import RagnarokRendering
import RagnarokResources
import simd

@MainActor
final class MapSceneRenderResources {
    let device: any MTLDevice

    private(set) var world: WorldRenderResource?
    private(set) var tileSelectorTexture: (any MTLTexture)?

    private var spriteAssetStore: SpriteAssetStore?
    private(set) var spriteDrawables: [SpriteLayerDrawable] = []

    private var combatTextSpriteSet: CombatTextSpriteSet?
    private var combatTextResources: [UUID : CombatTextRenderResource] = [:]

    private var effectAssetStore: EffectAssetStore?
    private var effectResources: [UUID : EffectRenderResourceGroup] = [:]
    private var effectLoadTasks: [UUID : Task<Void, Never>] = [:]

    init(device: any MTLDevice) {
        self.device = device
    }

    func loadWorld(_ asset: WorldAsset) {
        world = WorldRenderResource(device: device, asset: asset)
    }

    func loadTileSelectorTexture(from image: CGImage?) {
        tileSelectorTexture = MetalTextureFactory.makeTexture(
            from: image,
            device: device,
            label: "tile-selector"
        )
    }

    func prepareSprites(resourceManager: ResourceManager) {
        spriteAssetStore?.cancelAllTasks()
        spriteAssetStore = SpriteAssetStore(
            device: device,
            resourceManager: resourceManager
        )
        spriteDrawables.removeAll()
    }

    func synchronizeSprites(
        objects: [GameObjectID : MapSceneMapObject],
        items: [GameObjectID : MapSceneDroppedItem],
        worldPositions: [GameObjectID : SIMD3<Float>],
        camera: MapCameraState
    ) {
        spriteDrawables = spriteAssetStore?.sync(
            objects: objects,
            items: items,
            worldPositions: worldPositions,
            camera: camera
        ) ?? []
    }

    func prepareCombatTexts(resourceManager: ResourceManager) async throws {
        combatTextSpriteSet = nil
        combatTextResources.removeAll()
        combatTextSpriteSet = try await CombatTextSpriteSet(resourceManager: resourceManager)
    }

    func addCombatText(
        _ combatText: CombatText,
        startWorldPosition: SIMD3<Float>
    ) -> Bool {
        guard let combatTextSpriteSet,
              combatTextResources[combatText.id] == nil,
              let resource = CombatTextRenderResource(
                  device: device,
                  combatText: combatText,
                  startWorldPosition: startWorldPosition,
                  spriteSet: combatTextSpriteSet
              ) else {
            return false
        }

        combatTextResources[combatText.id] = resource
        return true
    }

    func combatTextResource(for id: UUID) -> CombatTextRenderResource? {
        combatTextResources[id]
    }

    func removeCombatText(id: UUID) {
        combatTextResources.removeValue(forKey: id)
    }

    func prepareEffects(resourceManager: ResourceManager) {
        cancelEffectLoads()
        effectAssetStore?.cancelAllTasks()
        effectAssetStore = EffectAssetStore(resourceManager: resourceManager)
        effectResources.removeAll()
    }

    func addEffect(
        _ effect: MapSceneEffect,
        worldPosition: SIMD3<Float>,
        onSound: @escaping @MainActor (_ name: String, _ delay: TimeInterval) -> Void
    ) {
        let effectID = effect.id
        effectLoadTasks.removeValue(forKey: effectID)?.cancel()
        effectResources.removeValue(forKey: effectID)

        effectLoadTasks[effectID] = Task { [weak self] in
            guard let self else {
                return
            }
            defer {
                self.effectLoadTasks[effectID] = nil
            }

            do {
                guard let effectAssetStore else {
                    return
                }

                let assetGroup = try await effectAssetStore.assetGroup(for: effect.reference)
                guard !Task.isCancelled else {
                    return
                }

                for asset in assetGroup.assets {
                    if let soundName = asset.soundName {
                        onSound(soundName, effect.delay)
                    }
                }

                guard effectLoadTasks[effectID] != nil else {
                    return
                }

                effectResources[effectID] = EffectRenderResourceGroup(
                    device: device,
                    assetGroup: assetGroup,
                    creationTime: effect.creationTime,
                    delay: effect.delay,
                    worldPosition: worldPosition,
                    sourceWorldPosition: effect.sourceWorldPosition
                )
            } catch {
                logger.warning("Metal map scene failed to load effect \(effect.reference): \(error)")
            }
        }
    }

    func effectResource(for id: UUID) -> EffectRenderResourceGroup? {
        effectResources[id]
    }

    func expiredEffectIDs(atTime time: TimeInterval) -> [UUID] {
        effectResources.compactMap { effectID, resourceGroup in
            resourceGroup.isExpired(atTime: time) ? effectID : nil
        }
    }

    func removeEffect(id: UUID) {
        effectResources.removeValue(forKey: id)
        effectLoadTasks.removeValue(forKey: id)?.cancel()
    }

    func makeSnapshot(
        from scene: MapScene,
        atTime time: TimeInterval
    ) -> MapSceneRenderSnapshot {
        let now = ContinuousClock.now

        let vanishedObjectIDs = scene.objects.compactMap { objectID, object in
            object.death?.isVanished(at: now) == true ? objectID : nil
        }
        for objectID in vanishedObjectIDs {
            scene.removeObject(objectID: objectID)
        }

        let expiredCombatTextObjectIDs = scene.combatTexts.compactMap { combatTextObjectID, combatText in
            combatText.isExpired(at: now) ? combatTextObjectID : nil
        }
        for combatTextObjectID in expiredCombatTextObjectIDs {
            scene.combatTexts.removeValue(forKey: combatTextObjectID)
            removeCombatText(id: combatTextObjectID)
        }

        let expiredEffectObjectIDs = expiredEffectIDs(atTime: time)
        for effectObjectID in expiredEffectObjectIDs {
            scene.removeEffect(objectID: effectObjectID)
        }

        var worldPositions: [GameObjectID : SIMD3<Float>] = [:]
        worldPositions.reserveCapacity(scene.objects.count + scene.items.count)

        for object in scene.objects.values {
            object.update(at: now)
            if let movement = object.movement {
                object.gridPosition = movement.currentPosition
            }
            worldPositions[object.objectID] = scene.worldPosition(for: object)
        }

        for item in scene.items.values {
            worldPositions[item.objectID] = scene.mapGrid.worldPosition(for: item.gridPosition)
        }

        synchronizeSprites(
            objects: scene.objects,
            items: scene.items,
            worldPositions: worldPositions,
            camera: scene.cameraState
        )

        if let playerWorldPosition = worldPositions[scene.player.objectID] {
            scene.updateCameraTargetPosition(playerWorldPosition)
        }

        var snapshot = MapSceneRenderSnapshot(fog: scene.fog)

        snapshot.world = world
        snapshot.spriteDrawables = spriteDrawables

        if let tileSelector = scene.tileSelector, let tileSelectorTexture,
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
                guard let resourceGroup = effectResource(for: effect.id) else {
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
                guard let resource = combatTextResource(for: combatText.id) else {
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

    func removeAll() {
        spriteAssetStore?.cancelAllTasks()
        spriteAssetStore = nil
        spriteDrawables.removeAll()

        combatTextSpriteSet = nil
        combatTextResources.removeAll()

        cancelEffectLoads()
        effectAssetStore?.cancelAllTasks()
        effectAssetStore = nil
        effectResources.removeAll()

        world = nil
        tileSelectorTexture = nil
    }

    private func cancelEffectLoads() {
        for task in effectLoadTasks.values {
            task.cancel()
        }
        effectLoadTasks.removeAll()
    }
}
