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
    let secondaryText: Text?

    @State private var mapImage: CGImage?
    @State private var localizedMapName: String?
    @State private var isPreviewPresented = false

    var body: some View {
        HStack {
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
                        HStack {
                            Text(map.name)
                                .foregroundColor(.primary)
                                .lineLimit(1)

                            secondaryText
                        }

                        Text(localizedMapName ?? map.name)
                            .foregroundColor(.secondary)
                            .lineLimit(1)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
            }

            Button("View") {
                isPreviewPresented.toggle()
            }
            .buttonStyle(.bordered)
            .buttonBorderShape(.capsule)
        }
        .sheet(isPresented: $isPreviewPresented) {
            let file = ClientResourceBundle.shared.rswFile(forMap: map)
            FilePreviewPageView(file: file, files: [file])
        }
        .task {
            mapImage = await ClientResourceBundle.shared.mapImage(forMap: map)
            localizedMapName = ClientDatabase.shared.mapDisplayName(map.name)
        }
    }

    init(database: Database, map: Map) {
        self.database = database
        self.map = map
        self.secondaryText = nil
    }

    init(database: Database, map: Map, @ViewBuilder secondaryText: () -> Text) {
        self.database = database
        self.map = map
        self.secondaryText = secondaryText()
    }
}
