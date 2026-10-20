//
//  SkillDatabaseView.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/1/2.
//

import RagnarokResources
import SwiftUI

struct SkillDatabaseView: View {
    @Environment(DatabaseModel.self) private var database

    @Namespace private var filterNamespace

    @State private var searchText = ""
    @State private var filter = SkillDatabaseFilter()
    @State private var filteredSkills: [SkillModel] = []
    @State private var isFilterPresented = false

    var body: some View {
        SizeClassAdaptiveView {
            List(filteredSkills) { skill in
                NavigationLink(value: skill) {
                    SkillCell(skill: skill)
                }
            }
            .listStyle(.plain)
        } regular: {
            List(filteredSkills) { skill in
                NavigationLink(value: skill) {
                    HStack {
                        SkillIconImageView(skill: skill)
                            .frame(width: 40)
                        Text(skill.displayName)
                            .frame(minWidth: 160, maxWidth: .infinity, alignment: .leading)
                        Text(skill.maxLevel.formatted())
                            .frame(width: 80, alignment: .leading)
                            .foregroundStyle(Color.secondary)
                        Text(skill.spCost)
                            .frame(minWidth: 160, maxWidth: .infinity, alignment: .leading)
                            .foregroundStyle(Color.secondary)
                    }
                }
            }
            .listStyle(.plain)
        }
        .background(.background)
        .navigationTitle(Text("Skill Database", tableName: "Database"))
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
            if database.skills.isEmpty {
                ProgressView()
            } else if (!searchText.isEmpty || !filter.isEmpty) && filteredSkills.isEmpty {
                ContentUnavailableView {
                    Label {
                        Text("No Results", tableName: "Database")
                    } icon: {
                        Image(systemName: "arrow.up.heart.fill")
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
                SkillDatabaseFilterView(filter: $filter)
            }
            .adaptiveNavigationTransition(sourceID: "filter", in: filterNamespace)
        }
        .task(id: query) {
            await database.fetchSkills()

            if !searchText.isEmpty {
                do {
                    try await Task.sleep(for: .milliseconds(200))
                } catch {
                    return
                }
            }

            let filteredSkills = await skills(matching: searchText, filter: filter)
            if !Task.isCancelled {
                self.filteredSkills = filteredSkills
            }
        }
    }

    private struct Query: Equatable {
        var searchText: String
        var filter: SkillDatabaseFilter
    }

    private var query: Query {
        Query(searchText: searchText, filter: filter)
    }

    private func skills(matching searchText: String, filter: SkillDatabaseFilter) async -> [SkillModel] {
        let skills = database.skills

        if searchText.isEmpty {
            return skills.filter(filter.isIncluded)
        }

        let indices = await database.skillSearchIndex.indices(matching: searchText)
        return indices.map({ skills[$0] }).filter(filter.isIncluded)
    }
}

#Preview("Pre-Renewal Skill Database") {
    NavigationStack {
        SkillDatabaseView()
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .environment(DatabaseModel(mode: .prerenewal, resourceManager: .previewing))
}

#Preview("Renewal Skill Database") {
    NavigationStack {
        SkillDatabaseView()
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .environment(DatabaseModel(mode: .renewal, resourceManager: .previewing))
}
