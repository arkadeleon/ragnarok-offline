//
//  MonsterSummonInfoView.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/5/9.
//

import SwiftUI

struct MonsterSummonInfoView: View {
    @ObservedObject var monsterSummon: ObservableMonsterSummon

    var body: some View {
        ScrollView {
            if let defaultMonster = monsterSummon.defaultMonster {
                DatabaseRecordInfoSection("Default", verticalSpacing: 0) {
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 80), spacing: 20)], alignment: .leading, spacing: 30) {
                        NavigationLink(value: defaultMonster) {
                            MonsterGridCell(monster: defaultMonster, secondaryText: nil)
                        }
                    }
                    .padding(.vertical, 30)
                }
            }

            if let summonMonsters = monsterSummon.summonMonsters {
                DatabaseRecordInfoSection("Summon", verticalSpacing: 0) {
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 80), spacing: 20)], alignment: .leading, spacing: 30) {
                        ForEach(summonMonsters) { summonMonster in
                            NavigationLink(value: summonMonster.monster) {
                                MonsterGridCell(monster: summonMonster.monster, secondaryText: "\(summonMonster.rate)")
                            }
                        }
                    }
                    .padding(.vertical, 30)
                }
            }
        }
        .navigationTitle(monsterSummon.monsterSummon.group)
        .task {
            await monsterSummon.fetchMonsterSummonInfo()
        }
    }
}

//#Preview {
//    MonsterSummonInfoView()
//}
