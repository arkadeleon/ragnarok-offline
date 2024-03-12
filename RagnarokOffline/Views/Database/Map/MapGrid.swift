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
            columns: [GridItem(.adaptive(minimum: 280), spacing: 20)],
            alignment: .leading,
            spacing: 20,
            insets: EdgeInsets(top: 20, leading: 20, bottom: 20, trailing: 20),
            partitions: database.maps(),
            filter: filter) { map in
                MapGridCell(database: database, map: map)
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
