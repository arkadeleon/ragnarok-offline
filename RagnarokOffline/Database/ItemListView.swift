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

    let title: String
    let includedTypes: [RAItemType]
    let excludedTypes: [RAItemType]

    private var items: [RAItem] {
        var items = database.allItems
        if !excludedTypes.isEmpty {
            items = items.filter({ !excludedTypes.contains($0.type) })
        }
        if !includedTypes.isEmpty {
            items = items.filter({ includedTypes.contains($0.type) })
        }
        return items
    }

    var body: some View {
        List(items, id: \.itemID) { item in
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
        .navigationTitle(title)
        .navigationBarTitleDisplayMode(.inline)
        .task {
            await database.fetchItems()
        }
    }

    init(_ title: String, includedTypes: [RAItemType] = [], excludedTypes: [RAItemType] = []) {
        self.title = title
        self.includedTypes = includedTypes
        self.excludedTypes = excludedTypes
    }
}
