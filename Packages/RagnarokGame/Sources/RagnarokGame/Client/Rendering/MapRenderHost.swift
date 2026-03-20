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

    #if !os(visionOS)
    var onSceneUpdate: (any MapProjector) -> Void
    #endif

    var body: some View {
        switch configuration.engine {
        case .metal:
            metalSurface
        case .realityKit:
            realityKitSurface
        }
    }

    private var metalSurface: some View {
        #if os(visionOS)
        Text("Game")
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        #else
        MapSceneARView(scene: scene, onSceneUpdate: onSceneUpdate)
        #endif
    }

    private var realityKitSurface: some View {
        #if os(visionOS)
        Text("Game")
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        #else
        MapSceneARView(scene: scene, onSceneUpdate: onSceneUpdate)
        #endif
    }
}
