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

    private var monsterSummons: [MonsterSummon] = []
    private var monsterSummonsByGroups: [String : MonsterSummon] = [:]

    private init(mode: ServerMode) {
        self.mode = mode
    }

    public func allMonsterSummons() throws -> [MonsterSummon] {
        if monsterSummons.isEmpty {
            let decoder = YAMLDecoder()

            let url = ResourceBundle.shared.dbURL
                .appendingPathComponent(mode.dbPath)
                .appendingPathComponent("mob_summon.yml")
            let data = try Data(contentsOf: url)
            monsterSummons = try decoder.decode(ListNode<MonsterSummon>.self, from: data).body
        }

        return monsterSummons
    }

    public func monsterSummon(forGroup group: String) async throws -> MonsterSummon {
        if monsterSummonsByGroups.isEmpty {
            let monsterSummons = try allMonsterSummons()
            monsterSummonsByGroups = Dictionary(monsterSummons.map({ ($0.group, $0) }), uniquingKeysWith: { (first, _) in first })
        }

        if let monsterSummon = monsterSummonsByGroups[group] {
            return monsterSummon
        } else {
            throw DatabaseError.recordNotFound
        }
    }
}
