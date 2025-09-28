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

final public class SkillInfoTable: LocalizedResource {
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

        return await cache.resource(forIdentifier: resourceIdentifier) {
            if let url = Bundle.module.url(forResource: "SkillInfo", withExtension: "json", locale: locale),
               let skillInfoTable = try? SkillInfoTable(contentsOf: url) {
                return skillInfoTable
            } else {
                return SkillInfoTable()
            }
        }
    }
}
