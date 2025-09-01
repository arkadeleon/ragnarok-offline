//
//  PetDatabaseView.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/5/8.
//

import SwiftUI

struct PetDatabaseView: View {
    @Environment(DatabaseModel.self) private var database

    @State private var searchText = ""
    @State private var filteredPets: [PetModel] = []

    var body: some View {
        ImageGrid(filteredPets) { pet in
            if let monster = pet.monster {
                NavigationLink(value: pet) {
                    MonsterGridCell(monster: monster, secondaryText: nil)
                }
                .buttonStyle(.plain)
            }
        }
        .navigationTitle("Pet Database")
        .background(.background)
        .overlay {
            if database.pets.isEmpty {
                ProgressView()
            } else if !searchText.isEmpty && filteredPets.isEmpty {
                ContentUnavailableView("No Results", systemImage: "pawprint.fill")
            }
        }
        .searchable(text: $searchText)
        .task(id: searchText) {
            filteredPets = await pets(matching: searchText, in: database.pets)
        }
        .task {
            await database.fetchPets()
            filteredPets = await pets(matching: searchText, in: database.pets)
        }
    }

    private func pets(matching searchText: String, in pets: [PetModel]) async -> [PetModel] {
        if searchText.isEmpty {
            return pets
        }

        let filteredPets = pets.filter { pet in
            pet.displayName.localizedStandardContains(searchText)
        }
        return filteredPets
    }
}

#Preview("Pre-Renewal Pet Database") {
    NavigationStack {
        PetDatabaseView()
    }
    .environment(DatabaseModel(mode: .prerenewal))
}

#Preview("Renewal Pet Database") {
    NavigationStack {
        PetDatabaseView()
    }
    .environment(DatabaseModel(mode: .renewal))
}
