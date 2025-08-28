//
//  PetDatabaseView.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/5/8.
//

import SwiftUI

struct PetDatabaseView: View {
    @Environment(DatabaseModel<PetProvider>.self) private var database
    @Environment(DatabaseModel<MonsterProvider>.self) private var monsterDatabase

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
        .task {
            await database.fetchRecords()
            await database.recordProvider.prefetchRecords(database.records, monsterDatabase: monsterDatabase)
        }
    }
}

#Preview("Pre-Renewal Pet Database") {
    NavigationStack {
        PetDatabaseView()
    }
    .environment(DatabaseModel(mode: .prerenewal, recordProvider: .pet))
    .environment(DatabaseModel(mode: .prerenewal, recordProvider: .monster))
}

#Preview("Renewal Pet Database") {
    NavigationStack {
        PetDatabaseView()
    }
    .environment(DatabaseModel(mode: .renewal, recordProvider: .pet))
    .environment(DatabaseModel(mode: .renewal, recordProvider: .monster))
}
