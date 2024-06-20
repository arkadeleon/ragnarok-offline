//
//  MonsterSummonProvider.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/5/9.
//

import rAthenaCommon
import RODatabase

struct MonsterSummonProvider: DatabaseRecordProvider {
    func records(for mode: ServerMode) async throws -> [ObservableMonsterSummon] {
        let monsterSummonDatabase = MonsterSummonDatabase.database(for: mode)
        let mss = try await monsterSummonDatabase.monsterSummons()

        var monsterSummons: [ObservableMonsterSummon] = []
        for ms in mss {
            let monsterSummon = ObservableMonsterSummon(mode: mode, monsterSummon: ms)
            monsterSummons.append(monsterSummon)
        }
        return monsterSummons
    }

    func records(matching searchText: String, in monsterSummons: [ObservableMonsterSummon]) async -> [ObservableMonsterSummon] {
        monsterSummons.filter { monsterSummon in
            monsterSummon.group.localizedStandardContains(searchText)
        }
    }
}

extension DatabaseRecordProvider where Self == MonsterSummonProvider {
    static var monsterSummon: MonsterSummonProvider {
        MonsterSummonProvider()
    }
}
