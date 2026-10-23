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
                ForEach(previewSummonMonsters) { summonMonster in
                    NavigationLink(value: summonMonster.monster) {
                        ImageGridCell(title: summonMonster.monster.displayName, badges: summonMonster.badges) {
                            MonsterImageView(monster: summonMonster.monster)
                        }
                    }
                }
            }
            .padding(.vertical, vSpacing(sizeClass))
        } header: {
            NavigationLink(value: monsterSummon) {
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

    private var previewSummonMonsters: some RandomAccessCollection<MonsterSummonModel.Summon> {
        (monsterSummon.summonMonsters ?? []).prefix(9)
    }
}
