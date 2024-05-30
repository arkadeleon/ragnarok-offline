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
                    .foregroundColor(.primary)
                    .lineLimit(1)

                Text(secondaryText ?? map.name)
                    .foregroundColor(.secondary)
                    .lineLimit(1)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}
