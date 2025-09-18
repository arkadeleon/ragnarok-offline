//
//  MonsterSummonDatabase.swift
//  DatabaseCore
//
//  Created by Leon Li on 2024/5/9.
//

import Foundation
import RapidYAML

public actor MonsterSummonDatabase {
    public let sourceURL: URL
    public let mode: DatabaseMode

    private lazy var _monsterSummons: [MonsterSummon] = {
        metric.beginMeasuring("Load monster summon database")

        do {
            let decoder = YAMLDecoder()

            let url = sourceURL.appending(path: "db/\(mode.path)/mob_summon.yml")
            let data = try Data(contentsOf: url)
            let monsterSummons = try decoder.decode(ListNode<MonsterSummon>.self, from: data).body

            metric.endMeasuring("Load monster summon database")

            return monsterSummons
        } catch {
            metric.endMeasuring("Load monster summon database", error)

            return []
        }
    }()

    private lazy var _monsterSummonsByGroup: [String : MonsterSummon] = {
        Dictionary(
            _monsterSummons.map({ ($0.group, $0) }),
            uniquingKeysWith: { (first, _) in first }
        )
    }()

    public init(sourceURL: URL, mode: DatabaseMode) {
        self.sourceURL = sourceURL
        self.mode = mode
    }

    public func monsterSummons() -> [MonsterSummon] {
        _monsterSummons
    }

    public func monsterSummon(forGroup group: String) -> MonsterSummon? {
        _monsterSummonsByGroup[group]
    }
}
