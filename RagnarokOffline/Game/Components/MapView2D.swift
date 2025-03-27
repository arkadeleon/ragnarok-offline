//
//  MapView2D.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2025/3/27.
//

import ROGame
import ROResources
import SpriteKit
import SwiftUI

struct MapView2D: View {
    var mapSession: MapSession
    var scene: MapScene2D

    var body: some View {
        SpriteView(scene: scene)
            .overlay(alignment: .topLeading) {
                PlayerStatusOverlayView(mapSession: mapSession)
            }
            .overlay {
                NPCDialogOverlayView(mapSession: mapSession)
            }
            .onReceive(mapSession.publisher(for: PlayerEvents.Moved.self), perform: scene.onPlayerMoved)
            .onReceive(mapSession.publisher(for: MapObjectEvents.Spawned.self), perform: scene.onMapObjectSpawned)
            .onReceive(mapSession.publisher(for: MapObjectEvents.Moved.self), perform: scene.onMapObjectMoved)
            .onReceive(mapSession.publisher(for: MapObjectEvents.Stopped.self), perform: scene.onMapObjectStopped)
            .onReceive(mapSession.publisher(for: MapObjectEvents.Vanished.self), perform: scene.onMapObjectVanished)
            .onReceive(mapSession.publisher(for: MapObjectEvents.StateChanged.self), perform: scene.onMapObjectStateChanged)
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
