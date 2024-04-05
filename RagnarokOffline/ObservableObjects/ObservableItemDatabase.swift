//
//  ObservableItemDatabase.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/4/3.
//  Copyright © 2024 Leon & Vane. All rights reserved.
//

import Combine
import rAthenaDatabase

@MainActor
class ObservableItemDatabase: ObservableObject {
    let database: Database

    @Published var status: AsyncContentStatus<[Item]> = .notYetLoaded
    @Published var searchText = ""
    @Published var filteredItems: [Item] = []

    init(database: Database) {
        self.database = database
    }

    func fetchItems() async {
        guard case .notYetLoaded = status else {
            return
        }

        status = .loading

        do {
            let usableItems = try await database.usableItems()
            status = .loaded(usableItems)
            filterItems()

            let equipItems = try await database.equipItems()
            status = .loaded(usableItems + equipItems)
            filterItems()

            let etcItems = try await database.etcItems()
            status = .loaded(usableItems + equipItems + etcItems)
            filterItems()
        } catch {
            status = .failed(error)
        }
    }

    func filterItems() {
        guard case .loaded(let items) = status else {
            return
        }

        if searchText.isEmpty {
            filteredItems = items
        } else {
            Task {
                filteredItems = items.filter { item in
                    item.name.localizedStandardContains(searchText)
                }
            }
        }
    }
}
