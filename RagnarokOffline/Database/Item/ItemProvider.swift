//
//  ItemProvider.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/4/3.
//

import RODatabase

struct ItemProvider: DatabaseRecordProvider {
    func records(for mode: DatabaseMode) async -> [ItemModel] {
        let database = ItemDatabase.shared
        let usableItems = await database.usableItems()

        var items: [ItemModel] = []
        for item in usableItems {
            let item = await ItemModel(mode: mode, item: item)
            items.append(item)
        }
        return items
    }

    func moreRecords(for mode: DatabaseMode) async -> [ItemModel] {
        let database = ItemDatabase.shared
        let equipItems = await database.equipItems()
        let etcItems = await database.etcItems()

        var items: [ItemModel] = []
        for item in equipItems + etcItems {
            let item = await ItemModel(mode: mode, item: item)
            items.append(item)
        }
        return items
    }

    func records(matching searchText: String, in items: [ItemModel]) async -> [ItemModel] {
        if searchText.hasPrefix("#") {
            if let itemID = Int(searchText.dropFirst()),
               let item = items.first(where: { $0.id == itemID }) {
                return [item]
            } else {
                return []
            }
        }

        let filteredItems = items.filter { item in
            item.displayName.localizedStandardContains(searchText)
        }
        return filteredItems
    }
}

extension DatabaseRecordProvider where Self == ItemProvider {
    static var item: ItemProvider {
        ItemProvider()
    }
}
