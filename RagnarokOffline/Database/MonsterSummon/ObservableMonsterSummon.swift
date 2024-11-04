//
//  ObservableMonsterSummon.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/5/9.
//

import Observation
import RODatabase

@Observable
@dynamicMemberLookup
class ObservableMonsterSummon {
    private let mode: DatabaseMode
    private let monsterSummon: MonsterSummon

    var defaultMonster: ObservableMonster?
    var summonMonsters: [Summon]?

    init(mode: DatabaseMode, monsterSummon: MonsterSummon) {
        self.mode = mode
        self.monsterSummon = monsterSummon
    }

    subscript<Value>(dynamicMember keyPath: KeyPath<MonsterSummon, Value>) -> Value {
        monsterSummon[keyPath: keyPath]
    }

    func fetchDetail() async throws {
        let monsterDatabase = MonsterDatabase.database(for: mode)

        if let monster = try await monsterDatabase.monster(forAegisName: monsterSummon.default) {
            defaultMonster = ObservableMonster(mode: mode, monster: monster)
        }

        var summonMonsters: [Summon] = []
        for summon in monsterSummon.summon {
            if let monster = try await monsterDatabase.monster(forAegisName: summon.monster) {
                let monster = ObservableMonster(mode: mode, monster: monster)
                let summon = Summon(monster: monster, rate: summon.rate)
                summonMonsters.append(summon)
            }
        }
        self.summonMonsters = summonMonsters
    }
}

extension ObservableMonsterSummon {
    struct Summon: Identifiable {
        var monster: ObservableMonster
        var rate: Int

        var id: Int {
            monster.id
        }
    }
}

extension ObservableMonsterSummon: Equatable {
    static func == (lhs: ObservableMonsterSummon, rhs: ObservableMonsterSummon) -> Bool {
        lhs.monsterSummon == rhs.monsterSummon
    }
}

extension ObservableMonsterSummon: Hashable {
    func hash(into hasher: inout Hasher) {
        monsterSummon.hash(into: &hasher)
    }
}

extension ObservableMonsterSummon: Identifiable {
    var id: String {
        monsterSummon.group
    }
}
