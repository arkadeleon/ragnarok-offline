//
//  SkillProvider.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/4/4.
//

import rAthenaCommon
import RODatabase

struct SkillProvider: DatabaseRecordProvider {
    func records(for mode: ServerMode) async throws -> [Skill] {
        let database = SkillDatabase.database(for: mode)
        let skills = try await database.skills()
        return skills
    }

    func records(matching searchText: String, in skills: [Skill]) async -> [Skill] {
        skills.filter { skill in
            skill.name.localizedStandardContains(searchText)
        }
    }
}

extension DatabaseRecordProvider where Self == SkillProvider {
    static var skill: SkillProvider {
        SkillProvider()
    }
}
