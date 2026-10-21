//
//  MonsterSummonSectionView.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2026/10/20.
//

import SwiftUI

struct MonsterSummonSectionView: View {
    var monsterSummon: MonsterSummonModel

    @Environment(\.horizontalSizeClass) private var sizeClass
    @Environment(DatabaseModel.self) private var database

    var body: some View {
        DatabaseRecordSectionView {
            LazyVGrid(columns: [imageGridItem(sizeClass)], alignment: .leading, spacing: vSpacing(sizeClass)) {
                ForEach((monsterSummon.summonMonsters ?? []).prefix(9)) { summonMonster in
                    NavigationLink(value: summonMonster.monster) {
                        MonsterSummonGridCell(summonMonster: summonMonster)
                    }
                }
            }
            .padding(.vertical, vSpacing(sizeClass))
        } header: {
            NavigationLink {
                MonsterSummonDetailView(monsterSummon: monsterSummon)
                    .environment(database)
            } label: {
                HStack {
                    Text("Summon", tableName: "Database")
                        .foregroundStyle(Color.primary)
                    Image(systemName: "chevron.right")
                        .foregroundStyle(Color.secondary)
                }
            }
        }
        .task {
            await monsterSummon.fetchDetail(database: database)
        }
    }
}
