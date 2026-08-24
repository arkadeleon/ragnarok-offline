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
