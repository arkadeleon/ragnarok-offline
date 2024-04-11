//
//  MapGridCell.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/3/4.
//

import SwiftUI
import RODatabase

struct MapGridCell: View {
    let database: Database
    let map: Map
    let secondaryText: String?

    @State private var mapImage: CGImage?
    @State private var mapDisplayName: String?

    var body: some View {
        NavigationLink {
            MapInfoView(database: database, map: map)
        } label: {
            HStack {
                ZStack {
                    if let mapImage {
                        Image(mapImage, scale: 1, label: Text(map.name))
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                    } else {
                        Image(systemName: "map")
                            .foregroundStyle(.tertiary)
                            .font(.system(size: 25))
                    }
                }
                .frame(width: 40, height: 40)

                VStack(alignment: .leading, spacing: 2) {
                    Text(mapDisplayName ?? map.name)
                        .foregroundColor(.primary)
                        .lineLimit(1)

                    Text(secondaryText ?? map.name)
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .task {
            mapImage = await ClientResourceBundle.shared.mapImage(forMap: map)
            mapDisplayName = ClientDatabase.shared.mapDisplayName(map.name)
        }
    }
}
