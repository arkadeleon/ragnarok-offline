//
//  MetalRenderBackend.swift
//  RagnarokGame
//
//  Created by Leon Li on 2026/3/22.
//

import Foundation
import Metal
import RagnarokMetalRendering
import RagnarokRenderAssets
import RagnarokResources
import simd

final class MetalRenderBackend: GameRenderBackend {
    private(set) weak var scene: MapScene?

    let resourceManager: ResourceManager
    let renderer: MetalMapRenderer
    let audioPlayer: MetalMapAudioPlayer

    private let spriteSnapshotBuilder = SpriteSnapshotBuilder()
    private var spriteSnapshots: [GameObjectID : SpriteSnapshot] = [:]
    private var spriteAssetStore: SpriteAssetStore?
    private var combatTextSpriteSet: CombatTextSpriteSet?
    private var effectAssetStore: EffectAssetStore?
    private var effectLoadTasks: [UUID : Task<Void, Never>] = [:]

    init(resourceManager: ResourceManager) throws {
        self.resourceManager = resourceManager
        self.renderer = try MetalMapRenderer()
        self.audioPlayer = MetalMapAudioPlayer(resourceManager: resourceManager)
    }

    func attach(scene: MapScene) {
        self.scene = scene
        syncFrameState(with: scene.state)
    }

    func detach() {
        audioPlayer.stopAll()
        clearRenderResources()
        scene = nil
    }

    func load(progress: Progress) async {
        guard let scene else {
            return
        }

        do {
            try await prepareRenderResources(scene: scene, progress: progress)

            await audioPlayer.playBGM(forMapName: scene.mapName)

            syncFrameState(with: scene.state)
        } catch {
            logger.warning("Metal map backend failed to load world asset: \(error)")
        }
    }

    func unload() {
        audioPlayer.stopAll()
        clearRenderResources()
    }

    func applySnapshot(_ state: MapSceneState) {
        syncFrameState(with: state)
    }

    func showSelection(at position: SIMD2<Int>, mapGrid: MapGrid) {
        renderer.tileSelectorResource?.showSelection(at: position, mapGrid: mapGrid)
    }

    func addCombatText(_ combatText: MapCombatText) {
        renderCombatText(combatText)
    }

    func addEffect(_ effect: MapEffect) {
        renderEffect(effect)
    }

    func playSound(named soundName: String, on objectID: GameObjectID) {
        audioPlayer.playSound(named: soundName)
    }

    func prepareFrame() {
        guard let scene else {
            return
        }
        syncFrameState(with: scene.state)
        syncAndProjectOverlay()
    }

    private func syncFrameState(with state: MapSceneState) {
        guard let scene else {
            return
        }

        removeExpiredCombatTexts()
        removeExpiredEffects()

        updateObjects(
            objects: state.objects,
            items: state.items,
            scene: scene
        )

        let playerPresentationPosition =
            spriteSnapshots[state.playerID]?.worldPosition
            ?? scene.mapGrid.worldPosition(for: state.player.gridPosition)
        renderer.updateCamera(
            cameraState: scene.cameraState,
            targetPosition: playerPresentationPosition
        )
    }

    private func syncAndProjectOverlay() {
        guard let scene else {
            return
        }

        for objectID in scene.state.overlay.gauges.keys {
            guard var worldPosition = spriteSnapshots[objectID]?.worldPosition else {
                continue
            }

            worldPosition += [0, -0.8, 0]
            scene.state.overlay.gauges[objectID]?.worldPosition = worldPosition

            let screenPosition = project(worldPosition)
            scene.state.overlay.gauges[objectID]?.screenPosition = screenPosition
        }
    }

    private func prepareRenderResources(scene: MapScene, progress: Progress) async throws {
        let worldAssetLoader = WorldAssetLoader()
        let worldAsset = try await worldAssetLoader.load(
            gat: scene.world.gat,
            gnd: scene.world.gnd,
            rsw: scene.world.rsw,
            resourceManager: resourceManager,
            progress: progress
        )
        let skyboxConfiguration = SkyboxConfiguration.generate(
            light: scene.world.rsw.light,
            mapWidth: scene.mapGrid.width,
            mapHeight: scene.mapGrid.height
        )

        renderer.skyboxResource = SkyboxRenderResource(device: renderer.device, configuration: skyboxConfiguration)
        renderer.groundResource = GroundRenderResource(device: renderer.device, asset: worldAsset.ground)
        renderer.waterResource = WaterRenderResource(device: renderer.device, asset: worldAsset.water)
        renderer.modelResources = worldAsset.modelGroups.map { modelGroup in
            RSMModelRenderResource(
                device: renderer.device,
                prototype: modelGroup.prototype,
                instances: modelGroup.instances
            )
        }

        do {
            let path = ResourcePath.textureDirectory.appending(["grid.tga"])
            let image = try await resourceManager.image(at: path)
            renderer.tileSelectorResource = TileSelectorRenderResource(device: renderer.device, image: image.cgImage)
        } catch {
            logger.warning("Metal backend failed to load grid.tga: \(error)")
        }

        let scriptContext = await resourceManager.scriptContext
        spriteAssetStore = SpriteAssetStore(
            device: renderer.device,
            resourceManager: resourceManager,
            scriptContext: scriptContext
        )

        do {
            combatTextSpriteSet = try await CombatTextSpriteSet(resourceManager: resourceManager)
        } catch {
            combatTextSpriteSet = nil
            logger.warning("Metal backend failed to load combat text sprites: \(error)")
        }

        effectAssetStore = EffectAssetStore(
            device: renderer.device,
            resourceManager: resourceManager
        )
    }

    private func clearRenderResources() {
        spriteAssetStore?.cancelAllTasks()
        spriteAssetStore = nil
        spriteSnapshots.removeAll()
        combatTextSpriteSet = nil
        for task in effectLoadTasks.values {
            task.cancel()
        }
        effectAssetStore?.cancelAllTasks()
        effectAssetStore = nil
        effectLoadTasks.removeAll()

        renderer.skyboxResource = nil
        renderer.groundResource = nil
        renderer.waterResource = nil
        renderer.modelResources.removeAll()
        renderer.spriteDrawables.removeAll()
        renderer.combatTextResources.removeAll()
        renderer.effectResources.removeAll()
        renderer.tileSelectorResource = nil
    }

    private func updateObjects(
        objects: [GameObjectID : MapObjectState],
        items: [GameObjectID : MapItemState],
        scene: MapScene
    ) {
        let snapshots = spriteSnapshotBuilder.build(
            objects: objects,
            items: items,
            scene: scene
        )
        spriteSnapshots = snapshots
        renderer.spriteDrawables = spriteAssetStore?.sync(snapshots: snapshots) ?? []
    }

    private func renderCombatText(_ combatText: MapCombatText) {
        guard let scene, let combatTextSpriteSet else {
            return
        }

        guard renderer.combatTextResources[combatText.id] == nil else {
            return
        }

        guard let startPosition = spriteSnapshots[combatText.target.id]?.worldPosition
            ?? fallbackWorldPosition(for: combatText.target.id, scene: scene) else {
            return
        }

        renderer.combatTextResources[combatText.id] = CombatTextRenderResource(
            device: renderer.device,
            combatText: combatText,
            startPosition: startPosition,
            spriteSet: combatTextSpriteSet
        )
    }

    private func renderEffect(_ effect: MapEffect) {
        guard let scene else {
            return
        }

        if let soundName = effect.effectDefinition.soundName {
            audioPlayer.playSound(named: soundName, after: effect.delay)
        }

        let worldPosition = scene.mapGrid.worldPosition(for: effect.gridPosition)
        let effectID = effect.id

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

                let asset = try await effectAssetStore.asset(for: effect.effectDefinition)

                renderer.effectResources[effectID] = try STREffectRenderResource(
                    device: renderer.device,
                    effect: effect,
                    strEffect: asset.effect,
                    textures: asset.textures,
                    worldPosition: worldPosition
                )
            } catch {
                logger.warning("Metal backend failed to load effect \(effect.effectID): \(error)")
            }
        }
    }

    private func removeExpiredCombatTexts() {
        let now = ContinuousClock.now
        renderer.combatTextResources = renderer.combatTextResources.filter { _, resource in
            !resource.isExpired(at: now)
        }
    }

    private func removeExpiredEffects() {
        let now = ContinuousClock.now
        renderer.effectResources = renderer.effectResources.filter { _, resource in
            !resource.isExpired(at: now)
        }
    }

    private func fallbackWorldPosition(for objectID: GameObjectID, scene: MapScene) -> SIMD3<Float>? {
        if let gridPosition = scene.state.objects[objectID]?.gridPosition {
            return scene.mapGrid.worldPosition(for: gridPosition)
        } else {
            return nil
        }
    }
}
