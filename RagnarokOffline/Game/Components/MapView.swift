//
//  MapView.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/9/10.
//

import RONetwork
import RORendering
import SwiftUI

struct MapView: View {
    var mapSession: MapSession
    var mapName: String
    var world: WorldResource
    var position: SIMD2<Int16>

    var body: some View {
        MapSceneView(mapSession: mapSession, mapName: mapName, world: world, position: position)
            .overlay(alignment: .topLeading) {
                PlayerStatusOverlayView(mapSession: mapSession)
            }
            .overlay {
                NPCDialogOverlayView(mapSession: mapSession)
            }
    }
}

//#Preview {
//    struct AsyncMapView: View {
//        @State private var scene: GameMapScene?
//
//        @Environment(\.gameSession) private var gameSession
//
//        var body: some View {
//            ZStack {
//                if let scene {
//                    MapView(scene: scene)
//                } else {
//                    ProgressView()
//                }
//            }
//            .task {
//                let map = try! await MapDatabase.renewal.map(forName: "iz_int")!
//                let grid = map.grid()!
//                self.scene = GameMapScene(name: "iz_int", grid: grid, position: [18, 26])
//            }
//        }
//    }
//
//    return AsyncMapView()
//}
