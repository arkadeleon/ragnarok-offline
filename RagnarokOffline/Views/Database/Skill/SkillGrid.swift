//
//  SkillGrid.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/1/2.
//  Copyright © 2024 Leon & Vane. All rights reserved.
//

import SwiftUI
import rAthenaDatabase

struct SkillGrid: View {
    let database: Database

    var body: some View {
        DatabaseRecordGrid(
            columns: [GridItem(.adaptive(minimum: 240), spacing: 16)],
            alignment: .leading,
            spacing: 32,
            insets: EdgeInsets(top: 32, leading: 16, bottom: 32, trailing: 16),
            partitions: database.skills(),
            filter: filter) { skill in
                NavigationLink {
                    SkillInfoView(database: database, skill: skill)
                } label: {
                    SkillGridCell(database: database, skill: skill)
                }
            }
            .navigationTitle("Skills")
            .navigationBarTitleDisplayMode(.inline)
    }

    private func filter(skills: [Skill], searchText: String) -> [Skill] {
        skills.filter { skill in
            skill.name.localizedCaseInsensitiveContains(searchText)
        }
    }
}

#Preview {
    SkillGrid(database: .renewal)
}
