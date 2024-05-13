//
//  ObservableMonsterSummon.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/5/9.
//

import Observation
import rAthenaCommon
import RODatabase

@Observable class ObservableMonsterSummon {
    let mode: ServerMode
    let monsterSummon: MonsterSummon

    var defaultMonster: Monster?
    var summonMonsters: [Summon]?

    init(mode: ServerMode, monsterSummon: MonsterSummon) {
        self.mode = mode
        self.monsterSummon = monsterSummon
    }

    func fetchMonsterSummonInfo() async {
        let monsterDatabase = MonsterDatabase.database(for: mode)

        defaultMonster = try? await monsterDatabase.monster(forAegisName: monsterSummon.default)

        var summonMonsters: [Summon] = []
        for s in monsterSummon.summon {
            if let monster = try? await monsterDatabase.monster(forAegisName: s.monster) {
                let summon = Summon(monster: monster, rate: s.rate)
                summonMonsters.append(summon)
            }
        }
        self.summonMonsters = summonMonsters
    }
}

extension ObservableMonsterSummon {
    struct Summon: Identifiable {
        var monster: Monster
        var rate: Int

        var id: Int {
            monster.id
        }
    }
}

extension ObservableMonsterSummon: Identifiable {
    var id: String {
        monsterSummon.group
    }
}

extension ObservableMonsterSummon: Hashable {
    func hash(into hasher: inout Hasher) {
        monsterSummon.hash(into: &hasher)
    }
}

extension ObservableMonsterSummon: Equatable {
    static func == (lhs: ObservableMonsterSummon, rhs: ObservableMonsterSummon) -> Bool {
        lhs.monsterSummon == rhs.monsterSummon
    }
}
