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
import RagnarokSprite
import simd

@MainActor
final class MetalRenderBackend {
    private(set) weak var scene: MetalMapScene?

    let resourceManager: ResourceManager
    let renderer: MetalMapRenderer
    let audioPlayer: MetalMapAudioPlayer

    private let spriteSnapshotBuilder = SpriteSnapshotBuilder()
    private var spriteSnapshots: [GameObjectID : SpriteSnapshot] = [:]
    private var spriteAssetStore: SpriteAssetStore?
    private var combatTextSpriteSet: CombatTextSpriteSet?
    private var effectAssetStore: EffectAssetStore?
    private var effectLoadTasks: [UUID : Task<Void, Never>] = [:]

    private var items: [GameObjectID : MetalMapItem] = [:]
    private var cameraState: MapCameraState = .default

    init(resourceManager: ResourceManager) throws {
        self.resourceManager = resourceManager
        self.renderer = try MetalMapRenderer()
        self.audioPlayer = MetalMapAudioPlayer(resourceManager: resourceManager)
    }

    func attach(scene: MetalMapScene) {
        self.scene = scene
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
        } catch {
            logger.warning("Metal map backend failed to load world asset: \(error)")
        }
    }

    func unload() {
        audioPlayer.stopAll()
        clearRenderResources()
    }

    func updateCamera(_ cameraState: MapCameraState) {
        self.cameraState = cameraState
        refreshSpriteDrawables()
        updateCameraTarget()
    }

    func addObject(objectID: GameObjectID, at gridPosition: SIMD2<Int>, direction: SpriteDirection, headDirection: SpriteHeadDirection) {
        guard let object = scene?.objectRegistry.object(for: objectID) else {
            return
        }
        object.gridPosition = gridPosition
        object.animationController.perform(.idle, completion: .indefinite)
        object.animationController.turn(direction: direction, headDirection: headDirection)
        if let mapGrid = scene?.mapGrid {
            object.presentation.worldPosition = mapGrid.worldPosition(for: gridPosition)
        }
        refreshSpriteDrawables()
    }

    func updateObject(objectID: GameObjectID) {
        guard scene?.objectRegistry.object(for: objectID) != nil else {
            return
        }
        refreshSpriteDrawables()
    }

    func moveObject(objectID: GameObjectID, startPosition: SIMD2<Int>, endPosition: SIMD2<Int>) -> MetalMovement? {
        guard let scene, let object = scene.objectRegistry.object(for: objectID) else {
            return nil
        }

        let now = ContinuousClock.now
        let movement = object.movementController.replan(
            startPosition: startPosition,
            endPosition: endPosition,
            speed: object.speed,
            at: now
        )

        object.gridPosition = movement.currentPosition
        let remainingDuration = movement.remainingDuration(at: now)
        object.animationController.perform(
            .walk,
            completion: .after(remainingDuration, settledAction: .idle),
            at: now
        )
        object.animationController.setDirection(movement.finalDirection)

        refreshSpriteDrawables()
        if objectID == scene.player.objectID {
            updateCameraTarget()
        }

        return movement
    }

    func stopObject(objectID: GameObjectID, at position: SIMD2<Int>) {
        if let object = scene?.objectRegistry.object(for: objectID) {
            object.gridPosition = position
            object.movementController.stop()
            object.animationController.perform(.idle, completion: .indefinite)
        }

        refreshSpriteDrawables()
        if objectID == scene?.player.objectID {
            updateCameraTarget()
        }
    }

    func turnObject(objectID: GameObjectID, direction: SpriteDirection, headDirection: SpriteHeadDirection) {
        guard let object = scene?.objectRegistry.object(for: objectID) else {
            return
        }

        object.animationController.turn(direction: direction, headDirection: headDirection)
        refreshSpriteDrawables()
    }

    func performObjectAction(objectID: GameObjectID, action: SpriteActionType, completion: MetalAnimationCompletion) {
        guard let object = scene?.objectRegistry.object(for: objectID) else {
            return
        }

        object.animationController.perform(action, completion: completion)
        refreshSpriteDrawables()
    }

    func removeObject(objectID: GameObjectID) {
        spriteSnapshots.removeValue(forKey: objectID)
        refreshSpriteDrawables()
    }

    func gridPosition(for objectID: GameObjectID) -> SIMD2<Int>? {
        scene?.objectRegistry.object(for: objectID)?.gridPosition
    }

    func nextGridPosition(for objectID: GameObjectID) -> SIMD2<Int>? {
        scene?.objectRegistry.object(for: objectID)?.movementController.nextPosition(at: .now)
    }

    func addItem(_ item: MetalMapItem) {
        items[item.objectID] = item
        refreshSpriteDrawables()
    }

    func removeItem(objectID: GameObjectID) {
        items.removeValue(forKey: objectID)
        spriteSnapshots.removeValue(forKey: objectID)
        refreshSpriteDrawables()
    }

    func showSelection(at position: SIMD2<Int>, mapGrid: MapGrid) {
        renderer.tileSelectorResource?.showSelection(at: position, mapGrid: mapGrid)
    }

    func addCombatText(_ combatText: MetalCombatText) {
        renderCombatText(combatText)
    }

    func addEffect(_ effect: MetalSkillEffect) {
        renderEffect(effect)
    }

    func playSound(named soundName: String, on objectID: GameObjectID) {
        audioPlayer.playSound(named: soundName)
    }

    func prepareFrame() {
        removeExpiredCombatTexts()
        removeExpiredEffects()
        refreshSpriteDrawables()
        updateCameraTarget()
        syncAndProjectOverlay()
    }

    private func refreshSpriteDrawables() {
        guard let scene else {
            return
        }

        let snapshots = spriteSnapshotBuilder.build(
            items: items,
            scene: scene
        )
        spriteSnapshots = snapshots
        renderer.spriteDrawables = spriteAssetStore?.sync(snapshots: snapshots) ?? []
    }

    private func updateCameraTarget() {
        guard let scene else {
            return
        }

        let targetPosition: SIMD3<Float>
        if let player = scene.objectRegistry.object(for: scene.player.objectID) {
            targetPosition = player.presentation.worldPosition
        } else {
            targetPosition = scene.mapGrid.worldPosition(for: scene.playerPosition)
        }
        renderer.updateCamera(
            cameraState: cameraState,
            targetPosition: targetPosition
        )
    }

    private func syncAndProjectOverlay() {
        guard let scene else {
            return
        }

        for objectID in scene.state.overlay.gauges.keys {
            guard let object = scene.objectRegistry.object(for: objectID) else {
                continue
            }
            var worldPosition = object.presentation.worldPosition
            worldPosition += [0, -0.8, 0]
            scene.state.overlay.gauges[objectID]?.worldPosition = worldPosition

            let screenPosition = project(worldPosition)
            scene.state.overlay.gauges[objectID]?.screenPosition = screenPosition
        }
    }

    private func prepareRenderResources(scene: MetalMapScene, progress: Progress) async throws {
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
        items.removeAll()
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

    private func renderCombatText(_ combatText: MetalCombatText) {
        guard let scene, let combatTextSpriteSet else {
            return
        }

        guard renderer.combatTextResources[combatText.id] == nil else {
            return
        }

        guard let startPosition = spriteSnapshots[combatText.target.objectID]?.worldPosition
            ?? fallbackWorldPosition(for: combatText.target.objectID, scene: scene) else {
            return
        }

        renderer.combatTextResources[combatText.id] = CombatTextRenderResource(
            device: renderer.device,
            combatText: combatText,
            startPosition: startPosition,
            spriteSet: combatTextSpriteSet
        )
    }

    private func renderEffect(_ effect: MetalSkillEffect) {
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

    private func fallbackWorldPosition(for objectID: GameObjectID, scene: MetalMapScene) -> SIMD3<Float>? {
        if let object = scene.objectRegistry.object(for: objectID) {
            return object.presentation.worldPosition
        } else {
            return nil
        }
    }
}
