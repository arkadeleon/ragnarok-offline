//
//  MapSceneView.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2025/7/2.
//

import SwiftUI

public struct MapSceneView: View {
    public var scene: any MapSceneProtocol

    public var body: some View {
        switch scene {
        case let scene as MapScene2D:
            MapScene2DView(scene: scene)
        case let scene as MapScene3D:
            MapScene3DView(scene: scene)
        default:
            EmptyView()
        }
    }

    public init(scene: any MapSceneProtocol) {
        self.scene = scene
    }
}
