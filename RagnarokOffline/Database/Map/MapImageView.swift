//
//  MapImageView.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/5/30.
//

import ROClient
import RODatabase
import SwiftUI

struct MapImageView: View {
    var map: Map

    @State private var mapImage: CGImage?

    var body: some View {
        ZStack {
            if let mapImage {
                Image(mapImage, scale: 1, label: Text(map.name))
                    .resizable()
                    .aspectRatio(contentMode: .fit)
            } else {
                Image(systemName: "map")
                    .font(.system(size: 25, weight: .thin))
                    .foregroundStyle(Color.secondary)
            }
        }
        .frame(width: 40, height: 40)
        .task {
            mapImage = await ClientResourceBundle.shared.mapImage(forMap: map)
        }
    }
}

//#Preview {
//    MapImageView()
//}
