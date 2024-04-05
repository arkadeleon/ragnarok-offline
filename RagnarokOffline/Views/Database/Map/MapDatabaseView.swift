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
            .searchable(text: $mapDatabase.searchText)
            .onSubmit(of: .search) {
                mapDatabase.filterMaps()
            }
            .onChange(of: mapDatabase.searchText) { _ in
                mapDatabase.filterMaps()
            }
        }
        .navigationTitle("Map Database")
        .navigationBarTitleDisplayMode(.inline)
        .task {
            await mapDatabase.fetchMaps()
        }
    }
}
