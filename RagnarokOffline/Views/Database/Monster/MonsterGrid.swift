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
    public var body: some View {
        DatabaseRecordGrid(itemSize: 80, horizontalSpacing: 32, verticalSpacing: 16) {
            try await Database.renewal.fetchMonsters()
        } filter: { monsters, searchText in
            monsters.filter { monster in
                monster.name.localizedCaseInsensitiveContains(searchText)
            }
        } content: { monster in
            NavigationLink {
                MonsterDetailView(monster: monster)
            } label: {
                MonsterGridCell(monster: monster)
            }
        }
        .navigationTitle("Monsters")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    MonsterGrid()
}
