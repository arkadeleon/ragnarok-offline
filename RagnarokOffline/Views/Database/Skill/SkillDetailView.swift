//
//  SkillDetailView.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/1/3.
//  Copyright © 2024 Leon & Vane. All rights reserved.
//

import SwiftUI
import rAthenaDatabase

struct SkillDetailView: View {
    let skill: Skill

    @State private var skillDescription: String?

    var body: some View {
        List {
            Section("Info") {
                DatabaseRecordField(name: "ID", value: "#\(skill.id)")
                DatabaseRecordField(name: "Aegis Name", value: skill.aegisName)
                DatabaseRecordField(name: "Name", value: skill.name)
                DatabaseRecordField(name: "Maximum Level", value: "\(skill.maxLevel)")
                DatabaseRecordField(name: "Type", value: skill.type.description)
                DatabaseRecordField(name: "Target Type", value: skill.targetType.description)
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
            skillDescription = ClientScriptManager.shared.skillDescription(skill.id)
        }
    }
}
