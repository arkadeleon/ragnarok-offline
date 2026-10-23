//
//  MapCell.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/3/4.
//

import SwiftUI

struct MapCell<SecondaryLabel>: View where SecondaryLabel: View {
    var map: MapModel
    var secondaryLabel: SecondaryLabel

    var body: some View {
        HStack {
            MapImageView(map: map)

            VStack(alignment: .leading, spacing: 2) {
                Text(map.displayName)
                    .foregroundStyle(Color.primary)
                    .lineLimit(1)

                secondaryLabel
                    .foregroundStyle(Color.secondary)
                    .lineLimit(1)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    init(map: MapModel, secondaryText: String? = nil) where SecondaryLabel == Text {
        self.map = map
        self.secondaryLabel = Text(secondaryText ?? map.name)
    }

    init(map: MapModel, badges: [DatabaseBadge]) where SecondaryLabel == DatabaseBadgeStackView {
        self.map = map
        self.secondaryLabel = DatabaseBadgeStackView(badges: badges)
    }
}
