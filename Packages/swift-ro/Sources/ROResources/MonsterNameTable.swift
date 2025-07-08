//
//  MonsterNameTable.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/5/29.
//

import Foundation

final public class MonsterNameTable: Resource {
    let monsterNamesByID: [Int : String]

    init(monsterNamesByID: [Int : String] = [:]) {
        self.monsterNamesByID = monsterNamesByID
    }

    public func localizedMonsterName(forMonsterID monsterID: Int) -> String? {
        monsterNamesByID[monsterID]
    }
}

extension ResourceManager {
    public func monsterNameTable() async -> MonsterNameTable {
        if let task = tasks.withLock({ $0["MonsterNameTable"] }) {
            return await task.value as! MonsterNameTable
        }

        let task = Task<any Resource, Never> {
            guard let url = Bundle.module.url(forResource: "mobname", withExtension: "txt", locale: locale),
                  let string = try? String(contentsOf: url, encoding: .utf8) else {
                return MonsterNameTable()
            }

            var monsterNamesByID: [Int : String] = [:]

            let lines = string.split(separator: "\n")
            for line in lines {
                if line.trimmingCharacters(in: .whitespaces).starts(with: "//") {
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

            return MonsterNameTable(monsterNamesByID: monsterNamesByID)
        }

        tasks.withLock {
            $0["MonsterNameTable"] = task
        }

        return await task.value as! MonsterNameTable
    }
}
