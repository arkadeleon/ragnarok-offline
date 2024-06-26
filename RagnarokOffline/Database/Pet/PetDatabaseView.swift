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
            ScrollView {
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 80), spacing: 20)], alignment: .center, spacing: 30) {
                    ForEach(pets) { pet in
                        NavigationLink(value: pet) {
                            MonsterGridCell(monster: pet.monster, secondaryText: nil)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 30)
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
