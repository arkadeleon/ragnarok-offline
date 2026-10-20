//
//  ItemCell.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/1/3.
//

import SwiftUI

struct ItemCell<SecondaryLabel>: View where SecondaryLabel: View {
    var item: ItemModel
    var secondaryLabel: SecondaryLabel

    var body: some View {
        HStack {
            ItemIconImageView(item: item)

            VStack(alignment: .leading, spacing: 2) {
                Text(item.displayName)
                    .foregroundStyle(Color.primary)
                    .lineLimit(1)

                secondaryLabel
                    .foregroundStyle(Color.secondary)
                    .lineLimit(1)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    init(item: ItemModel, secondaryText: String? = nil) where SecondaryLabel == Text {
        self.item = item
        self.secondaryLabel = Text(secondaryText ?? item.aegisName)
    }

    init(item: ItemModel, @ViewBuilder secondaryLabel: () -> SecondaryLabel) {
        self.item = item
        self.secondaryLabel = secondaryLabel()
    }
}
