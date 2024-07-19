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
        DatabaseView(database: $database) { pets in
            ImageGrid {
                ForEach(pets) { pet in
                    NavigationLink(value: pet) {
                        MonsterGridCell(monster: pet.monster, secondaryText: nil)
                    }
                    .buttonStyle(.plain)
                }
            }
        } empty: {
            ContentUnavailableView("No Pets", systemImage: "pawprint.fill")
        }
        .navigationTitle("Pet Database")
    }
}

#Preview {
    PetDatabaseView()
}
