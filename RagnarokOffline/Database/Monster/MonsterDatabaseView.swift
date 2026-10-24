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
                // The button looks selected while the filter is active, and a click opens the filter.
                let isFilterOn = Binding(get: { !filter.isEmpty }, set: { _ in isFilterPresented.toggle() })
                Toggle(isOn: isFilterOn) {
                    Label {
                        Text("Filter", tableName: "Database")
                    } icon: {
                        Image(systemName: "line.3.horizontal.decrease")
                    }
                }
                .toggleStyle(.button)
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
                } description: {
                    Text("Try adjusting your search or filters", tableName: "Database")
                } actions: {
                    if !filter.isEmpty {
                        Button {
                            filter.reset()
                        } label: {
                            Label {
                                Text("Reset Filters", tableName: "Database")
                            } icon: {
                                Image(systemName: "arrow.counterclockwise")
                            }
                            .font(.title3)
                            .fontWeight(.medium)
                            .padding(.horizontal)
                        }
                        .adaptiveProminentButtonStyle()
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
        if filter.isPetOnly {
            await database.fetchPets()
        }

        let monsters = database.monsters
        let pets = database.petsByMonsterAegisName

        if searchText.isEmpty {
            return monsters.filter({ filter.isIncluded($0, isPet: pets[$0.aegisName] != nil) })
        }

        let indices = await database.monsterSearchIndex.indices(matching: searchText)
        return indices.map({ monsters[$0] }).filter({ filter.isIncluded($0, isPet: pets[$0.aegisName] != nil) })
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
