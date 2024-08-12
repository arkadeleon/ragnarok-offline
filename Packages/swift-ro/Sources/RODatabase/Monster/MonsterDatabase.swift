//
//  MonsterDatabase.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/5/9.
//

import Foundation
import rAthenaCommon
import rAthenaResources

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

    private var cachedMonsters: [Monster] = []
    private var cachedMonstersByID: [Int : Monster] = [:]
    private var cachedMonstersByAegisName: [String : Monster] = [:]

    private init(mode: ServerMode) {
        self.mode = mode
    }

    public func monsters() throws -> [Monster] {
        if cachedMonsters.isEmpty {
            let decoder = YAMLDecoder()

            let url = ServerResourceBundle.shared.dbURL
                .appendingPathComponent(mode.dbPath)
                .appendingPathComponent("mob_db.yml")
            let data = try Data(contentsOf: url)
            cachedMonsters = try decoder.decode(ListNode<Monster>.self, from: data).body
        }

        return cachedMonsters
    }

    public func monster(forID id: Int) throws -> Monster? {
        if cachedMonstersByID.isEmpty {
            let monsters = try monsters()
            cachedMonstersByID = Dictionary(monsters.map({ ($0.id, $0) }), uniquingKeysWith: { (first, _) in first })
        }

        let monster = cachedMonstersByID[id]
        return monster
    }

    public func monster(forAegisName aegisName: String) throws -> Monster? {
        if cachedMonstersByAegisName.isEmpty {
            let monsters = try monsters()
            cachedMonstersByAegisName = Dictionary(monsters.map({ ($0.aegisName, $0) }), uniquingKeysWith: { (first, _) in first })
        }

        let monster = cachedMonstersByAegisName[aegisName]
        return monster
    }
}
