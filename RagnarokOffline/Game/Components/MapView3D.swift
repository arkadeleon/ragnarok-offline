//
//  MapView3D.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/9/10.
//

import ROGame
import RORendering
import SwiftUI

struct MapView3D: View {
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
