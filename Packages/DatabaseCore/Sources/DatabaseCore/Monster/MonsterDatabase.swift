//
//  MonsterDatabase.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/5/9.
//

import Foundation
import RapidYAML

public actor MonsterDatabase {
    public let sourceURL: URL
    public let mode: DatabaseMode

    private lazy var _monsters: [Monster] = {
        metric.beginMeasuring("Load monster database")

        do {
            let decoder = YAMLDecoder()

            let url = sourceURL.appending(path: "db/\(mode.path)/mob_db.yml")
            let data = try Data(contentsOf: url)
            let monsters = try decoder.decode(ListNode<Monster>.self, from: data).body

            metric.endMeasuring("Load monster database")

            return monsters
        } catch {
            metric.endMeasuring("Load monster database", error)

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

    public init(sourceURL: URL, mode: DatabaseMode) {
        self.sourceURL = sourceURL
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
