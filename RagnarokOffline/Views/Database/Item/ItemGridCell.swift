//
//  ItemGridCell.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/1/3.
//  Copyright © 2024 Leon & Vane. All rights reserved.
//

import SwiftUI
import rAthenaDatabase

struct ItemGridCell: View {
    let database: Database
    let item: Item
    let secondaryText: Text?

    @State private var itemIconImage: UIImage?
    @State private var localizedItemName: String?

    var body: some View {
        HStack {
            Image(uiImage: itemIconImage ?? UIImage())
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: 40, height: 40)
                .clipped()

            VStack(alignment: .leading, spacing: 2) {
                HStack {
                    Text(item.name)
                        .foregroundColor(.primary)
                        .lineLimit(1)

                    secondaryText
                }

                Text(localizedItemName ?? item.name)
                    .foregroundColor(.secondary)
                    .lineLimit(1)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .task {
            itemIconImage = await ClientResourceBundle.shared.itemIconImage(forItem: item)
            localizedItemName = ClientDatabase.shared.itemDisplayName(item.id)
        }
    }

    init(database: Database, item: Item) {
        self.database = database
        self.item = item
        self.secondaryText = nil
    }

    init(database: Database, item: Item, @ViewBuilder secondaryText: () -> Text) {
        self.database = database
        self.item = item
        self.secondaryText = secondaryText()
    }
}
