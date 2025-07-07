//
//  ItemCell.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/1/3.
//

import SwiftUI

struct ItemCell: View {
    var item: ItemModel
    var secondaryText: String?

    var body: some View {
        HStack {
            ItemIconImageView(item: item)

            VStack(alignment: .leading, spacing: 2) {
                Text(item.displayName)
                    .foregroundStyle(Color.primary)
                    .lineLimit(1)

                Text(secondaryText ?? item.aegisName)
                    .foregroundStyle(Color.secondary)
                    .lineLimit(1)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}
