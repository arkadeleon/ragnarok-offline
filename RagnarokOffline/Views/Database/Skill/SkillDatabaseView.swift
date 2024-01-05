//
//  SkillDatabaseView.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/1/2.
//  Copyright © 2024 Leon & Vane. All rights reserved.
//

import SwiftUI
import rAthenaMap

struct SkillDatabaseView: View {
    @State private var searchText = ""
    @State private var allRecords = [RASkill]()
    @State private var filteredRecords = [RASkill]()

    public var body: some View {
        List(filteredRecords, id: \.skillID) { skill in
            NavigationLink {
                SkillDetailView(skill: skill)
            } label: {
                SkillListCell(skill: skill)
            }
        }
        .listStyle(.plain)
        .searchable(text: $searchText)
        .navigationTitle(RASkillDatabase.shared.name)
        .navigationBarTitleDisplayMode(.inline)
        .task {
            Task {
                allRecords = RASkillDatabase.shared.allRecords()
                filterRecords()
            }
        }
        .onSubmit(of: .search) {
            filterRecords()
        }
        .onChange(of: searchText) { _ in
            filterRecords()
        }
    }

    private func filterRecords() {
        if searchText.isEmpty {
            filteredRecords = allRecords
        } else {
            filteredRecords = allRecords.filter { skill in
                skill.skillName.localizedCaseInsensitiveContains(searchText)
            }
        }
    }
}

#Preview {
    SkillDatabaseView()
}
