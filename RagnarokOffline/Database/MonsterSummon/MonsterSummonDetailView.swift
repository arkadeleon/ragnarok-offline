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
    @Environment(DatabaseModel<MonsterProvider>.self) private var monsterDatabase

    var body: some View {
        DatabaseRecordDetailView {
            if let defaultMonster = monsterSummon.defaultMonster {
                DatabaseRecordSectionView("Default") {
                    LazyVGrid(columns: [imageGridItem(sizeClass)], alignment: .leading, spacing: vSpacing(sizeClass)) {
                        NavigationLink(value: defaultMonster) {
                            MonsterGridCell(monster: defaultMonster, secondaryText: nil)
                        }
                        .buttonStyle(.plain)
                    }
                    .padding(.vertical, vSpacing(sizeClass))
                }
            }

            if let summonMonsters = monsterSummon.summonMonsters {
                DatabaseRecordSectionView("Summon") {
                    LazyVGrid(columns: [imageGridItem(sizeClass)], alignment: .leading, spacing: vSpacing(sizeClass)) {
                        ForEach(summonMonsters) { summonMonster in
                            NavigationLink(value: summonMonster.monster) {
                                MonsterGridCell(monster: summonMonster.monster, secondaryText: summonMonster.rate.formatted())
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.vertical, vSpacing(sizeClass))
                }
            }
        }
        .navigationTitle(monsterSummon.displayName)
        .task {
            await monsterSummon.fetchDetail(monsterDatabase: monsterDatabase)
        }
    }
}
