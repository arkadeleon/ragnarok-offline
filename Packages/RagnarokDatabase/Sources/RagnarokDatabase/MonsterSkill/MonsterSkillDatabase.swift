//
//  MonsterSkillDatabase.swift
//  RagnarokDatabase
//
//  Created by Leon Li on 2026/10/19.
//

import Foundation

final public class MonsterSkillDatabase: Sendable {
    public let baseURL: URL
    public let mode: DatabaseMode

    public init(baseURL: URL, mode: DatabaseMode) {
        self.baseURL = baseURL
        self.mode = mode
    }

    public func monsterSkills() async throws -> [MonsterSkill] {
        metric.beginMeasuring("Load monster skills")

        let url = baseURL.appending(path: "db/\(mode.path)/mob_skill_db.txt")
        let string = try String(contentsOf: url, encoding: .utf8)

        var monsterSkills: [MonsterSkill] = []

        for line in string.split(whereSeparator: \.isNewline) {
            let line = line.trimmingCharacters(in: .whitespaces)
            if line.isEmpty || line.hasPrefix("//") {
                continue
            }

            let columns = line.split(separator: ",", omittingEmptySubsequences: false).map(String.init)

            // A `clear` row removes the skills defined before it for the same monster.
            if columns.count > 1, columns[1] == "clear", let monsterID = Int(columns[0]) {
                monsterSkills.removeAll(where: { $0.monsterID == monsterID })
                continue
            }

            if let monsterSkill = MonsterSkill(columns) {
                monsterSkills.append(monsterSkill)
            }
        }

        metric.endMeasuring("Load monster skills")

        return monsterSkills
    }
}
