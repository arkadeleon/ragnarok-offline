//
//  ItemProvider.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/4/3.
//

import rAthenaCommon
import RODatabase

struct ItemProvider: DatabaseRecordProvider {
    func records(for mode: ServerMode) async throws -> [Item] {
        let database = ItemDatabase.database(for: mode)

        var items: [Item] = []

        let usableItems = try await database.usableItems()
        items = usableItems

        let equipItems = try await database.equipItems()
        items = usableItems + equipItems

        let etcItems = try await database.etcItems()
        items = usableItems + equipItems + etcItems

        return items
    }

    func records(matching searchText: String, in items: [Item]) -> [Item] {
        items.filter { item in
            item.name.localizedStandardContains(searchText)
        }
    }
}

extension DatabaseRecordProvider where Self == ItemProvider {
    static var item: ItemProvider {
        ItemProvider()
    }
}
