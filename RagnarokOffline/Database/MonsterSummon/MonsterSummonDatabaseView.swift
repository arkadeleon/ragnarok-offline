//
//  MonsterSummonDatabaseView.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/5/9.
//

import SwiftUI

struct MonsterSummonDatabaseView: View {
    @ObservedObject var monsterSummonDatabase: ObservableMonsterSummonDatabase

    var body: some View {
        ScrollView {
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 280), spacing: 20)], alignment: .leading, spacing: 20) {
                ForEach(monsterSummonDatabase.filteredMonsterSummons, id: \.monsterSummon) { monsterSummon in
                    NavigationLink(value: monsterSummon) {
                        VStack(alignment: .leading, spacing: 2) {
                            Text(monsterSummon.monsterSummon.group)
                                .foregroundColor(.primary)
                                .lineLimit(1)

                            Text("\(monsterSummon.monsterSummon.summon.count)")
                                .foregroundColor(.secondary)
                                .lineLimit(1)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
            }
            .padding(20)
        }
        .overlay {
            if monsterSummonDatabase.loadStatus == .loading {
                ProgressView()
            }
        }
        .overlay {
            if monsterSummonDatabase.loadStatus == .loaded && monsterSummonDatabase.filteredMonsterSummons.isEmpty {
                EmptyContentView("No Monster Summons")
            }
        }
        .databaseNavigationDestinations(mode: monsterSummonDatabase.mode)
        .navigationTitle("Monster Summon Database")
        #if !os(macOS)
        .navigationBarTitleDisplayMode(.inline)
        #endif
        .searchable(text: $monsterSummonDatabase.searchText)
        .onSubmit(of: .search) {
            monsterSummonDatabase.filterMonsterSummons()
        }
        .onChange(of: monsterSummonDatabase.searchText) { _ in
            monsterSummonDatabase.filterMonsterSummons()
        }
        .task {
            await monsterSummonDatabase.fetchMonsterSummons()
        }
    }
}

#Preview {
    MonsterSummonDatabaseView(monsterSummonDatabase: .init(mode: .renewal))
}
