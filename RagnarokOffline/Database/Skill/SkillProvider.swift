//
//  SkillProvider.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/4/4.
//

import RODatabase

struct SkillProvider: DatabaseRecordProvider {
    func records(for mode: DatabaseMode) async -> [ObservableSkill] {
        let database = SkillDatabase.database(for: mode)
        let skills = await database.skills().map { skill in
            ObservableSkill(mode: mode, skill: skill)
        }
        for skill in skills {
            await skill.fetchLocalizedName()
        }
        return skills
    }

    func records(matching searchText: String, in skills: [ObservableSkill]) async -> [ObservableSkill] {
        skills.filter { skill in
            skill.displayName.localizedStandardContains(searchText)
        }
    }
}

extension DatabaseRecordProvider where Self == SkillProvider {
    static var skill: SkillProvider {
        SkillProvider()
    }
}
