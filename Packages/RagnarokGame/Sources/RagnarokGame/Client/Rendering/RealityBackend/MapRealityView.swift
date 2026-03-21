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

    @State private var backend = RealityKitMapBackend()

    public var body: some View {
        #if os(visionOS)
        MapSceneRealityView(scene: scene)
            .onAppear {
                backend.attach(scene: scene)
            }
            .onDisappear {
                backend.detach()
            }
        #else
        MapSceneARView(scene: scene, overlay: overlay, backend: backend)
            .onDisappear {
                backend.detach()
            }
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
