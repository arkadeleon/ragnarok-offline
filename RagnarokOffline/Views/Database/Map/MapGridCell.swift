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
    let tertiaryText: String?

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
                    }
                }
                .frame(width: 40, height: 40)

                VStack(alignment: .leading, spacing: 2) {
                    Text(primaryText)
                        .foregroundColor(.primary)
                        .lineLimit(1)

                    Text(secondaryText)
                        .foregroundColor(.secondary)
                        .lineLimit(1)

                    if let tertiaryText {
                        Text(tertiaryText)
                            .foregroundColor(.secondary)
                            .lineLimit(1)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .task {
            mapImage = await ClientResourceBundle.shared.mapImage(forMap: map)
            mapDisplayName = ClientDatabase.shared.mapDisplayName(map.name)
        }
    }

    private var primaryText: String {
        map.name
    }

    private var secondaryText: String {
        mapDisplayName ?? map.name
    }
}
