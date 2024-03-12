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
            columns: [GridItem(.adaptive(minimum: 80), spacing: 20)],
            alignment: .center,
            spacing: 30,
            insets: EdgeInsets(top: 30, leading: 20, bottom: 30, trailing: 20),
            partitions: database.monsters(),
            filter: filter) { monster in
                MonsterGridCell(database: database, monster: monster)
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
