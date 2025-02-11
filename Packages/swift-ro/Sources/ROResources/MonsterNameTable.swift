//
//  MonsterNameTable.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/5/29.
//

import Foundation
import Lua

public actor MonsterNameTable {
    public static let current = MonsterNameTable(locale: .current)

    let locale: Locale

    lazy var monsterNamesByID: [Int : String] = {
        guard let url = Bundle.module.url(forResource: "mobname", withExtension: "txt", locale: locale),
              let string = try? String(contentsOf: url, encoding: .utf8) else {
            return [:]
        }

        var monsterNamesByID: [Int : String] = [:]

        let lines = string.split(separator: "\n")
        for line in lines {
            if line.trimmingCharacters(in: .whitespacesAndNewlines).starts(with: "//") {
                continue
            }

            let columns = line.split(separator: ",")
            if columns.count >= 2 {
                if let monsterID = Int(String(columns[0])) {
                    let monsterName = String(columns[1])
                    monsterNamesByID[monsterID] = monsterName
                }
            }
        }

        return monsterNamesByID
    }()

    init(locale: Locale) {
        self.locale = locale
    }

    public func localizedMonsterName(forMonsterID monsterID: Int) -> String? {
        monsterNamesByID[monsterID]
    }
}
