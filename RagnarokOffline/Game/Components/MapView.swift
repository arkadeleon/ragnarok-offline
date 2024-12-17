//
//  MapView.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/9/10.
//

import RODatabase
import RONetwork
import SpriteKit
import SwiftUI

struct MapView: View {
    var mapSession: MapSession
    var mapScene: GameMapScene

    @State private var npcDialog: NPCDialog?

    var body: some View {
        SpriteView(scene: mapScene)
            .ignoresSafeArea()
            .overlay {
                NPCDialogBox(mapSession: mapSession, dialog: $npcDialog)
            }
            .onReceive(mapSession.publisher(for: NPCEvents.DialogUpdated.self)) { event in
                self.npcDialog = event.dialog
            }
            .onReceive(mapSession.publisher(for: NPCEvents.DialogClosed.self)) { event in
                self.npcDialog = nil
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
