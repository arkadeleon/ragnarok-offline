//
//  ItemListView.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2023/1/13.
//  Copyright © 2023 Leon & Vane. All rights reserved.
//

import SwiftUI
import rAthenaCommon

struct ItemListView: View {
    @EnvironmentObject var database: Database

    private var items: [RAItem] {
        database.allItems.filter({ $0.type != .weapon && $0.type != .armor && $0.type != .card })
    }

    var body: some View {
        List(items, id: \.itemID) { item in
            Text(item.name)
        }
        .navigationTitle("Items")
        .task {
            await database.fetchItems()
        }
    }
}
