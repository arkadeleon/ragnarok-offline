//
//  SkillDatabase.swift
//  RagnarokDatabase
//
//  Created by Leon Li on 2024/3/11.
//

import Foundation
import RapidYAML

final public class SkillDatabase: Sendable {
    public let baseURL: URL
    public let mode: DatabaseMode

    public init(baseURL: URL, mode: DatabaseMode) {
        self.baseURL = baseURL
        self.mode = mode
    }

    public func skills() async throws -> [Skill] {
        metric.beginMeasuring("Load skills")

        let decoder = YAMLDecoder()

        let url = baseURL.appending(path: "db/\(mode.path)/skill_db.yml")
        let data = try Data(contentsOf: url)
        let skills = try decoder.decode(ListNode<Skill>.self, from: data).body

        metric.endMeasuring("Load skills")

        return skills
    }
}
