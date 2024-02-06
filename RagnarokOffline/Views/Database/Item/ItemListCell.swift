//
//  ItemListCell.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/1/3.
//  Copyright © 2024 Leon & Vane. All rights reserved.
//

import SwiftUI
import rAthenaDatabase

struct ItemListCell: View {
    let database: Database
    let item: Item

    @State private var localizedItemName: String?

    var body: some View {
        HStack {
            DatabaseRecordImage {
                await ClientResourceManager.shared.itemIconImage(item.id)
            }
            .frame(width: 24, height: 24)

            Text(item.name)

            if let localizedItemName {
                Text(localizedItemName)
                    .foregroundColor(.secondary)
            }
        }
        .task {
            localizedItemName = ClientScriptManager.shared.itemDisplayName(item.id)
        }
    }
}
