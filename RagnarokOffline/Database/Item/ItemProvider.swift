//
//  ItemProvider.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/4/3.
//

import RODatabase

struct ItemProvider: DatabaseRecordProvider {
    func records(for mode: DatabaseMode) async throws -> [ObservableItem] {
        let database = ItemDatabase.database(for: mode)
        let usableItems = try await database.usableItems().map { item in
            ObservableItem(mode: mode, item: item)
        }
        for item in usableItems {
            item.fetchLocalizedName()
        }
        return usableItems
    }

    func moreRecords(for mode: DatabaseMode) async throws -> [ObservableItem] {
        let database = ItemDatabase.database(for: mode)
        let equipItems = try await database.equipItems().map { item in
            ObservableItem(mode: mode, item: item)
        }
        let etcItems = try await database.etcItems().map { item in
            ObservableItem(mode: mode, item: item)
        }
        for item in equipItems + etcItems {
            item.fetchLocalizedName()
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
