//
//  MapSceneView.swift
//  GameView
//
//  Created by Leon Li on 2025/8/7.
//

import RealityKit
import SwiftUI

public struct MapSceneView: View {
    public var scene: MapScene

    @State private var distance: Float = 80

    public var body: some View {
        RealityView { content in
            content.add(scene.rootEntity)
        } update: { content in
        } placeholder: {
            ProgressView()
        }
        .ignoresSafeArea()
        .gesture(scene.tileTapGesture)
        .gesture(scene.mapObjectTapGesture)
        .gesture(scene.mapItemTapGesture)
        .gesture(
            MagnifyGesture()
                .onChanged { value in
                    var distance = distance * Float(1 / value.magnification)
                    distance = max(distance, 3)
                    distance = min(distance, 100)
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
