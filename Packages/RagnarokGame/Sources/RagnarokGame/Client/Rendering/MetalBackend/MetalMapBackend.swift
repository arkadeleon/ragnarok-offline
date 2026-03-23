//
//  MetalMapBackend.swift
//  RagnarokGame
//
//  Created by Leon Li on 2026/3/22.
//

#if os(iOS) || os(macOS)

import CoreGraphics
import RagnarokSceneAssets

final class MetalMapBackend: MapRenderBackend {
    private(set) weak var scene: MapScene?

    let renderer: MapRuntimeRenderer

    private let metalMapProjector = MetalMapProjector()
    private let metalMapHitTester = MetalMapHitTester()
    private var worldLoadTask: Task<Void, Never>?

    var projector: (any MapProjector)? {
        metalMapProjector
    }

    init() {
        self.renderer = MapRuntimeRenderer()
    }

    func attach(scene: MapScene) {
        self.scene = scene
        syncFrameState(with: scene.state)
        loadWorldAssetIfNeeded(for: scene)
    }

    func detach() {
        worldLoadTask?.cancel()
        worldLoadTask = nil
        scene = nil
        renderer.setWorldAsset(nil)
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
    }

    private func loadWorldAssetIfNeeded(for scene: MapScene) {
        worldLoadTask?.cancel()
        renderer.setWorldAsset(nil)

        worldLoadTask = Task { [weak self, weak scene] in
            guard let self, let scene else {
                return
            }

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
            } catch is CancellationError {
                return
            } catch {
                logger.warning("Metal map backend failed to load world asset: \(error)")
            }
        }
    }

    private func syncFrameState(with state: MapSceneState) {
        guard let scene else {
            return
        }

        renderer.updateCamera(
            cameraState: scene.cameraState,
            targetPosition: scene.position(for: state.player.gridPosition)
        )
    }
}

#endif
