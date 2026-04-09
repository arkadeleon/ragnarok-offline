//
//  MetalRenderBackend.swift
//  RagnarokGame
//
//  Created by Leon Li on 2026/3/22.
//

import AVFAudio
import CoreGraphics
import Foundation
import RagnarokRenderAssets
import RagnarokResources

final class MetalRenderBackend: GameRenderBackend {
    private(set) weak var scene: MapScene?

    let resourceManager: ResourceManager
    let renderer: MapRuntimeRenderer

    private let metalMapProjector = MetalMapProjector()
    private let metalMapHitTester = MetalMapHitTester()
    private var bgmPlayer: AVAudioPlayer?

    var projector: (any MapProjector)? {
        metalMapProjector
    }

    init(resourceManager: ResourceManager) {
        self.resourceManager = resourceManager
        self.renderer = MapRuntimeRenderer(resourceManager: resourceManager)
    }

    func attach(scene: MapScene) {
        self.scene = scene
        metalMapProjector.configure(renderer: renderer)
        metalMapHitTester.configure(renderer: renderer, scene: scene)
        syncFrameState(with: scene.state)
    }

    func detach() {
        bgmPlayer?.stop()
        bgmPlayer = nil
        scene = nil
        renderer.setWorldAsset(nil)
    }

    func load(progress: Progress) async {
        guard let scene else {
            return
        }

        renderer.setWorldAsset(nil)

        let worldAssetLoader = WorldAssetLoader()

        do {
            let worldAsset = try await worldAssetLoader.load(
                gat: scene.world.gat,
                gnd: scene.world.gnd,
                rsw: scene.world.rsw,
                resourceManager: scene.resourceManager
            )
            guard !Task.isCancelled, self.scene === scene else {
                return
            }

            renderer.setWorldAsset(worldAsset)

            let skyboxConfiguration = SkyboxConfiguration.generate(
                light: scene.world.rsw.light,
                mapWidth: scene.mapGrid.width,
                mapHeight: scene.mapGrid.height
            )
            renderer.setSkyboxConfiguration(skyboxConfiguration)

            bgmPlayer?.stop()
            bgmPlayer = await loadBGMPlayer(forMapName: scene.mapName)
            bgmPlayer?.numberOfLoops = -1
            bgmPlayer?.play()

            syncFrameState(with: scene.state)
            await renderer.prepareDynamicRenderers()
        } catch is CancellationError {
            return
        } catch {
            logger.warning("Metal map backend failed to load world asset: \(error)")
        }
    }

    func unload() {
        bgmPlayer?.stop()
        bgmPlayer = nil
    }

    func applySnapshot(_ state: MapSceneState) {
        syncFrameState(with: state)
    }

    func hitTest(at screenPoint: CGPoint) -> MapHitTestResult? {
        metalMapHitTester.hitTest(at: screenPoint)
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

    private func loadBGMPlayer(forMapName mapName: String) async -> AVAudioPlayer? {
        let mp3NameTable = await resourceManager.mp3NameTable()
        guard let mp3Name = mp3NameTable.mp3Name(forMapName: mapName) else {
            return nil
        }

        let bgmPath = ResourcePath(components: ["BGM", mp3Name])
        guard let bgmData = try? await resourceManager.contentsOfResource(at: bgmPath) else {
            return nil
        }

        return try? AVAudioPlayer(data: bgmData)
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

            let screenPosition = metalMapProjector.project(worldPosition)
            scene.state.overlay.gauges[objectID]?.screenPosition = screenPosition
        }
    }
}
