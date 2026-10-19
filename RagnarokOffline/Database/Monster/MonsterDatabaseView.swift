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

    @State private var searchText = ""
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
        .adaptiveSearch(text: $searchText)
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
            } else if (!searchText.isEmpty || !filter.isEmpty) && filteredMonsters.isEmpty {
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
                MonsterDatabaseFilterView(filter: $filter)
            }
            .adaptiveNavigationTransition(sourceID: "filter", in: filterNamespace)
        }
        .task(id: query) {
            await database.fetchMonsters()

            if !searchText.isEmpty {
                do {
                    try await Task.sleep(for: .milliseconds(200))
                } catch {
                    return
                }
            }

            let filteredMonsters = await monsters(matching: searchText, filter: filter)
            if !Task.isCancelled {
                self.filteredMonsters = filteredMonsters
            }
        }
    }

    private struct Query: Equatable {
        var searchText: String
        var filter: MonsterDatabaseFilter
    }

    private var query: Query {
        Query(searchText: searchText, filter: filter)
    }

    private func monsters(matching searchText: String, filter: MonsterDatabaseFilter) async -> [MonsterModel] {
        let monsters = database.monsters

        if searchText.isEmpty {
            return monsters.filter(filter.isIncluded)
        }

        let indices = await database.monsterSearchIndex.indices(matching: searchText)
        return indices.map({ monsters[$0] }).filter(filter.isIncluded)
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
