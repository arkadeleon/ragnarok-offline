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
                DatabaseRecordSectionView("Default") {
                    LazyVGrid(columns: [imageGridItem(sizeClass)], alignment: .leading, spacing: vSpacing(sizeClass)) {
                        NavigationLink(value: defaultMonster) {
                            MonsterGridCell(monster: defaultMonster, reservesSecondaryTextSpace: false, secondaryText: nil)
                        }
                    }
                    .padding(.vertical, vSpacing(sizeClass))
                }
            }

            if let summonMonsters = monsterSummon.summonMonsters {
                DatabaseRecordSectionView("Summon") {
                    LazyVGrid(columns: [imageGridItem(sizeClass)], alignment: .leading, spacing: vSpacing(sizeClass)) {
                        ForEach(summonMonsters) { summonMonster in
                            NavigationLink(value: summonMonster.monster) {
                                MonsterGridCell(monster: summonMonster.monster, reservesSecondaryTextSpace: true, secondaryText: summonMonster.rate.formatted())
                            }
                        }
                    }
                    .padding(.vertical, vSpacing(sizeClass))
                }
            }
        }
        .navigationTitle(monsterSummon.displayName)
        .task {
            await monsterSummon.fetchDetail(database: database)
        }
    }
}
