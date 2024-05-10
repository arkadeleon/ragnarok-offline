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
        ResponsiveView {
            List(monsterSummonDatabase.filteredMonsterSummons) { monsterSummon in
                NavigationLink(monsterSummon.monsterSummon.group, value: monsterSummon)
            }
            .listStyle(.plain)
        } regular: {
            Table(monsterSummonDatabase.filteredMonsterSummons) {
                TableColumn("Group", value: \.monsterSummon.group)
                TableColumn("Default", value: \.monsterSummon.default)
                TableColumn("Info") { monsterSummon in
                    NavigationLink(value: monsterSummon) {
                        Image(systemName: "info.circle")
                    }
                }
            }
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
