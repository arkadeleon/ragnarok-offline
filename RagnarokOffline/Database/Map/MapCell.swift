//
//  MapCell.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/3/4.
//

import RODatabase
import SwiftUI

struct MapCell: View {
    var map: Map
    var secondaryText: String?

    var body: some View {
        HStack {
            MapImageView(map: map)

            VStack(alignment: .leading, spacing: 2) {
                MapNameView(map: map)
                    .foregroundStyle(Color.primary)
                    .lineLimit(1)

                Text(secondaryText ?? map.name)
                    .foregroundStyle(Color.secondary)
                    .lineLimit(1)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}
