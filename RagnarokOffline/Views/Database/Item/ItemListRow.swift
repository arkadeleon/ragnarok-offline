//
//  ItemListRow.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/1/3.
//  Copyright © 2024 Leon & Vane. All rights reserved.
//

import rAthenaMap
import SwiftUI

struct ItemListRow: View {
    let item: RAItem

    @State private var localizedItemName: String?

    var body: some View {
        HStack {
            DatabaseRecordIcon {
                await ClientResourceManager.shared.itemIconImage(item.itemID)
            }

            Text(item.name)

            if let localizedItemName {
                Text(localizedItemName)
                    .foregroundColor(.secondary)
            }
        }
        .task {
            localizedItemName = ClientDatabase.shared.itemDisplayName(item.itemID)
        }
    }
}

#Preview {
    ItemListRow(item: RAItem())
}
