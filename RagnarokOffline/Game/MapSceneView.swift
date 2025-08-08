//
//  MapSceneView.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2025/8/7.
//

import RealityKit
import ROGame
import SwiftUI

struct MapSceneView: View {
    var scene: MapScene

    var body: some View {
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
    }
}
