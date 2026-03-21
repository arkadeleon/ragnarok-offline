//
//  MapRenderHost.swift
//  RagnarokGame
//
//  Created by Leon Li on 2026/3/20.
//

import SwiftUI

struct MapRenderHost: View {
    var scene: MapScene
    var configuration: MapRenderConfiguration
    var overlay: MapSceneOverlay?

    var body: some View {
        switch configuration.engine {
        case .metal:
            renderSurface
        case .realityKit:
            renderSurface
        }
    }

    private var renderSurface: some View {
        #if os(visionOS)
        Text("Game")
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        #else
        MapRealityView(scene: scene, overlay: overlay)
        #endif
    }
}
