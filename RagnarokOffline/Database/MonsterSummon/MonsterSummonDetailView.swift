//
//  MonsterSummonDetailView.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/5/9.
//

import SwiftUI

struct MonsterSummonDetailView: View {
    var monsterSummon: MonsterSummonModel

    @Environment(\.horizontalSizeClass) private var sizeClass
    @Environment(DatabaseModel.self) private var database

    var body: some View {
        DatabaseRecordDetailView {
            if let defaultMonster = monsterSummon.defaultMonster {
                DatabaseRecordSectionView {
                    LazyVGrid(columns: [imageGridItem(sizeClass)], alignment: .leading, spacing: vSpacing(sizeClass)) {
                        NavigationLink(value: defaultMonster) {
                            ImageGridCell(title: defaultMonster.displayName) {
                                MonsterImageView(monster: defaultMonster)
                            }
                        }
                    }
                    .padding(.vertical, vSpacing(sizeClass))
                } header: {
                    Text("Default", tableName: "Database")
                }
            }

            if let summonMonsters = monsterSummon.summonMonsters {
                DatabaseRecordSectionView {
                    LazyVGrid(columns: [imageGridItem(sizeClass)], alignment: .leading, spacing: vSpacing(sizeClass)) {
                        ForEach(summonMonsters) { summonMonster in
                            NavigationLink(value: summonMonster.monster) {
                                ImageGridCell(
                                    title: summonMonster.monster.displayName,
                                    subtitle: summonMonster.rate.formatted()
                                ) {
                                    MonsterImageView(monster: summonMonster.monster)
                                }
                            }
                        }
                    }
                    .padding(.vertical, vSpacing(sizeClass))
                } header: {
                    Text("Summon", tableName: "Database")
                }
            }
        }
        .navigationTitle(monsterSummon.displayName)
        .task {
            await monsterSummon.fetchDetail(database: database)
        }
    }
}
