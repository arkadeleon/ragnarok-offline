//
//  ItemList.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/1/3.
//  Copyright © 2024 Leon & Vane. All rights reserved.
//

import SwiftUI
import rAthenaDatabase

struct ItemList: View {
    let database: Database

    var body: some View {
        DatabaseRecordList(partitions: database.fetchItems()) { items, searchText in
            items.filter { item in
                item.name.localizedCaseInsensitiveContains(searchText)
            }
        } content: { item in
            NavigationLink {
                ItemDetailView(database: database, item: item)
            } label: {
                ItemListCell(database: database, item: item)
            }
        }
        .navigationTitle("Items")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    ItemList(database: .renewal)
}
