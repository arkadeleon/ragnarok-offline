//
//  MapInfoView.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/3/4.
//  Copyright © 2024 Leon & Vane. All rights reserved.
//

import SwiftUI
import rAthenaDatabase

struct MapInfoView: View {
    let database: Database
    let map: Map

    @State private var mapImage: UIImage?

    var body: some View {
        ScrollView {
            Image(uiImage: mapImage ?? UIImage())
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(height: 200)
        }
        .navigationTitle(map.name)
        .navigationBarTitleDisplayMode(.inline)
        .task {
            mapImage = await ClientResourceBundle.shared.mapImage(forMap: map)
        }
    }
}
