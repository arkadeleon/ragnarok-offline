//
//  MapView.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/9/10.
//

import ROFileFormats
import RONetwork
import SwiftUI

@available(iOS 18.0, macOS 15.0, visionOS 2.0, *)
struct MapView: View {
    var mapSession: MapSession
    var gat: GAT
    var gnd: GND
    var position: SIMD2<Int16>

    var body: some View {
        MapSceneView(mapSession: mapSession, gat: gat, gnd: gnd, position: position)
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
