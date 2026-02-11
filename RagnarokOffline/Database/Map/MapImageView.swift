//
//  MapImageView.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/5/30.
//

import SwiftUI

struct MapImageView: View {
    var map: MapModel

    var body: some View {
        ZStack {
            if let mapImage = map.image {
                Image(decorative: mapImage.cgImage, scale: 1)
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
            await map.fetchImage()
        }
    }
}
