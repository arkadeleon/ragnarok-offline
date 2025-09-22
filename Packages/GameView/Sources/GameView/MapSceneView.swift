//
//  MapSceneView.swift
//  GameView
//
//  Created by Leon Li on 2025/8/7.
//

import GameCore
import RealityKit
import SwiftUI

public struct MapSceneView: View {
    public var scene: MapScene

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
    }

    public init(scene: MapScene) {
        self.scene = scene
    }
}
