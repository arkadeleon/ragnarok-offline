//
//  PetProvider.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/5/8.
//

import RODatabase

struct PetProvider: DatabaseRecordProvider {
    func records(for mode: DatabaseMode) async -> [ObservablePet] {
        let database = PetDatabase.shared
        let pets = await database.pets().map { pet in
            ObservablePet(mode: mode, pet: pet)
        }
        for pet in pets {
            await pet.fetchMonster()
        }
        return pets
    }

    func records(matching searchText: String, in pets: [ObservablePet]) async -> [ObservablePet] {
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
