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
        let skills = await database.skills()

        var records: [ObservableSkill] = []
        for skill in skills {
            let record = await ObservableSkill(mode: mode, skill: skill)
            records.append(record)
        }
        return records
    }

    func records(matching searchText: String, in skills: [ObservableSkill]) async -> [ObservableSkill] {
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
