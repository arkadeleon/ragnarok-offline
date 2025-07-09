//
//  MapScene3DView.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/9/10.
//

import RealityKit
import SwiftUI

struct MapScene3DView: View {
    var scene: MapScene3D

    @State private var distance: Float = 80

    var body: some View {
        RealityView { content in
            content.add(scene.rootEntity)
        } update: { content in
        } placeholder: {
            ProgressView()
        }
        .ignoresSafeArea()
        .overlay(alignment: .bottom) {
            Slider(value: $distance, in: 2...300)
                .onChange(of: distance) {
                    scene.distance = distance
                }
        }
        .gesture(scene.tileTapGesture)
        .gesture(scene.mapObjectTapGesture)
        .gesture(scene.mapItemTapGesture)
        .onDisappear {
            scene.unload()
        }
    }
}
