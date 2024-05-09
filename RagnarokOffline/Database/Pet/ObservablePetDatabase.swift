//
//  ObservablePetDatabase.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/5/8.
//

import Combine
import rAthenaCommon
import RODatabase

@MainActor
class ObservablePetDatabase: ObservableObject {
    let mode: ServerMode

    @Published var loadStatus: LoadStatus = .notYetLoaded
    @Published var searchText = ""
    @Published var pets: [ObservablePet] = []
    @Published var filteredPets: [ObservablePet] = []

    init(mode: ServerMode) {
        self.mode = mode
    }

    func fetchPets() async {
        guard loadStatus == .notYetLoaded else {
            return
        }

        loadStatus = .loading

        let petDatabase = PetDatabase.database(for: mode)
        let monsterDatabase = MonsterDatabase.database(for: mode)

        do {
            let ps = try await petDatabase.pets()

            var pets: [ObservablePet] = []
            for p in ps {
                let monster = try await monsterDatabase.monster(forAegisName: p.monster)
                let pet = ObservablePet(mode: mode, pet: p, monster: monster)
                pets.append(pet)
            }
            self.pets = pets

            filterPets()

            loadStatus = .loaded
        } catch {
            loadStatus = .failed
        }
    }

    func filterPets() {
        if searchText.isEmpty {
            filteredPets = pets
        } else {
            filteredPets = pets.filter { pet in
                pet.monster.name.localizedStandardContains(searchText)
            }
        }
    }
}
