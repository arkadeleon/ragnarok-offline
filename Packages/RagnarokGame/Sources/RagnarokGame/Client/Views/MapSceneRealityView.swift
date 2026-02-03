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

    @State private var distance: Float = 100

    public var body: some View {
        RealityView { content in
            content.add(scene.rootEntity)
        } update: { content in
        } placeholder: {
            ProgressView()
        }
        .gesture(scene.tileTapGesture)
        .gesture(scene.mapObjectTapGesture)
        .gesture(scene.mapItemTapGesture)
        .gesture(
            MagnifyGesture()
                .onChanged { value in
                    var distance = distance * Float(1 / value.magnification)
                    distance = max(distance, 3)
                    distance = min(distance, 120)
                    scene.distance = distance
                }
                .onEnded { value in
                    distance = scene.distance
                }
        )
    }

    public init(scene: MapScene) {
        self.scene = scene
    }
}

#endif
