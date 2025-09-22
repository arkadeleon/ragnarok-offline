//
//  SkillInfoTable.swift
//  ResourceManagement
//
//  Created by Leon Li on 2025/8/5.
//

import Foundation

struct SkillInfo: Decodable {
    var skillName: String?
    var skillDescription: String?
}

final public class SkillInfoTable: Resource {
    let skillInfosByID: [Int : SkillInfo]

    init() {
        self.skillInfosByID = [:]
    }

    init(contentsOf url: URL) throws {
        let decoder = JSONDecoder()
        let data = try Data(contentsOf: url)
        self.skillInfosByID = try decoder.decode([Int : SkillInfo].self, from: data)
    }

    public func localizedSkillName(forSkillID skillID: Int) -> String? {
        skillInfosByID[skillID]?.skillName
    }

    public func localizedSkillDescription(forSkillID skillID: Int) -> String? {
        skillInfosByID[skillID]?.skillDescription
    }
}

extension ResourceManager {
    public func skillInfoTable(for locale: Locale) async -> SkillInfoTable {
        let localeIdentifier = locale.identifier(.bcp47)
        let resourceIdentifier = "SkillInfoTable-\(localeIdentifier)"

        if let phase = resources[resourceIdentifier] {
            return await phase.resource as! SkillInfoTable
        }

        let task = ResourceTask {
            if let url = Bundle.module.url(forResource: "SkillInfo", withExtension: "json", locale: locale),
               let skillInfoTable = try? SkillInfoTable(contentsOf: url) {
                return skillInfoTable
            } else {
                return SkillInfoTable()
            }
        }

        resources[resourceIdentifier] = .inProgress(task)

        let skillInfoTable = await task.value as! SkillInfoTable

        resources[resourceIdentifier] = .loaded(skillInfoTable)

        return skillInfoTable
    }
}
