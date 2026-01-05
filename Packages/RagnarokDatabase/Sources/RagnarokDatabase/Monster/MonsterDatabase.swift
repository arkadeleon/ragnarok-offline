//
//  MonsterDatabase.swift
//  RagnarokDatabase
//
//  Created by Leon Li on 2024/5/9.
//

import Foundation
import RapidYAML

final public class MonsterDatabase: Sendable {
    public let baseURL: URL
    public let mode: DatabaseMode

    public init(baseURL: URL, mode: DatabaseMode) {
        self.baseURL = baseURL
        self.mode = mode
    }

    public func monsters() async throws -> [Monster] {
        metric.beginMeasuring("Load monsters")

        let decoder = YAMLDecoder()

        let url = baseURL.appending(path: "db/\(mode.path)/mob_db.yml")
        let data = try Data(contentsOf: url)
        let monsters = try decoder.decode(ListNode<Monster>.self, from: data).body

        metric.endMeasuring("Load monsters")

        return monsters
    }
}
