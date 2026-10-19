//
//  MapDatabaseView.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/3/4.
//

import RagnarokResources
import SwiftUI

struct MapDatabaseView: View {
    @Environment(DatabaseModel.self) private var database

    @State private var searchText = ""
    @State private var filteredMaps: [MapModel] = []

    var body: some View {
        SizeClassAdaptiveView {
            List(filteredMaps) { map in
                NavigationLink(value: map) {
                    MapCell(map: map)
                }
            }
            .listStyle(.plain)
        } regular: {
            List(filteredMaps) { map in
                NavigationLink(value: map) {
                    HStack {
                        MapImageView(map: map)
                            .frame(width: 40)
                        Text(map.displayName)
                            .frame(minWidth: 160, maxWidth: .infinity, alignment: .leading)
                        Text(map.name)
                            .frame(minWidth: 120, maxWidth: .infinity, alignment: .leading)
                            .foregroundStyle(Color.secondary)
                    }
                }
            }
            .listStyle(.plain)
        }
        .background(.background)
        .navigationTitle(Text("Map Database", tableName: "Database"))
        .adaptiveSearch(text: $searchText)
        .overlay {
            if database.maps.isEmpty {
                ProgressView()
            } else if !searchText.isEmpty && filteredMaps.isEmpty {
                ContentUnavailableView {
                    Label {
                        Text("No Results", tableName: "Database")
                    } icon: {
                        Image(systemName: "map.fill")
                    }
                }
            }
        }
        .task(id: "\(searchText)") {
            await database.fetchMaps()

            if !searchText.isEmpty {
                do {
                    try await Task.sleep(for: .milliseconds(200))
                } catch {
                    return
                }
            }

            let filteredMaps = await maps(matching: searchText)
            if !Task.isCancelled {
                self.filteredMaps = filteredMaps
            }
        }
    }

    private func maps(matching searchText: String) async -> [MapModel] {
        let maps = database.maps

        if searchText.isEmpty {
            return maps
        }

        let indices = await database.mapSearchIndex.indices(matching: searchText)
        return indices.map { maps[$0] }
    }
}

#Preview("Pre-Renewal Map Database") {
    NavigationStack {
        MapDatabaseView()
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .environment(DatabaseModel(mode: .prerenewal, resourceManager: .previewing))
}

#Preview("Renewal Map Database") {
    NavigationStack {
        MapDatabaseView()
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .environment(DatabaseModel(mode: .renewal, resourceManager: .previewing))
}
