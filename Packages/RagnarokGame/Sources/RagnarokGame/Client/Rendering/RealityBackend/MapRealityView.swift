//
//  MapRealityView.swift
//  RagnarokGame
//
//  Created by Leon Li on 2026/3/21.
//

import SwiftUI

public struct MapRealityView: View {
    var scene: MapScene
    var overlay: MapSceneOverlay?

    public var body: some View {
        #if os(visionOS)
        MapSceneRealityView(scene: scene)
        #else
        MapSceneARView(scene: scene, overlay: overlay, backend: scene.realityKitBackend)
        #endif
    }

    public init(scene: MapScene) {
        self.scene = scene
        self.overlay = nil
    }

    init(scene: MapScene, overlay: MapSceneOverlay?) {
        self.scene = scene
        self.overlay = overlay
    }
}
