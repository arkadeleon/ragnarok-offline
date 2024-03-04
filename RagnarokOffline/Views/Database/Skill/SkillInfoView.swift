//
//  SkillInfoView.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/1/3.
//  Copyright © 2024 Leon & Vane. All rights reserved.
//

import SwiftUI
import rAthenaDatabase

struct SkillInfoView: View {
    let database: Database
    let skill: Skill

    @State private var skillDescription: String?

    var body: some View {
        List {
            Section("Info") {
                LabeledContent("ID", value: "#\(skill.id)")
                LabeledContent("Aegis Name", value: skill.aegisName)
                LabeledContent("Name", value: skill.name)
                LabeledContent("Maximum Level", value: "\(skill.maxLevel)")
                LabeledContent("Type", value: skill.type.description)
                LabeledContent("Target Type", value: skill.targetType.description)
            }

            if let skillDescription {
                Section("Description") {
                    Text(skillDescription)
                }
            }
        }
        .listStyle(.plain)
        .navigationTitle(skill.name)
        .navigationBarTitleDisplayMode(.inline)
        .task {
            skillDescription = ClientDatabase.shared.skillDescription(skill.id)
        }
    }
}
