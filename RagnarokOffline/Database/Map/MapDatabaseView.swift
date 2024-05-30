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
                Table(maps) {
                    TableColumn("") { map in
                        MapImageView(map: map)
                    }
                    .width(40)
                    TableColumn("Name") { map in
                        NavigationLink(value: map) {
                            MapNameView(map: map)
                        }
                    }
                    TableColumn("ID", value: \.name)
                }
            }
        }
        .navigationTitle("Map Database")
    }
}

#Preview {
    MapDatabaseView()
}
