//
//  SkillInfoTable.swift
//  RagnarokOffline
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
        let taskIdentifier = "SkillInfoTable-\(localeIdentifier)"

        if let task = tasks.withLock({ $0[taskIdentifier] }) {
            return await task.value as! SkillInfoTable
        }

        let task = Task<any Resource, Never> {
            if let url = Bundle.module.url(forResource: "SkillInfo", withExtension: "json", locale: locale),
               let skillInfoTable = try? SkillInfoTable(contentsOf: url) {
                return skillInfoTable
            } else {
                return SkillInfoTable()
            }
        }

        tasks.withLock {
            $0[taskIdentifier] = task
        }

        return await task.value as! SkillInfoTable
    }
}
