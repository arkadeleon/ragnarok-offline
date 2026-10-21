//
//  MonsterSummonDetailView.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/5/9.
//

import SwiftUI

struct MonsterSummonDetailView: View {
    var monsterSummon: MonsterSummonModel

    @Environment(DatabaseModel.self) private var database

    var body: some View {
        ImageGrid(monsterSummon.summonMonsters ?? []) { summonMonster in
            NavigationLink(value: summonMonster.monster) {
                MonsterSummonGridCell(summonMonster: summonMonster)
            }
        }
        .background(.background)
        .navigationTitle(monsterSummon.displayName)
        .task {
            await monsterSummon.fetchDetail(database: database)
        }
    }
}
