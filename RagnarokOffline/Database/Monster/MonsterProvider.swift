//
//  MonsterProvider.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/4/4.
//

import rAthenaCommon
import RODatabase

struct MonsterProvider: DatabaseRecordProvider {
    func records(for mode: ServerMode) async throws -> [Monster] {
        let database = MonsterDatabase.database(for: mode)
        let monsters = try await database.monsters()
        return monsters
    }

    func records(matching searchText: String, in monsters: [Monster]) async -> [Monster] {
        monsters.filter { monster in
            monster.name.localizedStandardContains(searchText)
        }
    }
}

extension DatabaseRecordProvider where Self == MonsterProvider {
    static var monster: MonsterProvider {
        MonsterProvider()
    }
}
