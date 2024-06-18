//
//  PetProvider.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/5/8.
//

import rAthenaCommon
import RODatabase

struct PetProvider: DatabaseRecordProvider {
    func records(for mode: ServerMode) async throws -> [ObservablePet] {
        let petDatabase = PetDatabase.database(for: mode)
        let monsterDatabase = MonsterDatabase.database(for: mode)

        let ps = try await petDatabase.pets()

        var pets: [ObservablePet] = []
        for p in ps {
            if let monster = try? await monsterDatabase.monster(forAegisName: p.monster) {
                let pet = ObservablePet(mode: mode, pet: p, monster: monster)
                pets.append(pet)
            }
        }

        return pets
    }

    func records(matching searchText: String, in pets: [ObservablePet]) async -> [ObservablePet] {
        pets.filter { pet in
            pet.monster.name.localizedStandardContains(searchText)
        }
    }
}

extension DatabaseRecordProvider where Self == PetProvider {
    static var pet: PetProvider {
        PetProvider()
    }
}
