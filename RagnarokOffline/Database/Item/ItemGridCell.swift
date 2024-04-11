//
//  ItemGridCell.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/1/3.
//

import SwiftUI
import RODatabase

struct ItemGridCell: View {
    let database: Database
    let item: Item
    let secondaryText: String?

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
                    } else {
                        Image(systemName: "leaf")
                            .foregroundStyle(.tertiary)
                            .font(.system(size: 25))
                    }
                }
                .frame(width: 40, height: 40)

                VStack(alignment: .leading, spacing: 2) {
                    Text(primaryText)
                        .foregroundColor(.primary)
                        .lineLimit(1)

                    Text(secondaryText ?? item.aegisName)
                        .foregroundColor(.secondary)
                        .lineLimit(1)
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
        let name = itemDisplayName ?? item.name
        return item.slots > 0 ? name + " [\(item.slots)]" : name
    }
}
