//
//  MonsterProvider.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/4/4.
//

import RODatabase

struct MonsterProvider: DatabaseRecordProvider {
    func records(for mode: DatabaseMode) async -> [MonsterModel] {
        let database = MonsterDatabase.shared
        let monsters = await database.monsters().map { monster in
            MonsterModel(mode: mode, monster: monster)
        }
        return monsters
    }

    func prefetchRecords(_ monsters: [MonsterModel], appModel: AppModel) async {
        for monster in monsters {
            await monster.fetchLocalizedName()
        }
    }

    func records(matching searchText: String, in monsters: [MonsterModel]) async -> [MonsterModel] {
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

extension DatabaseModel where RecordProvider == MonsterProvider {
    func monster(forID id: Int) -> MonsterModel? {
        recordsByID[id]
    }

    func monster(forAegisName aegisName: String) -> MonsterModel? {
        records.first(where: { $0.aegisName == aegisName })
    }
}
