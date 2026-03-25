//
//  MetalMapBackend.swift
//  RagnarokGame
//
//  Created by Leon Li on 2026/3/22.
//

#if os(iOS) || os(macOS)

import CoreGraphics
import Foundation
import RagnarokSceneAssets

final class MetalMapBackend: MapRenderBackend {
    private(set) weak var scene: MapScene?

    let renderer: MapRuntimeRenderer

    var overlay: MapSceneOverlay?

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
        overlay = nil
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

        renderer.syncSelection(state.selection.selectedPosition, mapGrid: scene.mapGrid)
    }

    private func syncAndProjectOverlay() {
        guard let scene else {
            return
        }

        if let worldPosition = renderer.presentationWorldPosition(for: scene.state.player.id) {
            scene.state.overlaySnapshot.anchors[scene.state.player.id]?.gaugePosition =
                worldPosition + [0, -0.8, 0]
        }
        for (objectID, _) in scene.state.objects {
            if let worldPosition = renderer.presentationWorldPosition(for: objectID) {
                scene.state.overlaySnapshot.anchors[objectID]?.gaugePosition =
                    worldPosition + [0, -0.8, 0]
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
}

#endif
