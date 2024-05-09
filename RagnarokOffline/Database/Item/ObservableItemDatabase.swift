//
//  ObservableItemDatabase.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/4/3.
//

import Combine
import rAthenaCommon
import RODatabase

@MainActor
class ObservableItemDatabase: ObservableObject {
    let mode: ServerMode

    @Published var loadStatus: LoadStatus = .notYetLoaded
    @Published var searchText = ""
    @Published var items: [Item] = []
    @Published var filteredItems: [Item] = []

    init(mode: ServerMode) {
        self.mode = mode
    }

    func fetchItems() async {
        guard loadStatus == .notYetLoaded else {
            return
        }

        loadStatus = .loading

        let database = ItemDatabase.database(for: mode)

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
