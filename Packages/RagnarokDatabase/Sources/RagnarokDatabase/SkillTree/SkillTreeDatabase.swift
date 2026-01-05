//
//  SkillTreeDatabase.swift
//  RagnarokDatabase
//
//  Created by Leon Li on 2024/3/11.
//

import Foundation
import RapidYAML

final public class SkillTreeDatabase: Sendable {
    public let baseURL: URL
    public let mode: DatabaseMode

    public init(baseURL: URL, mode: DatabaseMode) {
        self.baseURL = baseURL
        self.mode = mode
    }

    public func skillTrees() async throws -> [SkillTree] {
        metric.beginMeasuring("Load skill trees")

        let decoder = YAMLDecoder()

        let url = baseURL.appending(path: "db/\(mode.path)/skill_tree.yml")
        let data = try Data(contentsOf: url)
        let skillTrees = try decoder.decode(ListNode<SkillTree>.self, from: data).body

        metric.endMeasuring("Load skill trees")

        return skillTrees
    }
}
