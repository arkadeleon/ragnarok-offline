//
//  ObservableMonsterDatabase.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/4/4.
//

import Combine
import rAthenaCommon
import RODatabase

@MainActor
class ObservableMonsterDatabase: ObservableObject {
    let mode: ServerMode

    @Published var loadStatus: LoadStatus = .notYetLoaded
    @Published var searchText = ""
    @Published var monsters: [Monster] = []
    @Published var filteredMonsters: [Monster] = []

    init(mode: ServerMode) {
        self.mode = mode
    }

    func fetchMonsters() async {
        guard loadStatus == .notYetLoaded else {
            return
        }

        loadStatus = .loading

        do {
            let database = MonsterDatabase.database(for: mode)
            monsters = try await database.allMonsters()
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
