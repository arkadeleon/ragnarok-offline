//
//  MapRealityView.swift
//  RagnarokGame
//
//  Created by Leon Li on 2026/3/21.
//

#if os(visionOS)
import RealityKit
#endif
import SwiftUI

public struct MapRealityView: View {
    var scene: MapScene
    var overlay: MapSceneOverlay?

    #if os(visionOS)
    @State private var baseDistance: Float = MapCameraState.default.distance
    #endif

    public var body: some View {
        #if os(visionOS)
        RealityView { content in
            content.add(scene.realityKitBackend.rootEntity)
        } update: { _ in
        } placeholder: {
            ProgressView()
        }
        .gesture(scene.realityKitBackend.tileTapGesture)
        .gesture(scene.realityKitBackend.mapObjectTapGesture)
        .gesture(scene.realityKitBackend.mapItemTapGesture)
        .gesture(
            MagnifyGesture()
                .onChanged { value in
                    var distance = baseDistance * Float(1 / value.magnification)
                    distance = max(distance, 3)
                    distance = min(distance, 120)
                    scene.cameraState.distance = distance
                }
                .onEnded { _ in
                    baseDistance = scene.cameraState.distance
                }
        )
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
