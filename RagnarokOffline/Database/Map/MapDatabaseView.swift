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
        DatabaseView(database: $database) { maps in
            ResponsiveView {
                List(maps) { map in
                    NavigationLink(value: map) {
                        MapCell(map: map, secondaryText: nil)
                    }
                }
                .listStyle(.plain)
            } regular: {
                ScrollView {
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 280), spacing: 20)], alignment: .leading, spacing: 20) {
                        ForEach(maps) { map in
                            NavigationLink(value: map) {
                                MapCell(map: map, secondaryText: nil)
                            }
                        }
                    }
                    .padding(20)
                }
            }
        }
        .navigationTitle("Map Database")
    }
}

#Preview {
    MapDatabaseView()
}
