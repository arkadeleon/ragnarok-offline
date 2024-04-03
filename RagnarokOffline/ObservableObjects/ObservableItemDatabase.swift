//
//  ObservableItemDatabase.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/4/3.
//  Copyright © 2024 Leon & Vane. All rights reserved.
//

import Combine
import rAthenaDatabase

class ObservableItemDatabase: ObservableObject {
    let database: Database

    @Published var status: AsyncContentStatus<[Item]> = .notYetLoaded
    @Published var searchText = ""
    @Published var filteredItems: [Item] = []

    init(database: Database) {
        self.database = database
    }

    func fetchItems() {
        guard case .notYetLoaded = status else {
            return
        }

        status = .loading

        Task {
            do {
                let partitions = await database.items()
                for try await partition in partitions {
                    switch status {
                    case .loaded(let records):
                        status = .loaded(records + partition.records)
                        filterItems()
                    default:
                        status = .loaded(partition.records)
                        filterItems()
                    }
                }
            } catch {
                status = .failed(error)
            }
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
