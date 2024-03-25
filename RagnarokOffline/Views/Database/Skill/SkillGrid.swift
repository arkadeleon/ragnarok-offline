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
            columns: [GridItem(.adaptive(minimum: 280), spacing: 20)],
            alignment: .leading,
            spacing: 20,
            insets: EdgeInsets(top: 20, leading: 20, bottom: 20, trailing: 20),
            partitions: partitions,
            filter: filter) { skill in
                SkillGridCell(database: database, skill: skill)
            }
            .navigationTitle("Skills")
            .navigationBarTitleDisplayMode(.inline)
    }

    private func partitions() async -> AsyncDatabaseRecordPartitions<Skill> {
        await database.skills()
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
