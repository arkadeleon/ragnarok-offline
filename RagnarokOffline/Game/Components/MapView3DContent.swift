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
                    if let component = event.entity.components[TileComponent.self] {
                        let position = SIMD2(Int16(component.x), Int16(component.y))
                        scene.mapSceneDelegate?.mapScene(scene, didTapTileAt: position)
                    }
                }
        )
        .gesture(
            SpatialTapGesture()
                .targetedToEntity(where: .has(MapObjectComponent.self))
                .onEnded { event in
                    if let component = event.entity.components[MapObjectComponent.self] {
                        scene.mapSceneDelegate?.mapScene(scene, didTapMapObject: component.object)
                    }
                }
        )
    }
}
