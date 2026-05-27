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

    private var objectStates: [GameObjectID : MapSceneObject] = [:]
    private var objectMovements: [GameObjectID : MapObjectMovementState] = [:]
    private var objectPresentations: [GameObjectID : MapObjectPresentationState] = [:]
    private var itemStates: [GameObjectID : MapSceneItem] = [:]
    private var cameraState: MapCameraState = .default

    init(resourceManager: ResourceManager) throws {
        self.resourceManager = resourceManager
        self.renderer = try MetalMapRenderer()
        self.audioPlayer = MetalMapAudioPlayer(resourceManager: resourceManager)
    }

    func attach(scene: MapScene) {
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

    func addObject(_ object: MapSceneObject, direction: SpriteDirection, headDirection: SpriteHeadDirection) {
        objectStates[object.objectID] = object
        objectPresentations[object.objectID] = MapObjectPresentationState(
            action: .idle,
            direction: direction,
            headDirection: headDirection,
            startTime: .now,
            completion: .indefinite
        )
        refreshSpriteDrawables()
    }

    func updateObject(_ object: MapSceneObject) {
        objectStates[object.objectID] = object
        refreshSpriteDrawables()
    }

    func moveObject(_ command: MapObjectMoveCommand) -> MapObjectMovementState? {
        guard let scene else {
            return nil
        }

        let planner = MapObjectMovementPlanner(pathFinder: scene.pathFinder)
        let movement = planner.replan(
            existingMovement: objectMovements[command.objectID],
            existingSpeed: objectStates[command.objectID]?.speed,
            incomingStartPosition: command.startPosition,
            incomingEndPosition: command.endPosition,
            incomingSpeed: command.speed,
            at: command.startedAt
        )
        objectMovements[command.objectID] = movement

        let remainingDuration = movement.remainingDuration(at: command.startedAt)
        let currentHeadDirection = objectPresentations[command.objectID]?.headDirection ?? .lookForward
        objectPresentations[command.objectID] = MapObjectPresentationState(
            action: .walk,
            direction: movement.finalDirection,
            headDirection: currentHeadDirection,
            startTime: command.startedAt,
            completion: .after(remainingDuration, settledAction: .idle)
        )

        refreshSpriteDrawables()
        if command.objectID == scene.state.playerID {
            updateCameraTarget()
        }

        return movement
    }

    func stopObject(objectID: GameObjectID, at position: SIMD2<Int>) {
        objectMovements.removeValue(forKey: objectID)
        if objectStates[objectID] != nil {
            objectStates[objectID]?.gridPosition = position
        }

        if var presentation = objectPresentations[objectID] {
            presentation.action = .idle
            presentation.startTime = .now
            presentation.completion = .indefinite
            objectPresentations[objectID] = presentation
        }

        refreshSpriteDrawables()
        if objectID == scene?.state.playerID {
            updateCameraTarget()
        }
    }

    func turnObject(objectID: GameObjectID, direction: SpriteDirection, headDirection: SpriteHeadDirection) {
        guard objectStates[objectID] != nil else {
            return
        }
        if var presentation = objectPresentations[objectID] {
            presentation.direction = direction
            presentation.headDirection = headDirection
            objectPresentations[objectID] = presentation
        }
        refreshSpriteDrawables()
    }

    func performObjectAction(_ command: MapObjectPresentationCommand) {
        guard objectStates[command.objectID] != nil else {
            return
        }
        if var presentation = objectPresentations[command.objectID] {
            presentation.action = command.action
            presentation.startTime = command.startTime
            presentation.completion = command.completion
            objectPresentations[command.objectID] = presentation
        }
        refreshSpriteDrawables()
    }

    func removeObject(objectID: GameObjectID) {
        objectStates.removeValue(forKey: objectID)
        objectMovements.removeValue(forKey: objectID)
        objectPresentations.removeValue(forKey: objectID)
        spriteSnapshots.removeValue(forKey: objectID)
        refreshSpriteDrawables()
    }

    func addItem(_ item: MapSceneItem) {
        itemStates[item.objectID] = item
        refreshSpriteDrawables()
    }

    func removeItem(objectID: GameObjectID) {
        itemStates.removeValue(forKey: objectID)
        spriteSnapshots.removeValue(forKey: objectID)
        refreshSpriteDrawables()
    }

    func presentationGridPosition(for objectID: GameObjectID) -> SIMD2<Int>? {
        if let movement = objectMovements[objectID],
           let speed = objectStates[objectID]?.speed,
           let nextPosition = movement.nextPosition(speed: speed, at: .now) {
            return nextPosition
        }
        return objectStates[objectID]?.gridPosition
    }

    func showSelection(at position: SIMD2<Int>, mapGrid: MapGrid) {
        renderer.tileSelectorResource?.showSelection(at: position, mapGrid: mapGrid)
    }

    func addCombatText(_ combatText: MapSceneCombatText) {
        renderCombatText(combatText)
    }

    func addEffect(_ effect: MapSceneEffect) {
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
            objects: objectStates,
            movements: objectMovements,
            presentations: objectPresentations,
            items: itemStates,
            scene: scene
        )
        spriteSnapshots = snapshots
        renderer.spriteDrawables = spriteAssetStore?.sync(snapshots: snapshots) ?? []
    }

    private func updateCameraTarget() {
        guard let scene else {
            return
        }

        let targetPosition = spriteSnapshots[scene.state.playerID]?.worldPosition
            ?? scene.mapGrid.worldPosition(for: scene.state.player.gridPosition)
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
        objectStates.removeAll()
        objectMovements.removeAll()
        objectPresentations.removeAll()
        itemStates.removeAll()
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

    private func renderCombatText(_ combatText: MapSceneCombatText) {
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

    private func renderEffect(_ effect: MapSceneEffect) {
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
