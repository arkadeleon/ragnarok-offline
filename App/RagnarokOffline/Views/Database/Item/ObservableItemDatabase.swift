//
//  ObservableItemDatabase.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/4/3.
//  Copyright © 2024 Leon & Vane. All rights reserved.
//

import Combine

@MainActor
class ObservableItemDatabase: ObservableObject {
    let database: Database

    @Published var loadStatus: LoadStatus = .notYetLoaded
    @Published var searchText = ""
    @Published var items: [Item] = []
    @Published var filteredItems: [Item] = []

    init(database: Database) {
        self.database = database
    }

    func fetchItems() async {
        guard loadStatus == .notYetLoaded else {
            return
        }

        loadStatus = .loading

        do {
            let usableItems = try await database.usableItems()
            items = usableItems
            filterItems()

            loadStatus = .loaded

            let equipItems = try await database.equipItems()
            items = usableItems + equipItems
            filterItems()

            let etcItems = try await database.etcItems()
            items = usableItems + equipItems + etcItems
            filterItems()
        } catch {
            loadStatus = .failed
        }
    }

    func filterItems() {
        if searchText.isEmpty {
            filteredItems = items
        } else {
            filteredItems = items.filter { item in
                item.name.localizedStandardContains(searchText)
            }
        }
    }
}
