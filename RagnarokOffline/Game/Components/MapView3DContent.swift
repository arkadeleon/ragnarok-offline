//
//  MapView3DContent.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/9/10.
//

import RealityKit
import ROGame
import SwiftUI

struct MapView3DContent: View {
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
                        let position = SIMD2(Int16(tileComponent.x), Int16(tileComponent.y))
                        scene.mapSceneDelegate?.mapScene(scene, didTapTileAt: position)
                    }
                }
        )
        .gesture(
            SpatialTapGesture()
                .targetedToEntity(where: .has(SpriteComponent.self))
                .onEnded { event in
                    if let objectID = UInt32(event.entity.name) {
                        scene.mapSceneDelegate?.mapScene(scene, didTapMapObjectWith: objectID)
                    }
                }
        )
    }
}
