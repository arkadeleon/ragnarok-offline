//
//  MapListCell.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/3/4.
//  Copyright © 2024 Leon & Vane. All rights reserved.
//

import SwiftUI
import rAthenaDatabase

struct MapListCell: View {
    let database: Database
    let map: Map

    @State private var localizedMapName: String?

    var body: some View {
        HStack {
            DatabaseRecordImage {
                await ClientResourceManager.shared.mapPreviewImage(map.name, size: CGSize(width: 40, height: 40))
            }
            .frame(width: 40, height: 40)

            VStack(alignment: .leading, spacing: 2) {
                Text(map.name)

                Text(localizedMapName ?? "")
                    .foregroundColor(.secondary)
                    .lineLimit(1, reservesSpace: true)
            }
        }
        .task {
            localizedMapName = ClientDatabase.shared.mapDisplayName(map.name)
        }
    }
}

//#Preview {
//    MapListCell(database: .renewal, map: Database.renewal.maps().joined()[0])
//}
