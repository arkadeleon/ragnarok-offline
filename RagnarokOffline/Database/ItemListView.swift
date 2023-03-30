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

    var body: some View {
        List(database.items, id: \.itemID) { item in
            NavigationLink {
                ItemDetailView(item: item)
            } label: {
                switch item.type {
                case .weapon, .armor:
                    Text("\(item.name) [\(item.slots)]")
                default:
                    Text(item.name)
                }
            }
        }
        .navigationTitle("Item Database")
        .navigationBarTitleDisplayMode(.inline)
        .task {
            await database.fetchItems()
        }
    }
}
