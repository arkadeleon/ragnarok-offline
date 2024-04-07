//
//  SkillDatabaseView.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/1/2.
//  Copyright © 2024 Leon & Vane. All rights reserved.
//

import SwiftUI

struct SkillDatabaseView: View {
    @ObservedObject var skillDatabase: ObservableSkillDatabase

    var body: some View {
        AsyncContentView(status: skillDatabase.status) { skills in
            ScrollView {
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 280), spacing: 20)], alignment: .leading, spacing: 20) {
                    ForEach(skillDatabase.filteredSkills) { skill in
                        SkillGridCell(database: skillDatabase.database, skill: skill)
                    }
                }
                .padding(20)
            }
            .overlay {
                if skillDatabase.filteredSkills.isEmpty {
                    EmptyContentView("No Skills")
                }
            }
        }
        .navigationTitle("Skill Database")
        .navigationBarTitleDisplayMode(.inline)
        .searchable(text: $skillDatabase.searchText, placement: .navigationBarDrawer(displayMode: .always))
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
