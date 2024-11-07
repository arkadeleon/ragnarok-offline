//
//  MonsterSummonInfoView.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/5/9.
//

import SwiftUI

struct MonsterSummonInfoView: View {
    var monsterSummon: ObservableMonsterSummon

    var body: some View {
        ScrollView {
            LazyVStack(pinnedViews: .sectionHeaders) {
                if let defaultMonster = monsterSummon.defaultMonster {
                    DatabaseRecordSectionView("Default") {
                        NavigationLink(value: defaultMonster) {
                            MonsterGridCell(monster: defaultMonster, secondaryText: nil)
                        }
                        .buttonStyle(.plain)
                    }
                }

                if let summonMonsters = monsterSummon.summonMonsters {
                    DatabaseRecordSectionView("Summon", spacing: 30) {
                        LazyVGrid(columns: [GridItem(.adaptive(minimum: 80), spacing: 20)], alignment: .leading, spacing: 30) {
                            ForEach(summonMonsters) { summonMonster in
                                NavigationLink(value: summonMonster.monster) {
                                    MonsterGridCell(monster: summonMonster.monster, secondaryText: summonMonster.rate.formatted())
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }
                }
            }
        }
        .background(.background)
        .navigationTitle(monsterSummon.displayName)
        .task {
            await monsterSummon.fetchDetail()
        }
    }
}
