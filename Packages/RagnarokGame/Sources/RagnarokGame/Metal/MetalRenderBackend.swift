//
//  MetalRenderBackend.swift
//  RagnarokGame
//
//  Created by Leon Li on 2026/3/22.
//

import Foundation
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
    private var damageEffectSpriteSet: DamageEffectSpriteSet?

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
            try await prepareRenderResources(scene: scene)

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

        updateObjects(
            player: state.player,
            objects: state.objects,
            items: state.items,
            scene: scene
        )
        updateDamageEffects(state.damageEffects, scene: scene)

        let playerPresentationPosition =
            spriteSnapshots[state.player.id]?.worldPosition
            ?? scene.mapGrid.worldPosition(for: state.player.gridPosition)
        renderer.updateCamera(
            cameraState: scene.cameraState,
            targetPosition: playerPresentationPosition
        )

        renderer.tileSelectorResource?.syncSelection(state.selection, mapGrid: scene.mapGrid)
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

    private func prepareRenderResources(scene: MapScene) async throws {
        let worldAssetLoader = WorldAssetLoader()
        let worldAsset = try await worldAssetLoader.load(
            gat: scene.world.gat,
            gnd: scene.world.gnd,
            rsw: scene.world.rsw,
            resourceManager: resourceManager
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
            damageEffectSpriteSet = try await DamageEffectSpriteSet(resourceManager: resourceManager)
        } catch {
            damageEffectSpriteSet = nil
            logger.warning("Metal backend failed to load damage effect sprites: \(error)")
        }
    }

    private func clearRenderResources() {
        spriteAssetStore?.cancelAllTasks()
        spriteAssetStore = nil
        spriteSnapshots.removeAll()
        damageEffectSpriteSet = nil

        renderer.skyboxResource = nil
        renderer.groundResource = nil
        renderer.waterResource = nil
        renderer.modelResources.removeAll()
        renderer.spriteDrawables.removeAll()
        renderer.damageEffectResources.removeAll()
        renderer.tileSelectorResource = nil
    }

    private func updateObjects(
        player: MapObjectState,
        objects: [GameObjectID : MapObjectState],
        items: [GameObjectID : MapItemState],
        scene: MapScene
    ) {
        let snapshots = spriteSnapshotBuilder.build(
            player: player,
            objects: objects,
            items: items,
            scene: scene
        )
        spriteSnapshots = snapshots
        renderer.spriteDrawables = spriteAssetStore?.sync(snapshots: snapshots) ?? []
    }

    private func updateDamageEffects(_ damageEffects: [MapDamageEffect], scene: MapScene) {
        let activeEffectIDs = Set(damageEffects.map(\.id))
        renderer.damageEffectResources = renderer.damageEffectResources.filter { activeEffectIDs.contains($0.key) }

        guard let damageEffectSpriteSet else {
            return
        }

        for effect in damageEffects where renderer.damageEffectResources[effect.id] == nil {
            guard let startPosition = spriteSnapshots[effect.targetObjectID]?.worldPosition
                ?? fallbackWorldPosition(for: effect.targetObjectID, scene: scene) else {
                continue
            }

            let targetObjectType = if effect.targetObjectID == scene.state.player.id {
                scene.state.player.object.type
            } else {
                scene.state.objects[effect.targetObjectID]?.object.type
            }

            let resolvedTarget = DamageEffectRenderResource.ResolvedTarget(
                startPosition: startPosition,
                isPlayerTarget: targetObjectType == .pc
            )

            renderer.damageEffectResources[effect.id] = DamageEffectRenderResource(
                device: renderer.device,
                effect: effect,
                resolvedTarget: resolvedTarget,
                spriteSet: damageEffectSpriteSet
            )
        }
    }

    private func fallbackWorldPosition(for objectID: GameObjectID, scene: MapScene) -> SIMD3<Float>? {
        if let gridPosition = scene.state.object(for: objectID)?.gridPosition {
            return scene.mapGrid.worldPosition(for: gridPosition)
        } else {
            return nil
        }
    }
}
