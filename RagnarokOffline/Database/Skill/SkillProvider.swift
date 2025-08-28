//
//  SkillProvider.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/4/4.
//

import RODatabase

struct SkillProvider: DatabaseRecordProvider {
    func records(for mode: DatabaseMode) async -> [SkillModel] {
        let database = SkillDatabase.shared
        let skills = await database.skills().map { skill in
            SkillModel(mode: mode, skill: skill)
        }
        return skills
    }

    func prefetchRecords(_ skills: [SkillModel]) async {
        for skill in skills {
            await skill.fetchLocalizedName()
        }
    }

    func records(matching searchText: String, in skills: [SkillModel]) async -> [SkillModel] {
        if searchText.hasPrefix("#") {
            if let skillID = Int(searchText.dropFirst()),
               let skill = skills.first(where: { $0.id == skillID }) {
                return [skill]
            } else {
                return []
            }
        }

        let filteredSkills = skills.filter { skill in
            skill.displayName.localizedStandardContains(searchText)
        }
        return filteredSkills
    }
}

extension DatabaseRecordProvider where Self == SkillProvider {
    static var skill: SkillProvider {
        SkillProvider()
    }
}
