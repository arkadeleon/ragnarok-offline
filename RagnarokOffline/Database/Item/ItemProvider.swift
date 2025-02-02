//
//  ItemProvider.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/4/3.
//

import RODatabase

struct ItemProvider: DatabaseRecordProvider {
    func records(for mode: DatabaseMode) async -> [ObservableItem] {
        let database = ItemDatabase.database(for: mode)
        let usableItems = await database.usableItems().map { item in
            ObservableItem(mode: mode, item: item)
        }
        for item in usableItems {
            await item.fetchLocalizedName()
        }
        return usableItems
    }

    func moreRecords(for mode: DatabaseMode) async -> [ObservableItem] {
        let database = ItemDatabase.database(for: mode)
        let equipItems = await database.equipItems().map { item in
            ObservableItem(mode: mode, item: item)
        }
        let etcItems = await database.etcItems().map { item in
            ObservableItem(mode: mode, item: item)
        }
        for item in equipItems + etcItems {
            await item.fetchLocalizedName()
        }
        return equipItems + etcItems
    }

    func records(matching searchText: String, in items: [ObservableItem]) async -> [ObservableItem] {
        items.filter { item in
            item.displayName.localizedStandardContains(searchText)
        }
    }
}

extension DatabaseRecordProvider where Self == ItemProvider {
    static var item: ItemProvider {
        ItemProvider()
    }
}
