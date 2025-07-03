//
//  MapDatabaseView.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/3/4.
//

import SwiftUI

struct MapDatabaseView: View {
    @Environment(AppModel.self) private var appModel

    private var database: ObservableDatabase<MapProvider> {
        appModel.mapDatabase
    }

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
    }
}

#Preview("Pre-Renewal Map Database") {
    @Previewable @State var appModel = AppModel()
    appModel.mapDatabase = ObservableDatabase(mode: .prerenewal, recordProvider: .map)

    return MapDatabaseView()
        .environment(appModel)
}

#Preview("Renewal Map Database") {
    @Previewable @State var appModel = AppModel()
    appModel.mapDatabase = ObservableDatabase(mode: .renewal, recordProvider: .map)

    return MapDatabaseView()
        .environment(appModel)
}
