//
//  SkillTreeDetailView.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2023/3/30.
//  Copyright © 2023 Leon & Vane. All rights reserved.
//

import SwiftUI
import rAthenaCommon

struct SkillTreeDetailView: View {
    @EnvironmentObject var database: Database

    let skillTree: RASkillTree

    private var inherit: [RASkillTree] {
        Array(skillTree.inherit)
            .sorted()
            .compactMap { job in
                database.skillTree(for: job.name)
            }
    }

    private var tree: [RASkill] {
        skillTree.tree?
            .compactMap { skill in
                database.skill(for: skill.name)
            } ?? []
    }

    var body: some View {
        List {
            if !inherit.isEmpty {
                Section("Inherit") {
                    ForEach(inherit) { skillTree in
                        NavigationLink {
                            SkillTreeDetailView(skillTree: skillTree)
                        } label: {
                            Text(skillTree.job.englishName)
                        }
                    }
                }
            }

            if !tree.isEmpty {
                Section("Tree") {
                    ForEach(tree) { skill in
                        NavigationLink {
                            SkillDetailView(skill: skill)
                        } label: {
                            Text(skill.skillDescription)
                        }
                    }
                }
            }
        }
        .navigationTitle(skillTree.job.englishName)
    }
}
