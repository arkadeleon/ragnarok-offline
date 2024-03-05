//
//  MapList.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/3/4.
//  Copyright © 2024 Leon & Vane. All rights reserved.
//

import SwiftUI
import rAthenaDatabase

struct MapList: View {
    let database: Database

    var body: some View {
        DatabaseRecordList(partitions: database.maps()) { maps, searchText in
            maps.filter { map in
                map.name.localizedCaseInsensitiveContains(searchText)
            }
        } content: { map in
            NavigationLink {
                MapInfoView(database: database, map: map)
            } label: {
                MapListCell(database: database, map: map)
            }
        }
        .navigationTitle("Maps")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    MapList(database: .renewal)
}
