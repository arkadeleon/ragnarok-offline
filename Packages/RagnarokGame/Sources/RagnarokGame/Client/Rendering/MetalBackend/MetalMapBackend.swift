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

    var overlay: MapSceneOverlay?

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
        metalMapProjector.configure(renderer: renderer)
        metalMapHitTester.configure(renderer: renderer, scene: scene)
        syncFrameState(with: scene.state)
        loadWorldAssetIfNeeded(for: scene)
    }

    func detach() {
        worldLoadTask?.cancel()
        worldLoadTask = nil
        scene = nil
        overlay = nil
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
        syncAndProjectOverlay()
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

                Task { [weak self, weak scene] in
                    guard let self, let scene else {
                        return
                    }
                    await renderer.prepareDynamicRenderers(resourceManager: scene.resourceManager)
                }
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

        renderer.updateObjects(
            player: state.player,
            objects: state.objects,
            items: state.items,
            scene: scene,
            resourceManager: scene.resourceManager
        )

        renderer.syncSelection(state.selection.selectedPosition, mapGrid: scene.mapGrid)
    }

    private func syncAndProjectOverlay() {
        guard let scene else {
            return
        }

        if let gridPosition = gridPosition(for: scene.state.player.id, in: scene.state) {
            scene.state.overlaySnapshot.anchors[scene.state.player.id]?.gaugePosition =
                scene.position(for: gridPosition) + [0, -0.8, 0]
        }
        for (objectID, _) in scene.state.objects {
            if let gridPosition = gridPosition(for: objectID, in: scene.state) {
                scene.state.overlaySnapshot.anchors[objectID]?.gaugePosition =
                    scene.position(for: gridPosition) + [0, -0.8, 0]
            }
        }

        guard let overlay else {
            return
        }

        var gauges: [UInt32 : MapSceneOverlay.Gauge] = [:]
        for anchor in scene.state.overlaySnapshot.anchors.values {
            guard let gaugePosition = anchor.gaugePosition,
                  let screenPoint = metalMapProjector.project(gaugePosition) else {
                continue
            }

            gauges[anchor.id] = MapSceneOverlay.Gauge(
                objectID: anchor.id,
                hp: anchor.hp,
                maxHp: anchor.maxHp,
                sp: anchor.sp,
                maxSp: anchor.maxSp,
                objectType: anchor.objectType,
                screenPosition: screenPoint
            )
        }
        overlay.gauges = gauges
    }

    private func gridPosition(for objectID: UInt32, in state: MapSceneState) -> SIMD2<Int>? {
        if objectID == state.player.id {
            return state.player.gridPosition
        }
        return state.objects[objectID]?.gridPosition
    }
}

#endif
