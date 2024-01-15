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
    public var body: some View {
        DatabaseRecordList {
            try await Database.renewal.fetchSkills()
        } filter: { skills, searchText in
            skills.filter { skill in
                skill.name.localizedCaseInsensitiveContains(searchText)
            }
        } content: { skill in
            NavigationLink {
                SkillDetailView(skill: skill)
            } label: {
                SkillListCell(skill: skill)
            }
        }
        .navigationTitle("Skills")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    SkillList()
}
