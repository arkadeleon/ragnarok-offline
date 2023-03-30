//
//  SkillTreeListView.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2023/3/30.
//  Copyright © 2023 Leon & Vane. All rights reserved.
//

import SwiftUI

struct SkillTreeListView: View {
    @EnvironmentObject var database: Database

    var body: some View {
        List(database.skillTrees, id: \.job.name) { skillTree in
            NavigationLink {
                SkillTreeDetailView(skillTree: skillTree)
            } label: {
                Text(skillTree.job.englishName)
            }
        }
        .navigationTitle("Skill Database")
        .navigationBarTitleDisplayMode(.inline)
        .task {
            await database.fetchSkillTrees()
        }
    }
}
