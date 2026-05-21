//
//  MapViewerMapListView.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2026/5/21.
//

import SwiftUI

struct MapViewerMapListView: View {
    @Binding var selection: MapModel?

    @Environment(DatabaseModel.self) private var database
    @Environment(\.dismiss) private var dismiss

    @State private var searchText = ""
    @State private var maps: [MapModel] = []
    @State private var filteredMaps: [MapModel] = []

    var body: some View {
        List {
            ForEach(filteredMaps) { map in
                Button {
                    selection = map
                    dismiss()
                } label: {
                    HStack {
                        MapCell(map: map)

                        if selection == map {
                            Image(systemName: "checkmark")
                                .foregroundStyle(.link)
                        }
                    }
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
            }
        }
        .listStyle(.plain)
        .navigationTitle(Text("Map", tableName: "MapViewer"))
        .toolbarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarDoneButton {
                dismiss()
            }
        }
        .adaptiveSearch(text: $searchText)
        .overlay {
            if maps.isEmpty {
                ProgressView()
            } else if filteredMaps.isEmpty {
                ContentUnavailableView {
                    Label {
                        Text("No Results", tableName: "MapViewer")
                    } icon: {
                        Image(systemName: "map.fill")
                    }
                }
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

    MapViewerMapListView(selection: $selection)
        .environment(DatabaseModel(mode: .renewal, resourceManager: .previewing))
}
