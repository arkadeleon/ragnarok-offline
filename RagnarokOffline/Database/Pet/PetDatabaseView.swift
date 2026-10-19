//
//  PetDatabaseView.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/5/8.
//

import RagnarokResources
import SwiftUI

struct PetDatabaseView: View {
    @Environment(DatabaseModel.self) private var database

    @State private var searchText = ""
    @State private var filteredPets: [PetModel] = []

    var body: some View {
        ImageGrid(filteredPets) { pet in
            if let monster = pet.monster {
                NavigationLink(value: pet) {
                    ImageGridCell(title: monster.displayName) {
                        MonsterImageView(monster: monster)
                    }
                }
            }
        }
        .background(.background)
        .navigationTitle(Text("Pet Database", tableName: "Database"))
        .adaptiveSearch(text: $searchText)
        .overlay {
            if database.pets.isEmpty {
                ProgressView()
            } else if !searchText.isEmpty && filteredPets.isEmpty {
                ContentUnavailableView {
                    Label {
                        Text("No Results", tableName: "Database")
                    } icon: {
                        Image(systemName: "pawprint.fill")
                    }
                }
            }
        }
        .task(id: "\(searchText)") {
            await database.fetchPets()

            if !searchText.isEmpty {
                do {
                    try await Task.sleep(for: .milliseconds(200))
                } catch {
                    return
                }
            }

            let filteredPets = await pets(matching: searchText)
            if !Task.isCancelled {
                self.filteredPets = filteredPets
            }
        }
    }

    private func pets(matching searchText: String) async -> [PetModel] {
        let pets = database.pets

        if searchText.isEmpty {
            return pets
        }

        let indices = await database.petSearchIndex.indices(matching: searchText)
        return indices.map { pets[$0] }
    }
}

#Preview("Pre-Renewal Pet Database") {
    NavigationStack {
        PetDatabaseView()
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .environment(DatabaseModel(mode: .prerenewal, resourceManager: .previewing))
}

#Preview("Renewal Pet Database") {
    NavigationStack {
        PetDatabaseView()
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .environment(DatabaseModel(mode: .renewal, resourceManager: .previewing))
}
