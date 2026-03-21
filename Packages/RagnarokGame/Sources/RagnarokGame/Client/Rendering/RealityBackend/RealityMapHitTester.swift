//
//  RealityMapHitTester.swift
//  RagnarokGame
//
//  Created by Leon Li on 2026/3/21.
//

#if os(iOS) || os(macOS)

import CoreGraphics
import RealityKit

@MainActor
final class RealityMapHitTester {
    private weak var arView: ARView?
    private weak var scene: MapScene?

    init(arView: ARView, scene: MapScene) {
        self.arView = arView
        self.scene = scene
    }

    func hitTest(at screenPoint: CGPoint) -> MapHitTestResult? {
        // Phase 7: placeholder. Hit testing still happens through gesture handlers
        // in MapSceneARViewController. This will be wired in Phase 8.
        nil
    }
}

#endif
