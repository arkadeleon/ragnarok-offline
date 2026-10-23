//
//  MonsterSummonModel.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/5/9.
//

import Observation
import RagnarokDatabase

@Observable
@dynamicMemberLookup
final class MonsterSummonModel {
    struct Summon: Identifiable {
        var monster: MonsterModel
        var rate: Int?
        var isDefault: Bool

        var id: Int {
            monster.id
        }

        var badges: [DatabaseBadge] {
            var badges: [DatabaseBadge] = []

            if isDefault {
                badges.append(.default)
            }

            if let rate {
                badges.append(.rate(rate, base: 1000000))
            }

            return badges
        }
    }

    private let mode: DatabaseMode
    private let monsterSummon: MonsterSummon

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
    func fetchDetail(database: DatabaseModel) async {
        var summonMonsters: [Summon] = []
        for summon in monsterSummon.summon {
            if let monster = await database.monster(forAegisName: summon.monster) {
                let summon = Summon(monster: monster, rate: summon.rate, isDefault: false)
                summonMonsters.append(summon)
            }
        }

        if let defaultMonster = await database.monster(forAegisName: monsterSummon.default) {
            if let index = summonMonsters.firstIndex(where: { $0.monster.id == defaultMonster.id }) {
                var summon = summonMonsters.remove(at: index)
                summon.isDefault = true
                summonMonsters.insert(summon, at: 0)
            } else {
                let summon = Summon(monster: defaultMonster, rate: nil, isDefault: true)
                summonMonsters.insert(summon, at: 0)
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
