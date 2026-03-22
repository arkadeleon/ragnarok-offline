//
//  MetalMapBackend.swift
//  RagnarokGame
//
//  Created by Leon Li on 2026/3/22.
//

#if os(iOS) || os(macOS)

import CoreGraphics

final class MetalMapBackend: MapRenderBackend {
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
    }

    func detach() {
        scene = nil
    }

    func applySnapshot(_ state: MapSceneState) {
    }

    func hitTest(at screenPoint: CGPoint) -> MapHitTestResult? {
        metalMapHitTester.hitTest(at: screenPoint)
    }
}

#endif
