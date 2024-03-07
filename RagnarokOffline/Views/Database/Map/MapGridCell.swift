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

    @State private var mapImage: UIImage?
    @State private var localizedMapName: String?
    @State private var isPreviewPresented = false

    var body: some View {
        HStack {
            Image(uiImage: mapImage ?? UIImage())
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: 40, height: 40)
                .clipped()

            VStack(alignment: .leading, spacing: 2) {
                Text(map.name)
                    .foregroundColor(.primary)
                    .lineLimit(1)

                Text(localizedMapName ?? map.name)
                    .foregroundColor(.secondary)
                    .lineLimit(1)
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            Spacer()

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
}
