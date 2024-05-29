//
//  MonsterLocalization.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/5/29.
//

import Foundation

public actor MonsterLocalization {
    public static let shared = MonsterLocalization(locale: .current)

    let locale: Locale

    var monsterNameTable: [Int : String] = [:]
    var isMonsterNameTableLoaded = false

    init(locale: Locale) {
        self.locale = locale
    }

    public func localizedName(for monsterID: Int) -> String? {
        try? loadMonsterNameTableIfNeeded()

        let monsterName = monsterNameTable[monsterID]
        return monsterName
    }

    private func loadMonsterNameTableIfNeeded() throws {
        guard !isMonsterNameTableLoaded else {
            return
        }

        defer {
            isMonsterNameTableLoaded = true
        }

        guard let url = Bundle.module.url(forResource: "mobname", withExtension: "txt", locale: locale) else {
            return
        }

        let data = try Data(contentsOf: url)

        guard let string = String(data: data, encoding: .utf8) else {
            return
        }

        let lines = string.split(separator: "\n")

        for line in lines {
            if line.trimmingCharacters(in: .whitespacesAndNewlines).starts(with: "//") {
                continue
            }

            let columns = line.split(separator: ",")
            if columns.count >= 2 {
                if let monsterID = Int(String(columns[0])) {
                    let monsterName = String(columns[1])
                    monsterNameTable[monsterID] = monsterName
                }
            }
        }
    }
}
