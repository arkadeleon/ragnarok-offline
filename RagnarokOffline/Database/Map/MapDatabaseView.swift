//
//  MapDatabaseView.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/3/4.
//

import SwiftUI

struct MapDatabaseView: View {
    @Environment(DatabaseModel<MapProvider>.self) private var database

    var body: some View {
        AdaptiveView {
            List(database.filteredRecords) { map in
                NavigationLink(value: map) {
                    MapCell(map: map)
                }
            }
            .listStyle(.plain)
        } regular: {
            List(database.filteredRecords) { map in
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
        .databaseRoot(database) {
            ContentUnavailableView("No Results", systemImage: "map.fill")
        }
        .task {
            await database.fetchRecords()
            await database.recordProvider.prefetchRecords(database.records)
        }
    }
}

#Preview("Pre-Renewal Map Database") {
    NavigationStack {
        MapDatabaseView()
    }
    .environment(DatabaseModel(mode: .prerenewal, recordProvider: .map))
}

#Preview("Renewal Map Database") {
    NavigationStack {
        MapDatabaseView()
    }
    .environment(DatabaseModel(mode: .renewal, recordProvider: .map))
}
