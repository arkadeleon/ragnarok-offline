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
    private var effectAssetStore: EffectAssetStore?
    private(set) var effectManager = EffectManager()
    private(set) var worldEffectResources: [EffectRenderResourceGroup] = []
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
    ) async {
        cancelEffectLoads()
        effectAssetLoader = EffectAssetLoader(resourceManager: resourceManager)
        let assetStore = EffectAssetStore(device: device, resourceManager: resourceManager)
        let ez2strEffectCatalog = await EZ2STREffectCatalog.load(from: resourceManager)
        effectAssetStore = assetStore
        effectManager = EffectManager(assetStore: assetStore, ez2strEffectCatalog: ez2strEffectCatalog)
        worldEffectResources.removeAll()
        effectResources.removeAll()
        onEffectSound = onSound
    }

    func updateEffects(atTime currentTime: TimeInterval, world: any EffectWorldContext) {
        effectManager.update(atTime: currentTime, world: world)
    }

    func collectSTRPayloads(fog: Fog, world: any EffectWorldContext) -> [STREffectRenderer.RenderPayload] {
        effectManager.collectSTRPayloads(fog: fog, world: world)
    }

    func loadWorldEffects(_ effects: [WorldEffect]) async {
        guard let effectAssetLoader else {
            return
        }

        var resources: [EffectRenderResourceGroup] = []
        for effect in effects {
            let effectID = EffectID(rawValue: effect.effectID)
            let definitions = EffectTable.definitions(for: effectID)
            do {
                let assetGroup = try await effectAssetLoader.loadAssetGroup(with: definitions)
                resources.append(
                    EffectRenderResourceGroup(
                        device: device,
                        assetGroup: assetGroup,
                        creationTime: 0,
                        worldPosition: effect.position
                    )
                )
            } catch {
                logger.warning("World failed to load effect \(effectID.rawValue): \(error)")
            }
        }

        worldEffectResources = resources
    }

    private func loadEffect(_ effect: MapSceneEffect) {
        let instanceID = effect.id
        effectLoadTasks.removeValue(forKey: instanceID)?.cancel()
        effectResources.removeValue(forKey: instanceID)

        effectLoadTasks[instanceID] = Task { [weak self] in
            guard let self else {
                return
            }
            defer {
                self.effectLoadTasks[instanceID] = nil
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

                guard effectLoadTasks[instanceID] != nil else {
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

                effectResources[instanceID] = resourceGroup
            } catch {
                logger.warning("Map scene failed to load effect \(effect.reference): \(error)")
            }
        }
    }

    func effectResource(for instanceID: UUID) -> EffectRenderResourceGroup? {
        effectResources[instanceID]
    }

    func expiredEffectInstanceIDs(atTime time: TimeInterval) -> [UUID] {
        effectResources.compactMap { instanceID, resourceGroup in
            resourceGroup.isExpired(atTime: time) ? instanceID : nil
        }
    }

    private func removeEffect(instanceID: UUID) {
        effectManager.removeEffect(instanceID: instanceID)
        effectResources.removeValue(forKey: instanceID)
        effectLoadTasks.removeValue(forKey: instanceID)?.cancel()
    }

    func removeAll() {
        spriteAssetStore = nil
        spriteDrawables.removeAll()

        combatTextGlyphSet = nil
        combatTextTexture = nil

        cancelEffectLoads()
        effectManager.removeAll()
        effectAssetStore?.removeAll()
        effectAssetStore = nil
        effectAssetLoader = nil
        worldEffectResources.removeAll()
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
        if case .id(let effectID) = effect.reference, effectManager.supports(effectID) {
            let request = EffectSpawnRequest(
                effectID: effectID,
                worldPosition: effect.worldPosition,
                sourceWorldPosition: effect.sourceWorldPosition,
                ownerObjectID: effect.ownerObjectID,
                targetObjectID: effect.targetObjectID,
                sourceObjectID: effect.sourceObjectID,
                attachmentKey: effect.attachmentKey,
                level: effect.level,
                delay: effect.delay,
                duration: effect.duration
            )
            if effectManager.spawn(request, id: effect.id) != nil {
                return
            }
        }

        loadEffect(effect)
    }

    func mapSceneDidRemoveEffect(instanceID: UUID) {
        removeEffect(instanceID: instanceID)
    }

    func mapSceneDidClear() {
        spriteAssetStore?.removeAll()
        spriteDrawables.removeAll()
        cancelEffectLoads()
        effectManager.removeAll()
        effectResources.removeAll()
    }
}
