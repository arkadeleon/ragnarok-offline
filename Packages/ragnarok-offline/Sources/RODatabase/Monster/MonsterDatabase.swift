//
//  MonsterDatabase.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/5/9.
//

import Foundation
import rAthenaCommon
import rAthenaResource
import rAthenaRyml

public actor MonsterDatabase {
    public static let prerenewal = MonsterDatabase(mode: .prerenewal)
    public static let renewal = MonsterDatabase(mode: .renewal)

    public static func database(for mode: ServerMode) -> MonsterDatabase {
        switch mode {
        case .prerenewal: .prerenewal
        case .renewal: .renewal
        }
    }

    public let mode: ServerMode

    private var monsters: [Monster] = []
    private var monstersByIDs: [Int : Monster] = [:]
    private var monstersByAegisNames: [String : Monster] = [:]

    private init(mode: ServerMode) {
        self.mode = mode
    }

    public func allMonsters() throws -> [Monster] {
        if monsters.isEmpty {
            let decoder = YAMLDecoder()

            let url = ResourceBundle.shared.dbURL
                .appendingPathComponent(mode.dbPath)
                .appendingPathComponent("mob_db.yml")
            let data = try Data(contentsOf: url)
            monsters = try decoder.decode(ListNode<Monster>.self, from: data).body
        }

        return monsters
    }

    public func monster(forID id: Int) async throws -> Monster {
        if monstersByIDs.isEmpty {
            let monsters = try allMonsters()
            monstersByIDs = Dictionary(monsters.map({ ($0.id, $0) }), uniquingKeysWith: { (first, _) in first })
        }

        if let monster = monstersByIDs[id] {
            return monster
        } else {
            throw DatabaseError.recordNotFound
        }
    }

    public func monster(forAegisName aegisName: String) async throws -> Monster {
        if monstersByAegisNames.isEmpty {
            let monsters = try allMonsters()
            monstersByAegisNames = Dictionary(monsters.map({ ($0.aegisName, $0) }), uniquingKeysWith: { (first, _) in first })
        }

        if let monster = monstersByAegisNames[aegisName] {
            return monster
        } else {
            throw DatabaseError.recordNotFound
        }
    }
}
