//
//  MapGrid.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/3/4.
//  Copyright © 2024 Leon & Vane. All rights reserved.
//

import SwiftUI
import rAthenaDatabase

struct MapGrid: View {
    let database: Database

    var body: some View {
        DatabaseRecordGrid(
            columns: [GridItem(.adaptive(minimum: 240), spacing: 16)],
            alignment: .leading,
            spacing: 32,
            insets: EdgeInsets(top: 32, leading: 16, bottom: 32, trailing: 16),
            partitions: database.maps(),
            filter: filter) { map in
                NavigationLink {
                    MapInfoView(database: database, map: map)
                } label: {
                    MapGridCell(database: database, map: map)
                }
            }
            .navigationTitle("Maps")
            .navigationBarTitleDisplayMode(.inline)
    }

    private func filter(maps: [Map], searchText: String) -> [Map] {
        maps.filter { map in
            map.name.localizedCaseInsensitiveContains(searchText)
        }
    }
}

#Preview {
    MapGrid(database: .renewal)
}
