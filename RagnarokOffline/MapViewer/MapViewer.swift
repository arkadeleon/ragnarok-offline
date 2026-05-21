//
//  MapViewer.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2025/6/9.
//

import RagnarokResources
import SwiftUI

struct MapViewer: View {
    var resourceManager: ResourceManager

    @Namespace private var mapNamespace

    @State private var isPicking = false
    @State private var selectedMap: MapModel?

    var body: some View {
        ZStack {
            if let selectedMap {
                MapViewerMapRenderingView(map: selectedMap, resourceManager: resourceManager)
                    .id(selectedMap.name)
            } else {
                ContentUnavailableView {
                    Label {
                        Text("No Map Selected", tableName: "MapViewer")
                    } icon: {
                        Image(systemName: "map")
                    }
                } description: {
                    Text("Choose a map to view", tableName: "MapViewer")
                } actions: {
                    Button {
                        isPicking = true
                    } label: {
                        Label {
                            Text("Choose a Map", tableName: "MapViewer")
                        } icon: {
                            Image(systemName: "map")
                        }
                        .font(.title3)
                        .fontWeight(.medium)
                        .padding(.horizontal)
                    }
                    .adaptiveProminentButtonStyle()
                    .matchedTransitionSource(id: "map", in: mapNamespace)
                }
            }
        }
        .navigationTitle(Text("Map Viewer", tableName: "MapViewer"))
        .toolbarTitleDisplayMode(.inline)
        .toolbar {
            if let selectedMap {
                ToolbarItem {
                    Button {
                        isPicking = true
                    } label: {
                        HStack {
                            Image(systemName: "map")
                            Text(selectedMap.displayName)
                        }
                    }
                    .matchedTransitionSource(id: "map", in: mapNamespace)
                }
            }
        }
        .sheet(isPresented: $isPicking) {
            NavigationStack {
                MapViewerMapListView(selection: $selectedMap)
            }
            .presentationSizing(.form)
            .adaptiveNavigationTransition(sourceID: "map", in: mapNamespace)
        }
    }
}
