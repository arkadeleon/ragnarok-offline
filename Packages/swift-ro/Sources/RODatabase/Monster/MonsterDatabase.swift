//
//  MonsterDatabase.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/5/9.
//

import Foundation
import rAthenaResources

public actor MonsterDatabase {
    public static let prerenewal = MonsterDatabase(mode: .prerenewal)
    public static let renewal = MonsterDatabase(mode: .renewal)

    public static func database(for mode: DatabaseMode) -> MonsterDatabase {
        switch mode {
        case .prerenewal: .prerenewal
        case .renewal: .renewal
        }
    }

    public let mode: DatabaseMode

    private lazy var _monsters: [Monster] = {
        do {
            let decoder = YAMLDecoder()

            let url = ServerResourceManager.default.sourceURL
                .appending(path: "db/\(mode.path)/mob_db.yml")
            let data = try Data(contentsOf: url)
            let monsters = try decoder.decode(ListNode<Monster>.self, from: data).body

            return monsters
        } catch {
            logger.warning("\(error.localizedDescription)")
            return []
        }
    }()

    private lazy var _monstersByID: [Int : Monster] = {
        Dictionary(
            _monsters.map({ ($0.id, $0) }),
            uniquingKeysWith: { (first, _) in first }
        )
    }()

    private lazy var _monstersByAegisName: [String : Monster] = {
        Dictionary(
            _monsters.map({ ($0.aegisName, $0) }),
            uniquingKeysWith: { (first, _) in first }
        )
    }()

    private init(mode: DatabaseMode) {
        self.mode = mode
    }

    public func monsters() -> [Monster] {
        _monsters
    }

    public func monster(forID id: Int) -> Monster? {
        _monstersByID[id]
    }

    public func monster(forAegisName aegisName: String) -> Monster? {
        _monstersByAegisName[aegisName]
    }
}
