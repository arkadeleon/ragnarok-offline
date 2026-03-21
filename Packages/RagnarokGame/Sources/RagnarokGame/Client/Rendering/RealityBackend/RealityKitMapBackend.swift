//
//  RealityKitMapBackend.swift
//  RagnarokGame
//
//  Created by Leon Li on 2026/3/21.
//

import CoreGraphics
import RealityKit

@MainActor
final class RealityKitMapBackend: MapRenderBackend {
    private(set) var scene: MapScene?
    var overlay: MapSceneOverlay?

    #if os(iOS) || os(macOS)
    private var realityMapProjector: RealityMapProjector?
    private var realityMapHitTester: RealityMapHitTester?
    #endif

    var projector: (any MapProjector)? {
        #if os(iOS) || os(macOS)
        realityMapProjector
        #else
        nil
        #endif
    }

    func attach(scene: MapScene) {
        self.scene = scene
    }

    func detach() {
        scene = nil
        overlay = nil
        #if os(iOS) || os(macOS)
        realityMapProjector = nil
        realityMapHitTester = nil
        #endif
    }

    func applySnapshot(_ state: MapSceneState) {
        // No-op in Phase 7. Entity tree is still updated directly by MapScene.
    }

    func hitTest(at screenPoint: CGPoint) -> MapHitTestResult? {
        #if os(iOS) || os(macOS)
        realityMapHitTester?.hitTest(at: screenPoint)
        #else
        nil
        #endif
    }

    #if os(iOS) || os(macOS)
    func configure(arView: ARView) {
        guard let scene else {
            return
        }
        realityMapProjector = RealityMapProjector(arView: arView)
        realityMapHitTester = RealityMapHitTester(arView: arView, scene: scene)
    }

    /// Syncs overlay anchor positions from the RealityKit entity tree and projects them to
    /// screen coordinates. Called every render frame by the hosting view controller.
    func syncAndProjectOverlay() {
        guard let scene, let arView = realityMapProjector?.arView else {
            return
        }

        let query = EntityQuery(where: .has(HealthPointsComponent.self))
        for entity in arView.scene.performQuery(query) {
            guard let mapObject = entity.components[MapObjectComponent.self]?.mapObject,
                  scene.state.overlaySnapshot.anchors[mapObject.objectID] != nil else {
                continue
            }
            let worldPosition = entity.position(relativeTo: nil)
            scene.state.overlaySnapshot.anchors[mapObject.objectID]?.gaugePosition = worldPosition + [0, -0.8, 0]
        }

        guard let overlay, let projector = realityMapProjector else {
            return
        }

        var gauges: [UInt32 : MapSceneOverlay.Gauge] = [:]
        for anchor in scene.state.overlaySnapshot.anchors.values {
            guard let gaugePosition = anchor.gaugePosition,
                  let screenPoint = projector.project(gaugePosition) else {
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
    #endif
}
