//
//  MonsterDatabaseView.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/1/3.
//

import SwiftUI

struct MonsterDatabaseView: View {
    @Environment(DatabaseModel<MonsterProvider>.self) private var database

    var body: some View {
        ImageGrid(database.filteredRecords) { monster in
            NavigationLink(value: monster) {
                MonsterGridCell(monster: monster, secondaryText: nil)
            }
            .buttonStyle(.plain)
        }
        .navigationTitle("Monster Database")
        .databaseRoot(database) {
            ContentUnavailableView("No Results", systemImage: "pawprint.fill")
        }
        .task {
            await database.fetchRecords()
            await database.recordProvider.prefetchRecords(database.records)
        }
    }
}

#Preview("Pre-Renewal Monster Database") {
    NavigationStack {
        MonsterDatabaseView()
    }
    .environment(DatabaseModel(mode: .prerenewal, recordProvider: .monster))
}

#Preview("Renewal Monster Database") {
    NavigationStack {
        MonsterDatabaseView()
    }
    .environment(DatabaseModel(mode: .renewal, recordProvider: .monster))
}
