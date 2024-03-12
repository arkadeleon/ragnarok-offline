//
//  ItemGrid.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/1/3.
//  Copyright © 2024 Leon & Vane. All rights reserved.
//

import SwiftUI
import rAthenaDatabase

struct ItemGrid: View {
    let database: Database

    var body: some View {
        DatabaseRecordGrid(
            columns: [GridItem(.adaptive(minimum: 280), spacing: 20)],
            alignment: .leading,
            spacing: 20,
            insets: EdgeInsets(top: 20, leading: 20, bottom: 20, trailing: 20),
            partitions: database.items(),
            filter: filter) { item in
                ItemGridCell(database: database, item: item)
            }
            .navigationTitle("Items")
            .navigationBarTitleDisplayMode(.inline)
    }

    private func filter(items: [Item], searchText: String) -> [Item] {
        items.filter { item in
            item.name.localizedCaseInsensitiveContains(searchText)
        }
    }
}

#Preview {
    ItemGrid(database: .renewal)
}
