//
//  MonsterSummonDatabase.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/5/9.
//

import Foundation
import rAthenaCommon
import rAthenaResource
import rAthenaRyml

public actor MonsterSummonDatabase {
    public static let prerenewal = MonsterSummonDatabase(mode: .prerenewal)
    public static let renewal = MonsterSummonDatabase(mode: .renewal)

    public static func database(for mode: ServerMode) -> MonsterSummonDatabase {
        switch mode {
        case .prerenewal: .prerenewal
        case .renewal: .renewal
        }
    }

    public let mode: ServerMode

    private var cachedMonsterSummons: [MonsterSummon] = []
    private var cachedMonsterSummonsByGroups: [String : MonsterSummon] = [:]

    private init(mode: ServerMode) {
        self.mode = mode
    }

    public func monsterSummons() throws -> [MonsterSummon] {
        if cachedMonsterSummons.isEmpty {
            let decoder = YAMLDecoder()

            let url = ResourceBundle.shared.dbURL
                .appendingPathComponent(mode.dbPath)
                .appendingPathComponent("mob_summon.yml")
            let data = try Data(contentsOf: url)
            cachedMonsterSummons = try decoder.decode(ListNode<MonsterSummon>.self, from: data).body
        }

        return cachedMonsterSummons
    }

    public func monsterSummon(forGroup group: String) throws -> MonsterSummon {
        if cachedMonsterSummonsByGroups.isEmpty {
            let monsterSummons = try monsterSummons()
            cachedMonsterSummonsByGroups = Dictionary(monsterSummons.map({ ($0.group, $0) }), uniquingKeysWith: { (first, _) in first })
        }

        if let monsterSummon = cachedMonsterSummonsByGroups[group] {
            return monsterSummon
        } else {
            throw DatabaseError.recordNotFound
        }
    }
}
