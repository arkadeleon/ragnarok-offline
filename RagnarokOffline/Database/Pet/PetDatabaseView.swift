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
        ImageGrid(database.filteredRecords) { pet in
            if let monster = pet.monster {
                NavigationLink(value: pet) {
                    MonsterGridCell(monster: monster, secondaryText: nil)
                }
                .buttonStyle(.plain)
            }
        }
        .navigationTitle("Pet Database")
        .databaseRoot($database) {
            ContentUnavailableView("No Results", systemImage: "pawprint.fill")
        }
    }
}

#Preview {
    PetDatabaseView()
}
