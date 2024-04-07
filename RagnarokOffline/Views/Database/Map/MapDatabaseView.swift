//
//  MapDatabaseView.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/3/4.
//  Copyright © 2024 Leon & Vane. All rights reserved.
//

import SwiftUI

struct MapDatabaseView: View {
    @ObservedObject var mapDatabase: ObservableMapDatabase

    var body: some View {
        AsyncContentView(status: mapDatabase.status) { maps in
            ScrollView {
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 280), spacing: 20)], alignment: .leading, spacing: 20) {
                    ForEach(mapDatabase.filteredMaps) { map in
                        MapGridCell(database: mapDatabase.database, map: map, tertiaryText: nil)
                    }
                }
                .padding(20)
            }
            .overlay {
                if mapDatabase.filteredMaps.isEmpty {
                    EmptyContentView("No Maps")
                }
            }
        }
        .navigationTitle("Map Database")
        .navigationBarTitleDisplayMode(.inline)
        .searchable(text: $mapDatabase.searchText, placement: .navigationBarDrawer(displayMode: .always))
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
