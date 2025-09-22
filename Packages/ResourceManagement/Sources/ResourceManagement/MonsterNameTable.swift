//
//  MonsterNameTable.swift
//  ResourceManagement
//
//  Created by Leon Li on 2024/5/29.
//

import Foundation

final public class MonsterNameTable: Resource {
    let monsterNamesByID: [Int : String]

    init() {
        self.monsterNamesByID = [:]
    }

    init(contentsOf url: URL) throws {
        let decoder = JSONDecoder()
        let data = try Data(contentsOf: url)
        self.monsterNamesByID = try decoder.decode([Int : String].self, from: data)
    }

    public func localizedMonsterName(forMonsterID monsterID: Int) -> String? {
        monsterNamesByID[monsterID]
    }
}

extension ResourceManager {
    public func monsterNameTable(for locale: Locale) async -> MonsterNameTable {
        let localeIdentifier = locale.identifier(.bcp47)
        let resourceIdentifier = "MonsterNameTable-\(localeIdentifier)"

        if let phase = resources[resourceIdentifier] {
            return await phase.resource as! MonsterNameTable
        }

        let task = ResourceTask {
            if let url = Bundle.module.url(forResource: "MonsterName", withExtension: "json", locale: locale),
               let monsterNameTable = try? MonsterNameTable(contentsOf: url) {
                return monsterNameTable
            } else {
                return MonsterNameTable()
            }
        }

        resources[resourceIdentifier] = .inProgress(task)

        let monsterNameTable = await task.value as! MonsterNameTable

        resources[resourceIdentifier] = .loaded(monsterNameTable)

        return monsterNameTable
    }
}
