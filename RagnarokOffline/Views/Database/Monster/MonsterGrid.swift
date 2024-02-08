//
//  MonsterGrid.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/1/3.
//  Copyright © 2024 Leon & Vane. All rights reserved.
//

import SwiftUI
import rAthenaDatabase

struct MonsterGrid: View {
    let database: Database

    var body: some View {
        DatabaseRecordGrid {
            try await database.fetchMonsters()
        } filter: { monsters, searchText in
            monsters.filter { monster in
                monster.name.localizedCaseInsensitiveContains(searchText)
            }
        } content: { monster in
            NavigationLink {
                MonsterDetailView(database: database, monster: monster)
            } label: {
                MonsterGridCell(database: database, monster: monster)
            }
        }
        .navigationTitle("Monsters")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    MonsterGrid(database: .renewal)
}
