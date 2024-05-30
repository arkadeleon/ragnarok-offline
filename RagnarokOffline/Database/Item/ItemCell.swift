//
//  ItemCell.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/1/3.
//

import RODatabase
import SwiftUI

struct ItemCell: View {
    var item: Item
    var secondaryText: String?

    var body: some View {
        HStack {
            ItemIconView(item: item)

            VStack(alignment: .leading, spacing: 2) {
                ItemNameView(item: item)
                    .foregroundColor(.primary)
                    .lineLimit(1)

                Text(secondaryText ?? item.aegisName)
                    .foregroundColor(.secondary)
                    .lineLimit(1)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}
