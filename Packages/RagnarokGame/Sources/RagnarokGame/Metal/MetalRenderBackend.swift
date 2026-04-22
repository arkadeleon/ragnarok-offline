//
//  MetalRenderBackend.swift
//  RagnarokGame
//
//  Created by Leon Li on 2026/3/22.
//

import Foundation
import RagnarokRenderAssets
import RagnarokResources

final class MetalRenderBackend: GameRenderBackend {
    private(set) weak var scene: MapScene?

    let resourceManager: ResourceManager

    let renderer: MetalMapRenderer
    let audioPlayer: MetalMapAudioPlayer

    init(resourceManager: ResourceManager) throws {
        self.resourceManager = resourceManager
        self.renderer = try MetalMapRenderer(resourceManager: resourceManager)
        self.audioPlayer = MetalMapAudioPlayer(resourceManager: resourceManager)
    }

    func attach(scene: MapScene) {
        self.scene = scene
        syncFrameState(with: scene.state)
    }

    func detach() {
        audioPlayer.stopAll()
        scene = nil
    }

    func load(progress: Progress) async {
        guard let scene else {
            return
        }

        do {
            let worldAssetLoader = WorldAssetLoader()
            let worldAsset = try await worldAssetLoader.load(
                gat: scene.world.gat,
                gnd: scene.world.gnd,
                rsw: scene.world.rsw,
                resourceManager: scene.resourceManager
            )
            let skyboxConfiguration = SkyboxConfiguration.generate(
                light: scene.world.rsw.light,
                mapWidth: scene.mapGrid.width,
                mapHeight: scene.mapGrid.height
            )
            await renderer.prepareRenderResources(worldAsset: worldAsset, skyboxConfiguration: skyboxConfiguration)

            await audioPlayer.playBGM(forMapName: scene.mapName)

            syncFrameState(with: scene.state)
        } catch {
            logger.warning("Metal map backend failed to load world asset: \(error)")
        }
    }

    func unload() {
        audioPlayer.stopAll()
        renderer.spriteAssetStore?.cancelAllTasks()
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

        renderer.updateObjects(
            player: state.player,
            objects: state.objects,
            items: state.items,
            scene: scene
        )
        renderer.updateDamageEffects(state.damageEffects, scene: scene)

        let playerPresentationPosition =
            renderer.presentationWorldPosition(for: state.player.id)
            ?? scene.position(for: state.player.gridPosition)
        renderer.updateCamera(
            cameraState: scene.cameraState,
            targetPosition: playerPresentationPosition
        )

        renderer.syncSelection(state.selection, mapGrid: scene.mapGrid)
    }

    private func syncAndProjectOverlay() {
        guard let scene else {
            return
        }

        for objectID in scene.state.overlay.gauges.keys {
            guard var worldPosition = renderer.presentationWorldPosition(for: objectID) else {
                continue
            }

            worldPosition += [0, -0.8, 0]
            scene.state.overlay.gauges[objectID]?.worldPosition = worldPosition

            let screenPosition = project(worldPosition)
            scene.state.overlay.gauges[objectID]?.screenPosition = screenPosition
        }
    }
}
