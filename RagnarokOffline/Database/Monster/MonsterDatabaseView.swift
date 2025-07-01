//
//  MonsterDatabaseView.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/1/3.
//

import SwiftUI

struct MonsterDatabaseView: View {
    @Environment(ObservableDatabase<MonsterProvider>.self) private var database

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
    }
}

#Preview("Pre-Renewal Monster Database") {
    MonsterDatabaseView()
        .environment(ObservableDatabase(mode: .prerenewal, recordProvider: .monster))
}

#Preview("Renewal Monster Database") {
    MonsterDatabaseView()
        .environment(ObservableDatabase(mode: .renewal, recordProvider: .monster))
}
