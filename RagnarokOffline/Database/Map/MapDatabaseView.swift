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
                        MapCell(map: map)
                    }
                }
                .listStyle(.plain)
            } regular: {
                List(maps) { map in
                    NavigationLink(value: map) {
                        HStack {
                            MapImageView(map: map)
                                .frame(width: 40)
                            MapNameView(map: map)
                                .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                            Text(map.name)
                                .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
                .listStyle(.plain)
            }
        }
        .navigationTitle("Map Database")
    }
}

#Preview {
    MapDatabaseView()
}
