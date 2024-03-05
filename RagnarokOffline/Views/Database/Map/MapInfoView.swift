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

    @State private var mapPreview: UIImage?

    var body: some View {
        List {
            VStack(alignment: .center) {
                if let mapPreview {
                    Image(uiImage: mapPreview)
                } else {
                    EmptyView()
                }
            }
            .frame(width: 150, height: 150, alignment: .center)
        }
        .listStyle(.plain)
        .navigationTitle(map.name)
        .navigationBarTitleDisplayMode(.inline)
        .task {
            Task {
                mapPreview = await ClientResourceManager.shared.mapPreviewImage(map.name, size: CGSize(width: 150, height: 150))
            }
        }
    }
}

//#Preview {
//    MapInfoView(database: .renewal, map: Database.renewal.maps().joined()[0])
//}
