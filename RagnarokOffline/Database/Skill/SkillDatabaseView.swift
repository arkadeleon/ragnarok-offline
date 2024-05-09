//
//  SkillDatabaseView.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/1/2.
//

import SwiftUI

struct SkillDatabaseView: View {
    @ObservedObject var skillDatabase: ObservableSkillDatabase

    var body: some View {
        ScrollView {
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 280), spacing: 20)], alignment: .leading, spacing: 20) {
                ForEach(skillDatabase.filteredSkills) { skill in
                    NavigationLink(value: skill) {
                        SkillGridCell(skill: skill)
                    }
                }
            }
            .padding(20)
        }
        .overlay {
            if skillDatabase.loadStatus == .loading {
                ProgressView()
            }
        }
        .overlay {
            if skillDatabase.loadStatus == .loaded && skillDatabase.filteredSkills.isEmpty {
                EmptyContentView("No Skills")
            }
        }
        .databaseNavigationDestinations(mode: skillDatabase.database.mode)
        .navigationTitle("Skill Database")
        #if !os(macOS)
        .navigationBarTitleDisplayMode(.inline)
        #endif
        .searchable(text: $skillDatabase.searchText)
        .onSubmit(of: .search) {
            skillDatabase.filterSkills()
        }
        .onChange(of: skillDatabase.searchText) { _ in
            skillDatabase.filterSkills()
        }
        .task {
            await skillDatabase.fetchSkills()
        }
    }
}
