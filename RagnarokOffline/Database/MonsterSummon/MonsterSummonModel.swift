//
//  MonsterSummonModel.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/5/9.
//

import Foundation
import Observation
import RagnarokDatabase

@Observable
@dynamicMemberLookup
final class MonsterSummonModel {
    struct Summon: Identifiable {
        var monster: MonsterModel
        var probability: Double
        var isDefault: Bool

        var id: Int {
            monster.id
        }

        var badges: [DatabaseBadge] {
            var badges: [DatabaseBadge] = []

            if isDefault {
                badges.append(.default)
            }

            badges.append(.probability(probability))

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
                let summon = Summon(monster: monster, probability: probability(forMonsterAegisName: summon.monster), isDefault: false)
                summonMonsters.append(summon)
            }
        }

        if let defaultMonster = await database.monster(forAegisName: monsterSummon.default) {
            if let index = summonMonsters.firstIndex(where: { $0.monster.id == defaultMonster.id }) {
                var summon = summonMonsters.remove(at: index)
                summon.isDefault = true
                summonMonsters.insert(summon, at: 0)
            } else {
                let summon = Summon(monster: defaultMonster, probability: probability(forMonsterAegisName: monsterSummon.default), isDefault: true)
                summonMonsters.insert(summon, at: 0)
            }
        }

        self.summonMonsters = summonMonsters
    }

    /// The chance from 0 to 1 that 1 summon from this group gives the monster, including the fallback to the default monster.
    ///
    /// Each attempt picks an entry at random and keeps it with a chance of `Rate / 1000000`.
    /// After 3 attempts per entry without a hit, the summon gives the default monster.
    /// The Taekwon Mission skill keeps every pick, so its rates do not matter.
    func probability(forMonsterAegisName monsterAegisName: String) -> Double {
        let summons = monsterSummon.summon
        guard !summons.isEmpty else {
            return 0
        }

        let usesRate = monsterSummon.group.uppercased() != "TAEKWON_MISSION"
        let keepChances = summons.map { usesRate ? min(Double($0.rate) / 1000000, 1) : 1 }
        let count = Double(summons.count)
        let attemptChance = keepChances.reduce(0, +) / count
        let fallbackChance = pow(1 - attemptChance, 3 * count)

        var probability = 0.0
        if attemptChance > 0 {
            for (summon, keepChance) in zip(summons, keepChances) where summon.monster == monsterAegisName {
                probability += keepChance / count * (1 - fallbackChance) / attemptChance
            }
        }
        if monsterSummon.default == monsterAegisName {
            probability += fallbackChance
        }
        return probability
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
