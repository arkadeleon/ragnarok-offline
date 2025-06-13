//
//  MonsterProvider.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/4/4.
//

import RODatabase

struct MonsterProvider: DatabaseRecordProvider {
    func records(for mode: DatabaseMode) async -> [ObservableMonster] {
        let database = MonsterDatabase.shared
        let monsters = await database.monsters().map { monster in
            ObservableMonster(mode: mode, monster: monster)
        }
        return monsters
    }

    func records(matching searchText: String, in monsters: [ObservableMonster]) async -> [ObservableMonster] {
        if searchText.hasPrefix("#") {
            if let monsterID = Int(searchText.dropFirst()),
               let monster = monsters.first(where: { $0.id == monsterID }) {
                return [monster]
            } else {
                return []
            }
        }

        let filteredMonsters = monsters.filter { monster in
            monster.displayName.localizedStandardContains(searchText)
        }
        return filteredMonsters
    }
}

extension DatabaseRecordProvider where Self == MonsterProvider {
    static var monster: MonsterProvider {
        MonsterProvider()
    }
}
