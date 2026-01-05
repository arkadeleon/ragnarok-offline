//
//  MonsterSummonDatabase.swift
//  RagnarokDatabase
//
//  Created by Leon Li on 2024/5/9.
//

import Foundation
import RapidYAML

final public class MonsterSummonDatabase: Sendable {
    public let baseURL: URL
    public let mode: DatabaseMode

    public init(baseURL: URL, mode: DatabaseMode) {
        self.baseURL = baseURL
        self.mode = mode
    }

    public func monsterSummons() async throws -> [MonsterSummon] {
        metric.beginMeasuring("Load monster summons")

        let decoder = YAMLDecoder()

        let url = baseURL.appending(path: "db/\(mode.path)/mob_summon.yml")
        let data = try Data(contentsOf: url)
        let monsterSummons = try decoder.decode(ListNode<MonsterSummon>.self, from: data).body

        metric.endMeasuring("Load monster summons")

        return monsterSummons
    }
}
