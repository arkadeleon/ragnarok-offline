//
//  MonsterProvider.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/4/4.
//

import RODatabase

struct MonsterProvider: DatabaseRecordProvider {
    func records(for mode: DatabaseMode) async throws -> [ObservableMonster] {
        let database = MonsterDatabase.database(for: mode)
        let monsters = try await database.monsters().map { monster in
            ObservableMonster(mode: mode, monster: monster)
        }
        for monster in monsters {
            monster.fetchLocalizedName()
        }
        return monsters
    }

    func records(matching searchText: String, in monsters: [ObservableMonster]) async -> [ObservableMonster] {
        monsters.filter { monster in
            monster.displayName.localizedStandardContains(searchText)
        }
    }
}

extension DatabaseRecordProvider where Self == MonsterProvider {
    static var monster: MonsterProvider {
        MonsterProvider()
    }
}
