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
        ResponsiveView {
            List(mapDatabase.filteredMaps) { map in
                NavigationLink(value: map) {
                    MapCell(map: map, secondaryText: nil)
                }
            }
            .listStyle(.plain)
            .searchable(text: $mapDatabase.searchText, placement: .navigationBarDrawer(displayMode: .always))
        } regular: {
            ScrollView {
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 280), spacing: 20)], alignment: .leading, spacing: 20) {
                    ForEach(mapDatabase.filteredMaps) { map in
                        NavigationLink(value: map) {
                            MapCell(map: map, secondaryText: nil)
                        }
                    }
                }
                .padding(20)
            }
            .searchable(text: $mapDatabase.searchText)
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
        .databaseNavigationDestinations(mode: mapDatabase.mode)
        .navigationTitle("Map Database")
        #if !os(macOS)
        .navigationBarTitleDisplayMode(.inline)
        #endif
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
