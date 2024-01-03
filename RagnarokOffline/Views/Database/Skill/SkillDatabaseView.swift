//
//  SkillDatabaseView.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/1/2.
//  Copyright © 2024 Leon & Vane. All rights reserved.
//

import rAthenaMap
import SwiftUI

struct SkillDatabaseView: View {
    @State private var searchText = ""
    @State private var allRecords = [RASkill]()
    @State private var filteredRecords = [RASkill]()

    public var body: some View {
        List(filteredRecords) { skill in
            NavigationLink {
                SkillDetailView(skill: skill)
            } label: {
                HStack {
                    SkillListRow(skill: skill)
                }
            }
        }
        .listStyle(.plain)
        .searchable(text: $searchText)
        .navigationTitle(RASkillDatabase.shared.name)
        .navigationBarTitleDisplayMode(.inline)
        .task {
            Task {
                allRecords = RASkillDatabase.shared.allRecords() as! [RASkill]
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
            filteredRecords = allRecords.filter { record in
                record.recordTitle.localizedCaseInsensitiveContains(searchText)
            }
        }
    }
}
