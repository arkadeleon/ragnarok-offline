//
//  ItemListView.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2023/1/13.
//  Copyright © 2023 Leon & Vane. All rights reserved.
//

import rAthenaDatabase
import SwiftUI

struct ItemListView: View {
    @State private var items: [Item] = []

    var body: some View {
        List(items, id: \.id) { item in
            Text(item.name)
        }
        .navigationTitle("Items")
        .task {
            items = rAthenaDatabase.Database.renewal.fetchItems()
        }
    }
}
