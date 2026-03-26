//
//  MetalRenderBackend.swift
//  RagnarokGame
//
//  Created by Leon Li on 2026/3/22.
//

import CoreGraphics
import Foundation
import RagnarokSceneAssets

final class MetalRenderBackend: GameRenderBackend {
    private(set) weak var scene: MapScene?

    let renderer: MapRuntimeRenderer

    private let metalMapProjector = MetalMapProjector()
    private let metalMapHitTester = MetalMapHitTester()

    var projector: (any MapProjector)? {
        metalMapProjector
    }

    init() {
        self.renderer = MapRuntimeRenderer()
    }

    func attach(scene: MapScene) {
        self.scene = scene
        metalMapProjector.configure(renderer: renderer)
        metalMapHitTester.configure(renderer: renderer, scene: scene)
        syncFrameState(with: scene.state)
    }

    func detach() {
        scene = nil
        renderer.setWorldAsset(nil)
    }

    func load(progress: Progress) async {
        guard let scene else {
            return
        }

        renderer.setWorldAsset(nil)

        let loader = MapWorldAssetLoader()

        do {
            let worldAsset = try await loader.load(
                gat: scene.world.gat,
                gnd: scene.world.gnd,
                rsw: scene.world.rsw,
                resourceManager: scene.resourceManager
            )
            guard !Task.isCancelled, self.scene === scene else {
                return
            }

            renderer.setWorldAsset(worldAsset)
            syncFrameState(with: scene.state)
            await renderer.prepareDynamicRenderers(resourceManager: scene.resourceManager)
        } catch is CancellationError {
            return
        } catch {
            logger.warning("Metal map backend failed to load world asset: \(error)")
        }
    }

    func unload() {
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
            scene: scene,
            resourceManager: scene.resourceManager
        )

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

            let screenPosition = metalMapProjector.project(worldPosition)
            scene.state.overlay.gauges[objectID]?.screenPosition = screenPosition
        }
    }
}
