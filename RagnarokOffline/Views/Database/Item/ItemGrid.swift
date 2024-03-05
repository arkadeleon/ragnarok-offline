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
            columns: [GridItem(.adaptive(minimum: 240), spacing: 16)],
            alignment: .leading,
            spacing: 32,
            insets: EdgeInsets(top: 32, leading: 16, bottom: 32, trailing: 16),
            partitions: database.items(),
            filter: filter) { item in
                NavigationLink {
                    ItemInfoView(database: database, item: item)
                } label: {
                    ItemGridCell(database: database, item: item)
                }
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
