//
//  MonsterNameTable.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/5/29.
//

import Foundation

final public class MonsterNameTable: Sendable {
    public static let shared = MonsterNameTable(locale: .current)

    let locale: Locale
    let nameTable: [Int : String]

    init(locale: Locale) {
        self.locale = locale

        nameTable = {
            guard let string = resourceBundle.string(forResource: "mobname", withExtension: "txt", encoding: .utf8, locale: locale) else {
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

    public func localizedMonsterName(for monsterID: Int) -> String? {
        nameTable[monsterID]
    }
}
