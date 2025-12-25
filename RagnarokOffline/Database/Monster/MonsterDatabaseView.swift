//
//  MonsterDatabaseView.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/1/3.
//

import SwiftUI

struct MonsterDatabaseView: View {
    @Environment(DatabaseModel.self) private var database

    @Namespace private var filterNamespace

    @State private var filter = MonsterDatabaseFilter()
    @State private var filteredMonsters: [MonsterModel] = []
    @State private var isFilterPresented = false

    var body: some View {
        ImageGrid(filteredMonsters) { monster in
            NavigationLink(value: monster) {
                MonsterGridCell(monster: monster, reservesSecondaryTextSpace: false, secondaryText: nil)
            }
        }
        .background(.background)
        .navigationTitle("Monster Database")
        .adaptiveSearch(text: $filter.searchText)
        .toolbar {
            ToolbarItem {
                Button("Filter", systemImage: "line.3.horizontal.decrease") {
                    isFilterPresented.toggle()
                }
                .matchedTransitionSource(id: "filter", in: filterNamespace)
            }
        }
        .overlay {
            if database.monsters.isEmpty {
                ProgressView()
            } else if !filter.isEmpty && filteredMonsters.isEmpty {
                ContentUnavailableView("No Results", systemImage: "pawprint.fill")
            }
        }
        .sheet(isPresented: $isFilterPresented) {
            NavigationStack {
                MonsterDatabaseFilterView(filter: filter)
            }
            #if os(macOS)
            .navigationTransition(.automatic)
            #else
            .navigationTransition(.zoom(sourceID: "filter", in: filterNamespace))
            #endif
        }
        .task(id: filter.identifier) {
            await database.fetchMonsters()
            filteredMonsters = await monsters(matching: filter, in: database.monsters)
        }
    }

    private func monsters(matching filter: MonsterDatabaseFilter, in monsters: [MonsterModel]) async -> [MonsterModel] {
        if filter.searchText.hasPrefix("#") {
            if let monsterID = Int(filter.searchText.dropFirst()),
               let monster = monsters.first(where: { $0.id == monsterID }) {
                return [monster]
            } else {
                return []
            }
        }

        let filteredMonsters = monsters.filter(filter.isIncluded)
        return filteredMonsters
    }
}

#Preview("Pre-Renewal Monster Database") {
    NavigationStack {
        MonsterDatabaseView()
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .environment(DatabaseModel(mode: .prerenewal))
}

#Preview("Renewal Monster Database") {
    NavigationStack {
        MonsterDatabaseView()
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .environment(DatabaseModel(mode: .renewal))
}
