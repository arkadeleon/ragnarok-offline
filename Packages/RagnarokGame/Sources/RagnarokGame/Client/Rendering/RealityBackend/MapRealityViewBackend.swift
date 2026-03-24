//
//  MapRealityViewBackend.swift
//  RagnarokGame
//
//  Created by Leon Li on 2026/3/24.
//

import RealityKit

@MainActor
protocol MapRealityViewBackend: MapRenderBackend {
    var rootEntity: Entity { get }
    var overlay: MapSceneOverlay? { get set }

    #if os(iOS) || os(macOS)
    func configure(arView: ARView)
    func syncAndProjectOverlay()
    #endif
}
