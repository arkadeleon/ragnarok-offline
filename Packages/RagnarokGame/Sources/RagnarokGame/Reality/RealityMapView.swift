//
//  RealityMapView.swift
//  RagnarokGame
//
//  Created by Leon Li on 2026/3/21.
//

import RealityKit
import SwiftUI

#if os(visionOS)

public struct RealityMapView: View {
    var scene: RealityMapScene

    public var body: some View {
        RealityView { content in
            content.add(scene.rootEntity)
        } update: { _ in
        } placeholder: {
            ProgressView()
        }
        .gesture(tileTapGesture)
        .gesture(mapObjectTapGesture)
        .gesture(mapItemTapGesture)
    }

    public init(scene: RealityMapScene) {
        self.scene = scene
    }
}

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
            .targetedToEntity(where: .has(MapObjectComponent.self))
            .onEnded { event in
                guard let objectID = event.entity.components[MapObjectComponent.self]?.object.objectID else {
                    return
                }
                scene.handleInteraction(.mapObject(objectID: objectID))
            }
    }

    var mapItemTapGesture: some Gesture {
        SpatialTapGesture()
            .targetedToEntity(where: .has(MapItemComponent.self))
            .onEnded { event in
                guard let objectID = event.entity.components[MapItemComponent.self]?.item.objectID else {
                    return
                }
                scene.handleInteraction(.mapItem(objectID: objectID))
            }
    }
}

#else

public struct RealityMapView: View {
    var scene: MapScene

    public var body: some View {
        if let backend = scene.renderBackend as? RealityRenderBackend {
            RealityVirtualMapView(scene: scene, backend: backend)
        } else {
            EmptyView()
        }
    }

    public init(scene: MapScene) {
        self.scene = scene
    }
}

#endif
