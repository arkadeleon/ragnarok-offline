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

    @State private var localizedItemName: String?

    var body: some View {
        HStack {
            DatabaseRecordImage {
                await ClientResourceManager.shared.itemIconImage(item.id, size: CGSize(width: 40, height: 40))
            }
            .frame(width: 40, height: 40)

            VStack(alignment: .leading, spacing: 2) {
                Text(item.name)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .foregroundColor(.primary)
                    .lineLimit(1)

                Text(localizedItemName ?? item.name)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .foregroundColor(.secondary)
                    .lineLimit(1)
            }
        }
        .task {
            localizedItemName = ClientDatabase.shared.itemDisplayName(item.id)
        }
    }
}
