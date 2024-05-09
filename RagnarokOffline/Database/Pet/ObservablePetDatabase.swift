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

        do {
            let database = PetDatabase.database(for: mode)
            let allPets = try await database.allPets()

            var pets: [ObservablePet] = []
            for p in allPets {
                let database = Database.database(for: mode)
                let monster = try await database.monster(forAegisName: p.monster)
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
