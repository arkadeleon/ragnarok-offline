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

    @Published var loadStatus: LoadStatus = .notYetLoaded
    @Published var searchText = ""
    @Published var maps: [Map] = []
    @Published var filteredMaps: [Map] = []

    init(database: Database) {
        self.database = database
    }

    func fetchMaps() async {
        guard loadStatus == .notYetLoaded else {
            return
        }

        loadStatus = .loading

        do {
            maps = try await database.maps()
            filterMaps()

            loadStatus = .loaded
        } catch {
            loadStatus = .failed
        }
    }

    func filterMaps() {
        if searchText.isEmpty {
            filteredMaps = maps
        } else {
            filteredMaps = maps.filter { map in
                map.name.localizedStandardContains(searchText)
            }
        }
    }
}
