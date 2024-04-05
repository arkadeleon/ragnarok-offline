//
//  ObservableMapDatabase.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/4/4.
//  Copyright © 2024 Leon & Vane. All rights reserved.
//

import Combine
import rAthenaDatabase

@MainActor
class ObservableMapDatabase: ObservableObject {
    let database: Database

    @Published var status: AsyncContentStatus<[Map]> = .notYetLoaded
    @Published var searchText = ""
    @Published var filteredMaps: [Map] = []

    init(database: Database) {
        self.database = database
    }

    func fetchMaps() async {
        guard case .notYetLoaded = status else {
            return
        }

        status = .loading

        do {
            let maps = try await database.maps()
            status = .loaded(maps)
            filterMaps()
        } catch {
            status = .failed(error)
        }
    }

    func filterMaps() {
        guard case .loaded(let maps) = status else {
            return
        }

        if searchText.isEmpty {
            filteredMaps = maps
        } else {
            Task {
                filteredMaps = maps.filter { map in
                    map.name.localizedStandardContains(searchText)
                }
            }
        }
    }
}
