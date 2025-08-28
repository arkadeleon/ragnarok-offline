//
//  PetProvider.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/5/8.
//

import RODatabase

struct PetProvider: DatabaseRecordProvider {
    func records(for mode: DatabaseMode) async -> [PetModel] {
        let database = PetDatabase.shared
        let pets = await database.pets().map { pet in
            PetModel(mode: mode, pet: pet)
        }
        return pets
    }

    func prefetchRecords(_ pets: [PetModel], monsterDatabase: DatabaseModel<MonsterProvider>) async {
        await monsterDatabase.fetchRecords()
        for pet in pets {
            pet.fetchMonster(monsterDatabase: monsterDatabase)
        }
    }

    func records(matching searchText: String, in pets: [PetModel]) async -> [PetModel] {
        pets.filter { pet in
            pet.displayName.localizedStandardContains(searchText)
        }
    }
}

extension DatabaseRecordProvider where Self == PetProvider {
    static var pet: PetProvider {
        PetProvider()
    }
}
