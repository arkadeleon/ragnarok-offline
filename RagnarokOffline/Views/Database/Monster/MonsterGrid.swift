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
        DatabaseRecordGrid(
            columns: [GridItem(.adaptive(minimum: 80), spacing: 16)],
            alignment: .center,
            spacing: 32,
            insets: EdgeInsets(top: 32, leading: 16, bottom: 32, trailing: 16),
            partitions: database.monsters(),
            filter: filter) { monster in
                NavigationLink {
                    MonsterInfoView(database: database, monster: monster)
                } label: {
                    MonsterGridCell(database: database, monster: monster)
                }
            }
            .navigationTitle("Monsters")
            .navigationBarTitleDisplayMode(.inline)
    }

    private func filter(monsters: [Monster], searchText: String) -> [Monster] {
        monsters.filter { monster in
            monster.name.localizedCaseInsensitiveContains(searchText)
        }
    }
}

#Preview {
    MonsterGrid(database: .renewal)
}
