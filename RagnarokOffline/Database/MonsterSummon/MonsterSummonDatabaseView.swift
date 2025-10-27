//
//  MonsterSummonDatabaseView.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/5/9.
//

import RagnarokDatabase
import SwiftUI

struct MonsterSummonDatabaseView: View {
    @Environment(DatabaseModel.self) private var database

    @State private var searchText = ""
    @State private var filteredMonsterSummons: [MonsterSummonModel] = []

    var body: some View {
        AdaptiveView {
            List(filteredMonsterSummons) { monsterSummon in
                NavigationLink(monsterSummon.displayName, value: monsterSummon)
            }
            .listStyle(.plain)
        } regular: {
            List(filteredMonsterSummons) { monsterSummon in
                NavigationLink(value: monsterSummon) {
                    HStack {
                        Text(monsterSummon.displayName)
                            .frame(minWidth: 160, maxWidth: .infinity, alignment: .leading)
                        Text(monsterSummon.default)
                            .frame(minWidth: 120, maxWidth: .infinity, alignment: .leading)
                            .foregroundStyle(Color.secondary)
                        Text("\(monsterSummon.summon.count) monsters")
                            .frame(minWidth: 120, maxWidth: .infinity, alignment: .leading)
                            .foregroundStyle(Color.secondary)
                    }
                }
            }
            .listStyle(.plain)
        }
        .navigationTitle("Monster Summon Database")
        .background(.background)
        .overlay {
            if database.monsterSummons.isEmpty {
                ProgressView()
            } else if !searchText.isEmpty && filteredMonsterSummons.isEmpty {
                ContentUnavailableView("No Results", systemImage: "pawprint.fill")
            }
        }
        .searchable(text: $searchText)
        .task(id: searchText) {
            filteredMonsterSummons = await monsterSummons(matching: searchText, in: database.monsterSummons)
        }
        .task {
            await database.fetchMonsterSummons()
            filteredMonsterSummons = await monsterSummons(matching: searchText, in: database.monsterSummons)
        }
    }

    private func monsterSummons(matching searchText: String, in monsterSummons: [MonsterSummonModel]) async -> [MonsterSummonModel] {
        if searchText.isEmpty {
            return monsterSummons
        }

        let filteredMonsterSummons = monsterSummons.filter { monsterSummon in
            monsterSummon.displayName.localizedStandardContains(searchText)
        }
        return filteredMonsterSummons
    }
}

#Preview("Pre-Renewal Monster Summon Database") {
    NavigationStack {
        MonsterSummonDatabaseView()
    }
    .environment(DatabaseModel(mode: .prerenewal))
}

#Preview("Renewal Monster Summon Database") {
    NavigationStack {
        MonsterSummonDatabaseView()
    }
    .environment(DatabaseModel(mode: .renewal))
}
