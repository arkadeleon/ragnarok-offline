//
//  ObservableMonsterDatabase.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/4/4.
//  Copyright © 2024 Leon & Vane. All rights reserved.
//

import Combine
import rAthenaDatabase

@MainActor
class ObservableMonsterDatabase: ObservableObject {
    let database: Database

    @Published var status: AsyncContentStatus<[Monster]> = .notYetLoaded
    @Published var searchText = ""
    @Published var filteredMonsters: [Monster] = []

    init(database: Database) {
        self.database = database
    }

    func fetchMonsters() async {
        guard case .notYetLoaded = status else {
            return
        }

        status = .loading

        do {
            let monsters = try await database.monsters()
            status = .loaded(monsters)
            filterMonsters()
        } catch {
            status = .failed(error)
        }
    }

    func filterMonsters() {
        guard case .loaded(let monsters) = status else {
            return
        }

        if searchText.isEmpty {
            filteredMonsters = monsters
        } else {
            filteredMonsters = monsters.filter { monster in
                monster.name.localizedStandardContains(searchText)
            }
        }
    }
}
