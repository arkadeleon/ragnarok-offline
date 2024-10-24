//
//  MonsterInfoTable.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/5/29.
//

import Foundation
@preconcurrency import Lua

final public class MonsterInfoTable: Sendable {
    public static let shared = MonsterInfoTable(locale: .current)

    let locale: Locale
    let context: LuaContext
    let namesByID: [Int : String]

    init(locale: Locale) {
        self.locale = locale

        context = {
            let context = LuaContext()

            do {
                if let url = Bundle.module.url(forResource: "npcidentity", withExtension: "lub", locale: .korean) {
                    let data = try Data(contentsOf: url)
                    try context.load(data)
                }

                if let url = Bundle.module.url(forResource: "jobname", withExtension: "lub", locale: .korean) {
                    let data = try Data(contentsOf: url)
                    try context.load(data)
                }

                try context.parse("""
                function monsterResourceName(monsterID)
                    return JobNameTable[monsterID]
                end
                """)
            } catch {
                print(error)
            }

            return context
        }()

        namesByID = {
            guard let string = Bundle.module.string(forResource: "mobname", withExtension: "txt", encoding: .utf8, locale: locale) else {
                return [:]
            }

            var nameTable: [Int : String] = [:]

            let lines = string.split(separator: "\n")
            for line in lines {
                if line.trimmingCharacters(in: .whitespacesAndNewlines).starts(with: "//") {
                    continue
                }

                let columns = line.split(separator: ",")
                if columns.count >= 2 {
                    if let monsterID = Int(String(columns[0])) {
                        let monsterName = String(columns[1])
                        nameTable[monsterID] = monsterName
                    }
                }
            }

            return nameTable
        }()
    }

    public func monsterResourceName(forMonsterID monsterID: Int) -> String? {
        let result = try? context.call("monsterResourceName", with: [monsterID]) as? String
        return result
    }

    public func localizedMonsterName(forMonsterID monsterID: Int) -> String? {
        namesByID[monsterID]
    }
}
