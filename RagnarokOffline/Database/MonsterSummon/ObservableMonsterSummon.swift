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
    struct Summon: Identifiable {
        var monster: ObservableMonster
        var rate: Int

        var id: Int {
            monster.id
        }
    }

    private let mode: DatabaseMode
    private let monsterSummon: MonsterSummon

    var defaultMonster: ObservableMonster?
    var summonMonsters: [Summon]?

    var displayName: String {
        monsterSummon.group
    }

    init(mode: DatabaseMode, monsterSummon: MonsterSummon) {
        self.mode = mode
        self.monsterSummon = monsterSummon
    }

    subscript<Value>(dynamicMember keyPath: KeyPath<MonsterSummon, Value>) -> Value {
        monsterSummon[keyPath: keyPath]
    }

    @MainActor
    func fetchDetail() async {
        let monsterDatabase = MonsterDatabase.shared

        if let monster = await monsterDatabase.monster(forAegisName: monsterSummon.default) {
            defaultMonster = ObservableMonster(mode: mode, monster: monster)
        }

        var summonMonsters: [Summon] = []
        for summon in monsterSummon.summon {
            if let monster = await monsterDatabase.monster(forAegisName: summon.monster) {
                let summon = Summon(
                    monster: ObservableMonster(mode: mode, monster: monster),
                    rate: summon.rate
                )
                summonMonsters.append(summon)
            }
        }
        self.summonMonsters = summonMonsters
    }
}

extension ObservableMonsterSummon: Hashable {
    static func == (lhs: ObservableMonsterSummon, rhs: ObservableMonsterSummon) -> Bool {
        lhs.monsterSummon.group == rhs.monsterSummon.group
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(monsterSummon.group)
    }
}

extension ObservableMonsterSummon: Identifiable {
    var id: String {
        monsterSummon.group
    }
}
