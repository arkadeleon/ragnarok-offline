//
//  SkillInfoTable.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/5/27.
//

import Foundation
@preconcurrency import Lua

final public class SkillInfoTable: Sendable {
    public static let shared = SkillInfoTable(locale: .current)

    let locale: Locale
    let context: LuaContext

    init(locale: Locale) {
        self.locale = locale

        context = {
            let context = LuaContext()

            do {
                if let data = resourceBundle.data(forResource: "jobinheritlist", withExtension: "lub", locale: locale) {
                    try context.load(data)
                }

                if let data = resourceBundle.data(forResource: "skillid", withExtension: "lub", locale: locale) {
                    try context.load(data)
                }

                if let data = resourceBundle.data(forResource: "skillinfolist", withExtension: "lub", locale: locale) {
                    try context.load(data)
                }

                if let data = resourceBundle.data(forResource: "skilldescript", withExtension: "lub", locale: locale) {
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
    }

    public func localizedSkillName(for skillID: Int) -> String? {
        guard let result = try? context.call("skillName", with: [skillID]) as? String else {
            return nil
        }

        let encoding = locale.language.preferredEncoding
        let skillName = result.transcoding(from: .isoLatin1, to: encoding)
        return skillName
    }

    public func localizedSkillDescription(for skillID: Int) -> String? {
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