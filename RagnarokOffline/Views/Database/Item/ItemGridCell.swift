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
    let tertiaryText: String?

    @State private var itemIconImage: CGImage?
    @State private var itemDisplayName: String?

    var body: some View {
        NavigationLink {
            ItemInfoView(database: database, item: item)
        } label: {
            HStack {
                ZStack {
                    if let itemIconImage {
                        Image(itemIconImage, scale: 1, label: Text(item.name))
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                    }
                }
                .frame(width: 40, height: 40)

                VStack(alignment: .leading, spacing: 2) {
                    Text(primaryText)
                        .foregroundColor(.primary)
                        .lineLimit(1)

                    Text(secondaryText)
                        .foregroundColor(.secondary)
                        .lineLimit(1)

                    if let tertiaryText {
                        Text(tertiaryText)
                            .foregroundColor(.secondary)
                            .lineLimit(1)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .task {
            itemIconImage = await ClientResourceBundle.shared.itemIconImage(forItem: item)
            itemDisplayName = ClientDatabase.shared.identifiedItemDisplayName(item.id)
        }
    }

    private var primaryText: String {
        item.slots > 0 ? item.name + " [\(item.slots)]" : item.name
    }

    private var secondaryText: String {
        itemDisplayName ?? item.name
    }
}
