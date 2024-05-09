//
//  PetDatabaseView.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/5/8.
//

import SwiftUI

struct PetDatabaseView: View {
    @ObservedObject var petDatabase: ObservablePetDatabase

    var body: some View {
        ScrollView {
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 80), spacing: 20)], alignment: .center, spacing: 30) {
                ForEach(petDatabase.filteredPets) { pet in
                    NavigationLink(value: pet) {
                        MonsterGridCell(monster: pet.monster, secondaryText: nil)
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 30)
        }
        .overlay {
            if petDatabase.loadStatus == .loading {
                ProgressView()
            }
        }
        .overlay {
            if petDatabase.loadStatus == .loaded && petDatabase.filteredPets.isEmpty {
                EmptyContentView("No Pets")
            }
        }
        .databaseNavigationDestinations(mode: petDatabase.mode)
        .navigationTitle("Pet Database")
        #if !os(macOS)
        .navigationBarTitleDisplayMode(.inline)
        #endif
        .searchable(text: $petDatabase.searchText)
        .onSubmit(of: .search) {
            petDatabase.filterPets()
        }
        .onChange(of: petDatabase.searchText) { _ in
            petDatabase.filterPets()
        }
        .task {
            await petDatabase.fetchPets()
        }
    }
}

//#Preview {
//    PetDatabaseView()
//}
