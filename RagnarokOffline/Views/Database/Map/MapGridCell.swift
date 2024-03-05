//
//  MapGridCell.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/3/4.
//  Copyright © 2024 Leon & Vane. All rights reserved.
//

import SwiftUI
import rAthenaDatabase

struct MapGridCell: View {
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
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .foregroundColor(.primary)
                    .lineLimit(1)

                Text(localizedMapName ?? map.name)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .foregroundColor(.secondary)
                    .lineLimit(1)
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
