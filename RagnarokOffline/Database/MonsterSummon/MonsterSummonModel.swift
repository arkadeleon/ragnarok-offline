//
//  MonsterSummonModel.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/5/9.
//

import Observation
import RODatabase

@Observable
@dynamicMemberLookup
final class MonsterSummonModel {
    struct Summon: Identifiable {
        var monster: MonsterModel
        var rate: Int

        var id: Int {
            monster.id
        }
    }

    private let mode: DatabaseMode
    private let monsterSummon: MonsterSummon

    var defaultMonster: MonsterModel?
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
            defaultMonster = MonsterModel(mode: mode, monster: monster)
        }

        var summonMonsters: [Summon] = []
        for summon in monsterSummon.summon {
            if let monster = await monsterDatabase.monster(forAegisName: summon.monster) {
                let summon = Summon(
                    monster: MonsterModel(mode: mode, monster: monster),
                    rate: summon.rate
                )
                summonMonsters.append(summon)
            }
        }
        self.summonMonsters = summonMonsters
    }
}

extension MonsterSummonModel: Equatable {
    static func == (lhs: MonsterSummonModel, rhs: MonsterSummonModel) -> Bool {
        lhs.monsterSummon.group == rhs.monsterSummon.group
    }
}

extension MonsterSummonModel: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(monsterSummon.group)
    }
}

extension MonsterSummonModel: Identifiable {
    var id: String {
        monsterSummon.group
    }
}
