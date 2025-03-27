//
//  MapView3D.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/9/10.
//

import RealityKit
import ROGame
import RORendering
import SwiftUI

struct MapView3D: View {
    var mapSession: MapSession
    var scene: MapScene3D

    @State private var distance: Float = 80

    var body: some View {
        RealityView { content in
            await scene.load()
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
        .gesture(
            SpatialTapGesture()
                .targetedToEntity(where: .has(TileComponent.self))
                .onEnded { event in
                    if let tileComponent = event.entity.components[TileComponent.self] {
                        mapSession.requestMove(x: Int16(tileComponent.x), y: Int16(tileComponent.y))
                    }
                }
        )
        .gesture(
            SpatialTapGesture()
                .targetedToEntity(where: .has(SpriteComponent.self))
                .onEnded { event in
                    logger.info("Tap sprite entity: \(event.entity.name)")
                }
        )
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
