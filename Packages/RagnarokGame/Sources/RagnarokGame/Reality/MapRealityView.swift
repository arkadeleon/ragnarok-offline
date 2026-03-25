//
//  MapRealityView.swift
//  RagnarokGame
//
//  Created by Leon Li on 2026/3/21.
//

#if os(visionOS)
import RealityKit
#endif
import SwiftUI

public struct MapRealityView: View {
    var scene: MapScene
    var overlay: MapSceneOverlay?

    #if os(visionOS)
    @State private var baseDistance: Float = MapCameraState.default.distance
    #endif

    public var body: some View {
        #if os(visionOS)
        if let backend = scene.renderBackend as? RealityKitMapBackend {
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
        if let backend = scene.renderBackend as? RealityKitMapBackend {
            MapSceneARView(scene: scene, overlay: overlay, backend: backend)
        } else {
            EmptyView()
        }
        #endif
    }

    public init(scene: MapScene) {
        self.scene = scene
        self.overlay = nil
    }

    init(scene: MapScene, overlay: MapSceneOverlay?) {
        self.scene = scene
        self.overlay = overlay
    }
}

#if os(visionOS)
private extension MapRealityView {
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
            .targetedToEntity(where: .has(MapObjectComponent.self))
            .onEnded { event in
                guard let mapObject = event.entity.components[MapObjectComponent.self]?.mapObject else {
                    return
                }

                scene.handleInteraction(.mapObject(objectID: mapObject.objectID))
            }
    }

    var mapItemTapGesture: some Gesture {
        SpatialTapGesture()
            .targetedToEntity(where: .has(MapItemComponent.self))
            .onEnded { event in
                guard let mapItem = event.entity.components[MapItemComponent.self]?.mapItem else {
                    return
                }

                scene.handleInteraction(.item(objectID: mapItem.objectID))
            }
    }
}
#endif
