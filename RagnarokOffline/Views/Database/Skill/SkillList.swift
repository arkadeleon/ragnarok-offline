//
//  SkillList.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/1/2.
//  Copyright © 2024 Leon & Vane. All rights reserved.
//

import SwiftUI
import rAthenaDatabase

struct SkillList: View {
    let database: Database

    var body: some View {
        DatabaseRecordList(partitions: database.skills()) { skills, searchText in
            skills.filter { skill in
                skill.name.localizedCaseInsensitiveContains(searchText)
            }
        } content: { skill in
            NavigationLink {
                SkillDetailView(database: database, skill: skill)
            } label: {
                SkillListCell(database: database, skill: skill)
            }
        }
        .navigationTitle("Skills")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    SkillList(database: .renewal)
}
