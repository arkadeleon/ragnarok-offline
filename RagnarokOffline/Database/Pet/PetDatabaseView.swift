//
//  PetDatabaseView.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/5/8.
//

import SwiftUI

struct PetDatabaseView: View {
    @Environment(ObservableDatabase<PetProvider>.self) private var database

    var body: some View {
        ImageGrid(database.filteredRecords) { pet in
            if let monster = pet.monster {
                NavigationLink(value: pet) {
                    MonsterGridCell(monster: monster, secondaryText: nil)
                }
                .buttonStyle(.plain)
            }
        }
        .navigationTitle("Pet Database")
        .databaseRoot(database) {
            ContentUnavailableView("No Results", systemImage: "pawprint.fill")
        }
    }
}

#Preview("Pre-Renewal Pet Database") {
    PetDatabaseView()
        .environment(ObservableDatabase(mode: .prerenewal, recordProvider: .pet))
}

#Preview("Renewal Pet Database") {
    PetDatabaseView()
        .environment(ObservableDatabase(mode: .renewal, recordProvider: .pet))
}
