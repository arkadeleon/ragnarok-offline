//
//  SkillInfoTable.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/5/27.
//

import Foundation
import Lua

public let skillInfoTable = SkillInfoTable(locale: .current)

public actor SkillInfoTable {
    let locale: Locale

    lazy var context: LuaContext = {
        let context = LuaContext()

        do {
            if let url = Bundle.module.url(forResource: "jobinheritlist", withExtension: "lub", locale: .korean) {
                let data = try Data(contentsOf: url)
                try context.load(data)
            }

            if let url = Bundle.module.url(forResource: "skillid", withExtension: "lub", locale: .korean) {
                let data = try Data(contentsOf: url)
                try context.load(data)
            }

            if let url = Bundle.module.url(forResource: "skillinfolist", withExtension: "lub", locale: locale) {
                let data = try Data(contentsOf: url)
                try context.load(data)
            }

            if let url = Bundle.module.url(forResource: "skilldescript", withExtension: "lub", locale: locale) {
                let data = try Data(contentsOf: url)
                try context.load(data)
            }

            try context.parse("""
            function skillName(skillID)
                return SKILL_INFO_LIST[skillID]["SkillName"]
            end
            function skillDescription(skillID)
                return SKILL_DESCRIPT[skillID]
            end
            """)
        } catch {
            print(error)
        }

        return context
    }()

    init(locale: Locale) {
        self.locale = locale
    }

    public func localizedSkillName(forSkillID skillID: Int) -> String? {
        guard let result = try? context.call("skillName", with: [skillID]) as? String else {
            return nil
        }

        let encoding = locale.language.preferredEncoding
        let skillName = result.transcoding(from: .isoLatin1, to: encoding)
        return skillName
    }

    public func localizedSkillDescription(forSkillID skillID: Int) -> String? {
        guard let result = try? context.call("skillDescription", with: [skillID]) as? [String] else {
            return nil
        }

        let encoding = locale.language.preferredEncoding
        let skillDescription = result
            .joined(separator: "\n")
            .transcoding(from: .isoLatin1, to: encoding)
        return skillDescription
    }
}
