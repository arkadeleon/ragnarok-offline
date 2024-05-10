//
//  ObservableMonsterSummon.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/5/9.
//

import Combine
import rAthenaCommon
import RODatabase

class ObservableMonsterSummon: NSObject, ObservableObject {
    let mode: ServerMode
    let monsterSummon: MonsterSummon

    @Published var defaultMonster: Monster?
    @Published var summonMonsters: [Summon]?

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
