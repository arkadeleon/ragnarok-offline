//
//  MapSceneRenderResources.swift
//  RagnarokGame
//
//  Created by Leon Li on 2026/8/24.
//

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

    private var spriteAssetStore: SpriteAssetStore?
    private(set) var spriteDrawables: [SpriteDrawable] = []

    private(set) var combatTextGlyphSet: CombatTextGlyphSet?
    private(set) var combatTextTexture: (any MTLTexture)?

    private var effectAssetLoader: EffectAssetLoader?
    private var effectResources: [UUID : EffectRenderResourceGroup] = [:]
    private var effectLoadTasks: [UUID : Task<Void, Never>] = [:]
    private var onEffectSound: (@MainActor (_ name: String, _ delay: TimeInterval) -> Void)?

    let textTextureCache: TextTextureCache

    init(device: any MTLDevice) {
        self.device = device
        self.textTextureCache = TextTextureCache(device: device)
    }

    func loadWorld(_ asset: WorldAsset) {
        world = WorldRenderResource(device: device, asset: asset)
    }

    func prepareSprites(shadowmap: GroundShadowmap) {
        spriteAssetStore = SpriteAssetStore(device: device, shadowmap: shadowmap)
        spriteDrawables.removeAll()
    }

    func synchronizeSprites(objects: [GameObjectID : MapSceneMapObject], items: [GameObjectID : MapSceneDroppedItem]) {
        spriteDrawables = spriteAssetStore?.sync(objects: objects, items: items) ?? []
    }

    func prepareCombatTexts(resourceManager: ResourceManager) async {
        combatTextGlyphSet = nil
        combatTextTexture = nil

        do {
            let glyphSet = try await CombatTextGlyphSet(resourceManager: resourceManager)
            combatTextGlyphSet = glyphSet
            combatTextTexture = MetalTextureFactory.makeTexture(
                from: glyphSet.atlasImage,
                device: device,
                label: "combat-text-atlas"
            )
        } catch {
            logger.warning("Map scene failed to load combat text glyphs: \(error)")
        }
    }

    func prepareEffects(
        resourceManager: ResourceManager,
        onSound: @escaping @MainActor (_ name: String, _ delay: TimeInterval) -> Void
    ) {
        cancelEffectLoads()
        effectAssetLoader = EffectAssetLoader(resourceManager: resourceManager)
        effectResources.removeAll()
        onEffectSound = onSound
    }

    private func loadEffect(_ effect: MapSceneEffect) {
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
                    worldPosition: effect.worldPosition,
                    sourceWorldPosition: effect.sourceWorldPosition
                )

                for sound in resourceGroup.sounds {
                    onEffectSound?(sound.name, effect.delay + sound.delay)
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
        effectResources.removeValue(forKey: objectID)
        effectLoadTasks.removeValue(forKey: objectID)?.cancel()
    }

    func removeAll() {
        spriteAssetStore = nil
        spriteDrawables.removeAll()

        combatTextGlyphSet = nil
        combatTextTexture = nil

        cancelEffectLoads()
        effectAssetLoader = nil
        effectResources.removeAll()
        onEffectSound = nil

        textTextureCache.removeAll()

        world = nil
    }

    private func cancelEffectLoads() {
        for task in effectLoadTasks.values {
            task.cancel()
        }
        effectLoadTasks.removeAll()
    }
}

extension MapSceneRenderResources: MapSceneObserver {
    func mapSceneDidAddObject(_ object: MapSceneMapObject) {
    }

    func mapSceneDidUpdateObjectSprite(_ object: MapSceneMapObject) {
    }

    func mapSceneDidRemoveObject(objectID: GameObjectID) {
        spriteAssetStore?.removeObjectTextures(forObjectID: objectID)
    }

    func mapSceneDidAddItem(_ item: MapSceneDroppedItem) {
    }

    func mapSceneDidRemoveItem(objectID: GameObjectID) {
        spriteAssetStore?.removeItemTextures(forItemID: objectID)
    }

    func mapSceneDidAddEffect(_ effect: MapSceneEffect) {
        loadEffect(effect)
    }

    func mapSceneDidRemoveEffect(id: UUID) {
        removeEffect(objectID: id)
    }

    func mapSceneDidClear() {
        spriteAssetStore?.removeAll()
        spriteDrawables.removeAll()
        cancelEffectLoads()
        effectResources.removeAll()
    }
}
