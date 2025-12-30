//
//  MonsterNameTable.swift
//  RagnarokLocalization
//
//  Created by Leon Li on 2024/5/29.
//

import Foundation

final public class MonsterNameTable {
    let monsterNamesByID: [Int : String]

    public init(locale: Locale = .current) {
        guard let url = Bundle.module.url(forResource: "MonsterName", withExtension: "json", locale: locale) else {
            self.monsterNamesByID = [:]
            return
        }

        do {
            let decoder = JSONDecoder()
            let data = try Data(contentsOf: url)
            self.monsterNamesByID = try decoder.decode([Int : String].self, from: data)
        } catch {
            self.monsterNamesByID = [:]
        }
    }

    public func localizedMonsterName(forMonsterID monsterID: Int) -> String? {
        monsterNamesByID[monsterID]
    }
}
