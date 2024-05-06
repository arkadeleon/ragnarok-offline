//
//  MapDatabaseView.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/3/4.
//

import SwiftUI

struct MapDatabaseView: View {
    @ObservedObject var mapDatabase: ObservableMapDatabase

    var body: some View {
        ScrollView {
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 280), spacing: 20)], alignment: .leading, spacing: 20) {
                ForEach(mapDatabase.filteredMaps) { map in
                    NavigationLink(value: map) {
                        MapGridCell(map: map, secondaryText: nil)
                    }
                }
            }
            .padding(20)
        }
        .overlay {
            if mapDatabase.loadStatus == .loading {
                ProgressView()
            }
        }
        .overlay {
            if mapDatabase.loadStatus == .loaded && mapDatabase.filteredMaps.isEmpty {
                EmptyContentView("No Maps")
            }
        }
        .databaseNavigationDestinations(database: mapDatabase.database)
        .navigationTitle("Map Database")
        #if !os(macOS)
        .navigationBarTitleDisplayMode(.inline)
        #endif
        .searchable(text: $mapDatabase.searchText)
        .onSubmit(of: .search) {
            mapDatabase.filterMaps()
        }
        .onChange(of: mapDatabase.searchText) { _ in
            mapDatabase.filterMaps()
        }
        .task {
            await mapDatabase.fetchMaps()
        }
    }
}
