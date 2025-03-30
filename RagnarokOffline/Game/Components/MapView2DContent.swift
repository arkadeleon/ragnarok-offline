//
//  MapView2DContent.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2025/3/27.
//

import SpriteKit
import SwiftUI

struct MapView2DContent: View {
    var scene: MapScene2D

    var body: some View {
        SpriteView(scene: scene)
    }
}

//#Preview {
//    struct AsyncMapView: View {
//        @State private var scene: MapScene2D?
//
//        var body: some View {
//            ZStack {
//                if let scene {
//                    MapView2D(mapSession: <#T##MapSession#>, scene: scene)
//                } else {
//                    ProgressView()
//                }
//            }
//            .task {
//                let world = try! await ResourceManager.default.world(at: ["data", "iz_int"])
//                self.scene = MapScene2D(mapName: "iz_int", world: world, position: [18, 26])
//            }
//        }
//    }
//
//    return AsyncMapView()
//}
