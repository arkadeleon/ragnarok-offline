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

struct MetalMapObjectState {
    var object: MapSceneObject
    var gridPosition: SIMD2<Int>
    var animation: MapObjectAnimationState
    var movement: MapObjectMovementState?
}

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

    private var objectStates: [GameObjectID : MetalMapObjectState] = [:]
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

    func addObject(_ object: MapSceneObject, at gridPosition: SIMD2<Int>, direction: SpriteDirection, headDirection: SpriteHeadDirection) {
        let animation = MapObjectAnimationState(
            action: .idle,
            direction: direction,
            headDirection: headDirection,
            startTime: .now,
            completion: .indefinite
        )
        objectStates[object.objectID] = MetalMapObjectState(
            object: object,
            gridPosition: gridPosition,
            animation: animation,
            movement: nil
        )
        refreshSpriteDrawables()
    }

    func updateObject(_ object: MapSceneObject) {
        guard var objectState = objectStates[object.objectID] else {
            return
        }

        objectState.object = object
        objectStates[object.objectID] = objectState
        refreshSpriteDrawables()
    }

    func moveObject(objectID: GameObjectID, startPosition: SIMD2<Int>, endPosition: SIMD2<Int>) -> MapObjectMovementState? {
        let now = ContinuousClock.now

        guard let scene, var objectState = objectStates[objectID] else {
            return nil
        }

        let speed = objectState.object.speed
        let planner = MapObjectMovementPlanner(pathFinder: scene.pathFinder)
        var movement = planner.replan(
            existingMovement: objectState.movement,
            incomingStartPosition: startPosition,
            incomingEndPosition: endPosition,
            speed: speed,
            at: now
        )
        movement.updateWorldPath { scene.mapGrid.worldPosition(for: $0) }

        let remainingDuration = movement.remainingDuration(at: now)
        objectState.gridPosition = endPosition
        objectState.animation = MapObjectAnimationState(
            action: .walk,
            direction: movement.finalDirection,
            headDirection: objectState.animation.headDirection,
            startTime: now,
            completion: .after(remainingDuration, settledAction: .idle)
        )
        objectState.movement = movement
        objectStates[objectID] = objectState

        refreshSpriteDrawables()
        if objectID == scene.state.playerID {
            updateCameraTarget()
        }

        return movement
    }

    func stopObject(objectID: GameObjectID, at position: SIMD2<Int>) {
        if var objectState = objectStates[objectID] {
            objectState.gridPosition = position
            objectState.animation.action = .idle
            objectState.animation.startTime = .now
            objectState.animation.completion = .indefinite
            objectState.movement = nil
            objectStates[objectID] = objectState
        }

        refreshSpriteDrawables()
        if objectID == scene?.state.playerID {
            updateCameraTarget()
        }
    }

    func turnObject(objectID: GameObjectID, direction: SpriteDirection, headDirection: SpriteHeadDirection) {
        guard var objectState = objectStates[objectID] else {
            return
        }

        objectState.animation.direction = direction
        objectState.animation.headDirection = headDirection
        objectStates[objectID] = objectState
        refreshSpriteDrawables()
    }

    func performObjectAction(objectID: GameObjectID, action: SpriteActionType, completion: MapObjectAnimationCompletion) {
        guard var objectState = objectStates[objectID] else {
            return
        }

        objectState.animation.action = action
        objectState.animation.startTime = .now
        objectState.animation.completion = completion
        objectStates[objectID] = objectState
        refreshSpriteDrawables()
    }

    func removeObject(objectID: GameObjectID) {
        objectStates.removeValue(forKey: objectID)
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

    func gridPosition(for objectID: GameObjectID) -> SIMD2<Int>? {
        guard let objectState = objectStates[objectID] else {
            return nil
        }

        return objectState.movement?.nextPosition(at: .now) ?? objectState.gridPosition
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
            objects: &objectStates,
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
            ?? gridPosition(for: scene.state.playerID).map { scene.mapGrid.worldPosition(for: $0) }
            ?? scene.mapGrid.worldPosition(for: scene.playerPosition)
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
        if let gridPosition = objectStates[objectID]?.gridPosition {
            return scene.mapGrid.worldPosition(for: gridPosition)
        } else {
            return nil
        }
    }
}
