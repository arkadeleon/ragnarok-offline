//
//  MonsterProvider.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/4/4.
//

import rAthenaCommon
import RODatabase

struct MonsterProvider: DatabaseRecordProvider {
    func records(for mode: ServerMode) async throws -> [ObservableMonster] {
        let database = MonsterDatabase.database(for: mode)
        let monsters = try await database.monsters()

        var observableMonsters: [ObservableMonster] = []
        for monster in monsters {
            let observableMonster = ObservableMonster(mode: mode, monster: monster)
            observableMonsters.append(observableMonster)
        }
        return observableMonsters
    }

    func records(matching searchText: String, in monsters: [ObservableMonster]) async -> [ObservableMonster] {
        monsters.filter { monster in
            monster.localizedName.localizedStandardContains(searchText)
        }
    }
}

extension DatabaseRecordProvider where Self == MonsterProvider {
    static var monster: MonsterProvider {
        MonsterProvider()
    }
}
