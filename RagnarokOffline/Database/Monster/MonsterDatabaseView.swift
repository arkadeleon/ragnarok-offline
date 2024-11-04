//
//  MonsterDatabaseView.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/1/3.
//

import SwiftUI

struct MonsterDatabaseView: View {
    @State private var database = ObservableDatabase(mode: .renewal, recordProvider: .monster)

    var body: some View {
        ImageGrid {
            ForEach(database.filteredRecords) { monster in
                NavigationLink(value: monster) {
                    MonsterGridCell(monster: monster, secondaryText: nil)
                }
                .buttonStyle(.plain)
            }
        }
        .navigationTitle("Monster Database")
        .databaseRoot($database) {
            ContentUnavailableView("No Monsters", systemImage: "pawprint.fill")
        }
    }
}

#Preview {
    MonsterDatabaseView()
}
