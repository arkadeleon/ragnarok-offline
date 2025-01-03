//
//  MonsterSummonDatabase.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/5/9.
//

import Foundation
import rAthenaResources

public actor MonsterSummonDatabase {
    public static let prerenewal = MonsterSummonDatabase(mode: .prerenewal)
    public static let renewal = MonsterSummonDatabase(mode: .renewal)

    public static func database(for mode: DatabaseMode) -> MonsterSummonDatabase {
        switch mode {
        case .prerenewal: .prerenewal
        case .renewal: .renewal
        }
    }

    public let mode: DatabaseMode

    private var cachedMonsterSummons: [MonsterSummon] = []
    private var cachedMonsterSummonsByGroup: [String : MonsterSummon] = [:]

    private init(mode: DatabaseMode) {
        self.mode = mode
    }

    public func monsterSummons() throws -> [MonsterSummon] {
        if cachedMonsterSummons.isEmpty {
            let decoder = YAMLDecoder()

            let url = ServerResourceManager.default.sourceURL
                .appending(path: "db/\(mode.path)/mob_summon.yml")
            let data = try Data(contentsOf: url)
            cachedMonsterSummons = try decoder.decode(ListNode<MonsterSummon>.self, from: data).body
        }

        return cachedMonsterSummons
    }

    public func monsterSummon(forGroup group: String) throws -> MonsterSummon? {
        if cachedMonsterSummonsByGroup.isEmpty {
            let monsterSummons = try monsterSummons()
            cachedMonsterSummonsByGroup = Dictionary(monsterSummons.map({ ($0.group, $0) }), uniquingKeysWith: { (first, _) in first })
        }

        let monsterSummon = cachedMonsterSummonsByGroup[group]
        return monsterSummon
    }
}
