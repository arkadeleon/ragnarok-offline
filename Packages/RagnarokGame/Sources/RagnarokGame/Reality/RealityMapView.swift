//
//  RealityMapView.swift
//  RagnarokGame
//
//  Created by Leon Li on 2026/3/21.
//

import RealityKit
import SwiftUI

public struct RealityMapView: View {
    var scene: MapScene

    #if os(visionOS)
    @State private var baseDistance: Float = MapCameraState.default.distance
    #endif

    public var body: some View {
        #if os(visionOS)
        if let backend = scene.renderBackend as? RealityRenderBackend {
            RealityView { content in
                content.add(backend.rootEntity)
            } update: { _ in
            } placeholder: {
                ProgressView()
            }
            .gesture(tileTapGesture)
            .gesture(mapObjectTapGesture)
            .gesture(mapItemTapGesture)
            .gesture(
                MagnifyGesture()
                    .onChanged { value in
                        var distance = baseDistance * Float(1 / value.magnification)
                        distance = max(distance, 3)
                        distance = min(distance, 120)
                        scene.cameraState.distance = distance
                    }
                    .onEnded { _ in
                        baseDistance = scene.cameraState.distance
                    }
            )
        } else {
            EmptyView()
        }
        #else
        if let backend = scene.renderBackend as? RealityRenderBackend {
            RealityVirtualMapView(scene: scene, backend: backend)
        } else {
            EmptyView()
        }
        #endif
    }

    public init(scene: MapScene) {
        self.scene = scene
    }
}

#if os(visionOS)
private extension RealityMapView {
    var tileTapGesture: some Gesture {
        SpatialTapGesture()
            .targetedToEntity(where: .has(TileComponent.self))
            .onEnded { event in
                guard let position = event.entity.components[TileComponent.self]?.position else {
                    return
                }

                scene.handleInteraction(.ground(position: position))
            }
    }

    var mapObjectTapGesture: some Gesture {
        SpatialTapGesture()
            .targetedToEntity(where: .has(MapSceneObjectComponent.self))
            .onEnded { event in
                guard let object = event.entity.components[MapSceneObjectComponent.self]?.object else {
                    return
                }

                scene.handleInteraction(.mapObject(objectID: object.objectID))
            }
    }

    var mapItemTapGesture: some Gesture {
        SpatialTapGesture()
            .targetedToEntity(where: .has(MapSceneItemComponent.self))
            .onEnded { event in
                guard let item = event.entity.components[MapSceneItemComponent.self]?.item else {
                    return
                }

                scene.handleInteraction(.mapItem(objectID: item.objectID))
            }
    }
}
#endif
