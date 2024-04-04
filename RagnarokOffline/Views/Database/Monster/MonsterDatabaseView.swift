//
//  MonsterDatabaseView.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/1/3.
//  Copyright © 2024 Leon & Vane. All rights reserved.
//

import SwiftUI

struct MonsterDatabaseView: View {
    @ObservedObject var monsterDatabase: ObservableMonsterDatabase

    var body: some View {
        AsyncContentView(status: monsterDatabase.status) { monsters in
            ScrollView {
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 80), spacing: 20)], alignment: .center, spacing: 30) {
                    ForEach(monsterDatabase.filteredMonsters) { monster in
                        MonsterGridCell(database: monsterDatabase.database, monster: monster, secondaryText: nil)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 30)
            }
            .searchable(text: $monsterDatabase.searchText)
            .onSubmit(of: .search) {
                monsterDatabase.filterMonsters()
            }
            .onChange(of: monsterDatabase.searchText) { _ in
                monsterDatabase.filterMonsters()
            }
        }
        .navigationTitle("Monster Database")
        .navigationBarTitleDisplayMode(.inline)
        .task {
            monsterDatabase.fetchMonsters()
        }
    }
}
