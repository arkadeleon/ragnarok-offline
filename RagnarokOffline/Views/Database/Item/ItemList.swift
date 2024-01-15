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
    public var body: some View {
        DatabaseRecordList {
            try await Database.renewal.fetchItems()
        } filter: { items, searchText in
            items.filter { item in
                item.name.localizedCaseInsensitiveContains(searchText)
            }
        } content: { item in
            NavigationLink {
                ItemDetailView(item: item)
            } label: {
                ItemListCell(item: item)
            }
        }
        .navigationTitle("Items")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    ItemList()
}
