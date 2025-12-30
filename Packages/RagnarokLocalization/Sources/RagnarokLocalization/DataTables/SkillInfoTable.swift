//
//  SkillInfoTable.swift
//  RagnarokLocalization
//
//  Created by Leon Li on 2025/8/5.
//

import Foundation

struct SkillInfo: Decodable {
    var skillName: String?
    var skillDescription: String?
}

final public class SkillInfoTable {
    let skillInfosByID: [Int : SkillInfo]

    public init(locale: Locale = .current) {
        guard let url = Bundle.module.url(forResource: "SkillInfo", withExtension: "json", locale: locale) else {
            self.skillInfosByID = [:]
            return
        }

        do {
            let decoder = JSONDecoder()
            let data = try Data(contentsOf: url)
            self.skillInfosByID = try decoder.decode([Int : SkillInfo].self, from: data)
        } catch {
            self.skillInfosByID = [:]
        }
    }

    public func localizedSkillName(forSkillID skillID: Int) -> String? {
        skillInfosByID[skillID]?.skillName
    }

    public func localizedSkillDescription(forSkillID skillID: Int) -> String? {
        skillInfosByID[skillID]?.skillDescription
    }
}
