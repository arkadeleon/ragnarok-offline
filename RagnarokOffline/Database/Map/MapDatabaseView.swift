//
//  MapDatabaseView.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/3/4.
//

import SwiftUI

struct MapDatabaseView: View {
    @ObservedObject var database: ObservableDatabase<MapProvider>

    var body: some View {
        DatabaseView(database: database) { maps in
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
    MapDatabaseView(database: .init(mode: .renewal, recordProvider: .map))
}
