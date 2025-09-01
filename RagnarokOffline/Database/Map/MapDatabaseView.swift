//
//  MapDatabaseView.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/3/4.
//

import SwiftUI

struct MapDatabaseView: View {
    @Environment(DatabaseModel.self) private var database

    @State private var searchText = ""
    @State private var filteredMaps: [MapModel] = []

    var body: some View {
        AdaptiveView {
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
        .navigationTitle("Map Database")
        .background(.background)
        .overlay {
            if database.maps.isEmpty {
                ProgressView()
            } else if !searchText.isEmpty && filteredMaps.isEmpty {
                ContentUnavailableView("No Results", systemImage: "map.fill")
            }
        }
        .searchable(text: $searchText)
        .task(id: searchText) {
            filteredMaps = await maps(matching: searchText, in: database.maps)
        }
        .task {
            await database.fetchMaps()
            filteredMaps = await maps(matching: searchText, in: database.maps)
        }
    }

    private func maps(matching searchText: String, in maps: [MapModel]) async -> [MapModel] {
        if searchText.isEmpty {
            return maps
        }

        let filteredMaps = maps.filter { map in
            map.displayName.localizedStandardContains(searchText)
        }
        return filteredMaps
    }
}

#Preview("Pre-Renewal Map Database") {
    NavigationStack {
        MapDatabaseView()
    }
    .environment(DatabaseModel(mode: .prerenewal))
}

#Preview("Renewal Map Database") {
    NavigationStack {
        MapDatabaseView()
    }
    .environment(DatabaseModel(mode: .renewal))
}
