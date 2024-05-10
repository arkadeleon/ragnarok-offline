//
//  ObservableMapDatabase.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/4/4.
//

import Combine
import rAthenaCommon
import RODatabase

@MainActor
class ObservableMapDatabase: ObservableObject {
    let mode: ServerMode

    @Published var loadStatus: LoadStatus = .notYetLoaded
    @Published var searchText = ""
    @Published var maps: [Map] = []
    @Published var filteredMaps: [Map] = []

    init(mode: ServerMode) {
        self.mode = mode
    }

    func fetchMaps() async {
        guard loadStatus == .notYetLoaded else {
            return
        }

        loadStatus = .loading

        let database = MapDatabase.database(for: mode)

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
