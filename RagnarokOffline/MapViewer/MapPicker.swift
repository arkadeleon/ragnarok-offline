//
//  MapPicker.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2026/3/10.
//

import SwiftUI

struct MapPicker: View {
    @Binding var selection: MapModel?

    @Environment(DatabaseModel.self) private var database

    @Namespace private var mapNamespace

    @State private var isPicking = false
    @State private var searchText = ""
    @State private var maps: [MapModel] = []
    @State private var filteredMaps: [MapModel] = []

    var body: some View {
        Button {
            isPicking = true
        } label: {
            HStack {
                Image(systemName: "map")

                if let selection {
                    Text(selection.displayName)
                }
            }
        }
        .matchedTransitionSource(id: "map", in: mapNamespace)
        .sheet(isPresented: $isPicking) {
            NavigationStack {
                mapList
            }
            .presentationSizing(.form)
            #if os(macOS)
            .navigationTransition(.automatic)
            #else
            .navigationTransition(.zoom(sourceID: "map", in: mapNamespace))
            #endif
        }
    }

    private var mapList: some View {
        List {
            ForEach(filteredMaps) { map in
                Button {
                    selection = map
                    isPicking = false
                } label: {
                    HStack {
                        MapCell(map: map)

                        if selection == map {
                            Image(systemName: "checkmark")
                                .foregroundStyle(.link)
                        }
                    }
                }
            }
        }
        .listStyle(.plain)
        .navigationTitle("Map")
        .toolbarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarCancelButton {
                isPicking = false
            }
        }
        .adaptiveSearch(text: $searchText)
        .overlay {
            if maps.isEmpty {
                ProgressView()
            } else if filteredMaps.isEmpty {
                ContentUnavailableView("No Results", systemImage: "map.fill")
            }
        }
        .task(id: searchText) {
            if maps.isEmpty {
                await database.fetchMaps()
                maps = database.maps
            }

            filteredMaps = filteredMaps(matching: searchText, in: maps)
        }
    }

    private func filteredMaps(matching searchText: String, in maps: [MapModel]) -> [MapModel] {
        if searchText.isEmpty {
            return maps
        }

        let filteredMaps = maps.filter { map in
            map.displayName.localizedStandardContains(searchText) || map.name.localizedStandardContains(searchText)
        }
        return filteredMaps
    }
}

#Preview {
    @Previewable @State var selection: MapModel? = nil

    MapPicker(selection: $selection)
        .environment(DatabaseModel(mode: .renewal))
}
