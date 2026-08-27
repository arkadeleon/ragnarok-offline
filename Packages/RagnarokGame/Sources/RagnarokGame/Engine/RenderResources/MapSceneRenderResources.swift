//
//  MapSceneRenderResources.swift
//  RagnarokGame
//
//  Created by Leon Li on 2026/8/24.
//

import CoreGraphics
import Foundation
import Metal
import RagnarokEffects
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

    private var effectAssetLoader: EffectAssetLoader?
    private var effectObjectIDs: Set<UUID> = []
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

    func synchronizeCombatTexts(_ combatTexts: [UUID : CombatText]) {
        let currentIDs = Set(combatTexts.keys)
        for combatTextObjectID in Set(combatTextResources.keys).subtracting(currentIDs) {
            combatTextResources.removeValue(forKey: combatTextObjectID)
        }

        for (combatTextObjectID, combatText) in combatTexts where combatTextResources[combatTextObjectID] == nil {
            addCombatText(combatText)
        }
    }

    private func addCombatText(_ combatText: CombatText) {
        guard let combatTextSpriteSet,
              combatTextResources[combatText.id] == nil,
              let resource = CombatTextRenderResource(
                  device: device,
                  combatText: combatText,
                  spriteSet: combatTextSpriteSet
              ) else {
            return
        }

        combatTextResources[combatText.id] = resource
    }

    func combatTextResource(for objectID: UUID) -> CombatTextRenderResource? {
        combatTextResources[objectID]
    }

    func prepareEffects(resourceManager: ResourceManager) {
        cancelEffectLoads()
        effectAssetLoader = EffectAssetLoader(resourceManager: resourceManager)
        effectObjectIDs.removeAll()
        effectResources.removeAll()
    }

    func synchronizeEffects(
        _ effects: [UUID : MapSceneEffect],
        worldPositions: [UUID : SIMD3<Float>],
        onSound: @escaping @MainActor (_ name: String, _ delay: TimeInterval) -> Void
    ) {
        let currentIDs = Set(effects.keys)
        for effectObjectID in effectObjectIDs.subtracting(currentIDs) {
            removeEffect(objectID: effectObjectID)
        }

        for (effectObjectID, effect) in effects where !effectObjectIDs.contains(effectObjectID) {
            guard let worldPosition = worldPositions[effectObjectID] else {
                continue
            }
            effectObjectIDs.insert(effectObjectID)
            loadEffect(effect, worldPosition: worldPosition, onSound: onSound)
        }
    }

    private func loadEffect(
        _ effect: MapSceneEffect,
        worldPosition: SIMD3<Float>,
        onSound: @escaping @MainActor (_ name: String, _ delay: TimeInterval) -> Void
    ) {
        let objectID = effect.id
        effectLoadTasks.removeValue(forKey: objectID)?.cancel()
        effectResources.removeValue(forKey: objectID)

        effectLoadTasks[objectID] = Task { [weak self] in
            guard let self else {
                return
            }
            defer {
                self.effectLoadTasks[objectID] = nil
            }

            do {
                guard let effectAssetLoader else {
                    return
                }

                let definitions = EffectTable.definitions(for: effect.reference)
                let assetGroup = try await effectAssetLoader.loadAssetGroup(with: definitions)
                guard !Task.isCancelled else {
                    return
                }

                guard effectLoadTasks[objectID] != nil else {
                    return
                }

                let resourceGroup = EffectRenderResourceGroup(
                    device: device,
                    assetGroup: assetGroup,
                    creationTime: effect.creationTime,
                    delay: effect.delay,
                    duration: effect.duration,
                    worldPosition: worldPosition,
                    sourceWorldPosition: effect.sourceWorldPosition
                )

                for sound in resourceGroup.sounds {
                    onSound(sound.name, effect.delay + sound.delay)
                }

                effectResources[objectID] = resourceGroup
            } catch {
                logger.warning("Map scene failed to load effect \(effect.reference): \(error)")
            }
        }
    }

    func effectResource(for objectID: UUID) -> EffectRenderResourceGroup? {
        effectResources[objectID]
    }

    func expiredEffectIDs(atTime time: TimeInterval) -> [UUID] {
        effectResources.compactMap { objectID, resourceGroup in
            resourceGroup.isExpired(atTime: time) ? objectID : nil
        }
    }

    private func removeEffect(objectID: UUID) {
        effectObjectIDs.remove(objectID)
        effectResources.removeValue(forKey: objectID)
        effectLoadTasks.removeValue(forKey: objectID)?.cancel()
    }

    func removeAll() {
        spriteAssetStore?.cancelAllTasks()
        spriteAssetStore = nil
        spriteDrawables.removeAll()

        combatTextSpriteSet = nil
        combatTextResources.removeAll()

        cancelEffectLoads()
        effectAssetLoader = nil
        effectObjectIDs.removeAll()
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
