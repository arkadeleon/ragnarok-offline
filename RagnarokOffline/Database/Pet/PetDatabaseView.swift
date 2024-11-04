//
//  PetDatabaseView.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/5/8.
//

import SwiftUI

struct PetDatabaseView: View {
    @State private var database = ObservableDatabase(mode: .renewal, recordProvider: .pet)

    var body: some View {
        ImageGrid {
            ForEach(database.filteredRecords) { pet in
                NavigationLink(value: pet) {
                    MonsterGridCell(monster: pet.monster, secondaryText: nil)
                }
                .buttonStyle(.plain)
            }
        }
        .navigationTitle("Pet Database")
        .databaseRoot($database) {
            ContentUnavailableView("No Pets", systemImage: "pawprint.fill")
        }
    }
}

#Preview {
    PetDatabaseView()
}
