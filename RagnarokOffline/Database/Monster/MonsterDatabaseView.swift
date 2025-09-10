//
//  MonsterDatabaseView.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/1/3.
//

import SwiftUI

struct MonsterDatabaseView: View {
    @Environment(DatabaseModel.self) private var database

    @State private var searchText = ""
    @State private var filteredMonsters: [MonsterModel] = []

    var body: some View {
        ImageGrid(filteredMonsters) { monster in
            NavigationLink(value: monster) {
                MonsterGridCell(monster: monster, secondaryText: nil)
            }
        }
        .navigationTitle("Monster Database")
        .background(.background)
        .overlay {
            if database.monsters.isEmpty {
                ProgressView()
            } else if !searchText.isEmpty && filteredMonsters.isEmpty {
                ContentUnavailableView("No Results", systemImage: "pawprint.fill")
            }
        }
        .searchable(text: $searchText)
        .task(id: searchText) {
            filteredMonsters = await monsters(matching: searchText, in: database.monsters)
        }
        .task {
            await database.fetchMonsters()
            filteredMonsters = await monsters(matching: searchText, in: database.monsters)
        }
    }

    private func monsters(matching searchText: String, in monsters: [MonsterModel]) async -> [MonsterModel] {
        if searchText.isEmpty {
            return monsters
        }

        if searchText.hasPrefix("#") {
            if let monsterID = Int(searchText.dropFirst()),
               let monster = monsters.first(where: { $0.id == monsterID }) {
                return [monster]
            } else {
                return []
            }
        }

        let filteredMonsters = monsters.filter { monster in
            monster.displayName.localizedStandardContains(searchText)
        }
        return filteredMonsters
    }
}

#Preview("Pre-Renewal Monster Database") {
    NavigationStack {
        MonsterDatabaseView()
    }
    .environment(DatabaseModel(mode: .prerenewal))
}

#Preview("Renewal Monster Database") {
    NavigationStack {
        MonsterDatabaseView()
    }
    .environment(DatabaseModel(mode: .renewal))
}
