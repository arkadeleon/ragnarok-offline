//
//  MapDatabaseView.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/3/4.
//

import SwiftUI

struct MapDatabaseView: View {
    @State private var database = ObservableDatabase(mode: .renewal, recordProvider: .map)

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
                            .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                        Text(map.name)
                            .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                            .foregroundStyle(Color.secondary)
                    }
                }
            }
            .listStyle(.plain)
        }
        .navigationTitle("Map Database")
        .databaseRoot($database) {
            ContentUnavailableView("No Maps", systemImage: "map.fill")
        }
    }
}

#Preview {
    MapDatabaseView()
}
