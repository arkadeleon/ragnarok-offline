//
//  SkillLocalization.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/5/27.
//

import Foundation
import Lua

public actor SkillLocalization {
    public static let shared = SkillLocalization(locale: .current)

    let locale: Locale
    let context = LuaContext()

    var isSkillScriptsLoaded = false

    init(locale: Locale) {
        self.locale = locale
    }

    public func localizedName(for skillID: Int) -> String? {
        try? loadSkillScriptsIfNeeded()

        guard let result = try? context.call("skillName", with: [skillID]) as? String else {
            return nil
        }

        let encoding = locale.language.preferredEncoding
        let skillName = result.data(using: .isoLatin1)?.string(using: encoding)
        return skillName
    }

    public func localizedDescription(for skillID: Int) -> String? {
        try? loadSkillScriptsIfNeeded()

        guard let result = try? context.call("skillDescription", with: [skillID]) as? [String] else {
            return nil
        }

        let encoding = locale.language.preferredEncoding
        let skillDescription = result.joined(separator: "\n").data(using: .isoLatin1)?.string(using: encoding)
        return skillDescription
    }

    private func loadSkillScriptsIfNeeded() throws {
        guard !isSkillScriptsLoaded else {
            return
        }

        if let url = Bundle.module.url(forResource: "jobinheritlist", withExtension: "lub", locale: locale) {
            let data = try Data(contentsOf: url)
            try context.load(data)
        }

        if let url = Bundle.module.url(forResource: "skillid", withExtension: "lub", locale: locale) {
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

        isSkillScriptsLoaded = true
    }
}
