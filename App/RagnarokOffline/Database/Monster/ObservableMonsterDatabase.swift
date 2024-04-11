//
//  ObservableMonsterDatabase.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/4/4.
//

import Combine
import RODatabase

@MainActor
class ObservableMonsterDatabase: ObservableObject {
    let database: Database

    @Published var loadStatus: LoadStatus = .notYetLoaded
    @Published var searchText = ""
    @Published var monsters: [Monster] = []
    @Published var filteredMonsters: [Monster] = []

    init(database: Database) {
        self.database = database
    }

    func fetchMonsters() async {
        guard loadStatus == .notYetLoaded else {
            return
        }

        loadStatus = .loading

        do {
            monsters = try await database.monsters()
            filterMonsters()

            loadStatus = .loaded
        } catch {
            loadStatus = .failed
        }
    }

    func filterMonsters() {
        if searchText.isEmpty {
            filteredMonsters = monsters
        } else {
            filteredMonsters = monsters.filter { monster in
                monster.name.localizedStandardContains(searchText)
            }
        }
    }
}
