//
//  ItemListView.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2023/1/13.
//  Copyright © 2023 Leon & Vane. All rights reserved.
//

import rAthenaCommon
import SwiftUI

struct ItemListView: View {
    @State private var items: [RAItem] = []

    var body: some View {
        List(items, id: \.itemID) { item in
            Text(item.name)
        }
        .navigationTitle("Items")
        .task {
            let database = RAItemDatabase()
            items = await database.fetchAllItems().filter({ $0.type != .weapon && $0.type != .armor && $0.type != .card })
        }
    }
}
