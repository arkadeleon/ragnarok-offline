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
        let skills = await database.skills()

        var records: [SkillModel] = []
        for skill in skills {
            let record = await SkillModel(mode: mode, skill: skill)
            records.append(record)
        }
        return records
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
