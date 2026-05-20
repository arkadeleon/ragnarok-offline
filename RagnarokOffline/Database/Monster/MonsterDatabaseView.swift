//
//  MonsterDatabaseView.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/1/3.
//

import RagnarokResources
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
                ImageGridCell(title: monster.displayName) {
                    MonsterImageView(monster: monster)
                }
            }
        }
        .background(.background)
        .navigationTitle(Text("Monster Database", tableName: "Database"))
        .adaptiveSearch(text: $filter.searchText)
        .toolbar {
            ToolbarItem {
                Button {
                    isFilterPresented.toggle()
                } label: {
                    Label {
                        Text("Filter", tableName: "Database")
                    } icon: {
                        Image(systemName: "line.3.horizontal.decrease")
                    }
                }
                .matchedTransitionSource(id: "filter", in: filterNamespace)
            }
        }
        .overlay {
            if database.monsters.isEmpty {
                ProgressView()
            } else if !filter.isEmpty && filteredMonsters.isEmpty {
                ContentUnavailableView {
                    Label {
                        Text("No Results", tableName: "Database")
                    } icon: {
                        Image(systemName: "pawprint.fill")
                    }
                }
            }
        }
        .sheet(isPresented: $isFilterPresented) {
            NavigationStack {
                MonsterDatabaseFilterView(filter: filter)
            }
            .adaptiveNavigationTransition(sourceID: "filter", in: filterNamespace)
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
    .environment(DatabaseModel(mode: .prerenewal, resourceManager: .previewing))
}

#Preview("Renewal Monster Database") {
    NavigationStack {
        MonsterDatabaseView()
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .environment(DatabaseModel(mode: .renewal, resourceManager: .previewing))
}
