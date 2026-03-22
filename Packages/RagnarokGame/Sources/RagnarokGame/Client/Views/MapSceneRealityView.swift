//
//  MapSceneRealityView.swift
//  RagnarokGame
//
//  Created by Leon Li on 2026/1/30.
//

import RealityKit
import SwiftUI

#if os(visionOS)

public struct MapSceneRealityView: View {
    public var scene: MapScene
    var backend: RealityKitMapBackend

    @State private var baseDistance: Float = MapCameraState.default.distance

    public var body: some View {
        RealityView { content in
            content.add(backend.rootEntity)
        } update: { content in
        } placeholder: {
            ProgressView()
        }
        .gesture(backend.tileTapGesture)
        .gesture(backend.mapObjectTapGesture)
        .gesture(backend.mapItemTapGesture)
        .gesture(
            MagnifyGesture()
                .onChanged { value in
                    var distance = baseDistance * Float(1 / value.magnification)
                    distance = max(distance, 3)
                    distance = min(distance, 120)
                    scene.cameraState.distance = distance
                }
                .onEnded { value in
                    baseDistance = scene.cameraState.distance
                }
        )
    }

    public init(scene: MapScene) {
        self.scene = scene
        self.backend = scene.realityKitBackend
    }
}

#endif
