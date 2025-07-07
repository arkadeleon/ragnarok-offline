//
//  MonsterSummonProvider.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/5/9.
//

import RODatabase

struct MonsterSummonProvider: DatabaseRecordProvider {
    func records(for mode: DatabaseMode) async -> [MonsterSummonModel] {
        let database = MonsterSummonDatabase.shared
        let monsterSummons = await database.monsterSummons().map { monsterSummon in
            MonsterSummonModel(mode: mode, monsterSummon: monsterSummon)
        }
        return monsterSummons
    }

    func records(matching searchText: String, in monsterSummons: [MonsterSummonModel]) async -> [MonsterSummonModel] {
        monsterSummons.filter { monsterSummon in
            monsterSummon.displayName.localizedStandardContains(searchText)
        }
    }
}

extension DatabaseRecordProvider where Self == MonsterSummonProvider {
    static var monsterSummon: MonsterSummonProvider {
        MonsterSummonProvider()
    }
}
