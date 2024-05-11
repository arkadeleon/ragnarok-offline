//
//  PetDatabaseView.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/5/8.
//

import SwiftUI

struct PetDatabaseView: View {
    @ObservedObject var database: ObservableDatabase<PetProvider>

    var body: some View {
        DatabaseView(database: database) { pets in
            ScrollView {
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 80), spacing: 20)], alignment: .center, spacing: 30) {
                    ForEach(pets) { pet in
                        NavigationLink(value: pet) {
                            MonsterGridCell(monster: pet.monster, secondaryText: nil)
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 30)
            }
        }
        .navigationTitle("Pet Database")
    }
}

#Preview {
    PetDatabaseView(database: .init(mode: .renewal, recordProvider: .pet))
}
