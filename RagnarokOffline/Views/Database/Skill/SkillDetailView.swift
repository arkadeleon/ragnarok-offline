//
//  SkillDetailView.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/1/3.
//  Copyright © 2024 Leon & Vane. All rights reserved.
//

import rAthenaMap
import SwiftUI

struct SkillDetailView: View {
    let skill: RASkill

    @State private var skillDescription: String?

    var body: some View {
        List {
            Section("Info") {
                DatabaseRecordField(name: "ID", value: "#\(skill.skillID)")
                DatabaseRecordField(name: "Aegis Name", value: skill.skillName)
                DatabaseRecordField(name: "Name", value: skill.skillDescription)
                DatabaseRecordField(name: "Maximum Level", value: "\(skill.maxLevel)")
                DatabaseRecordField(name: "Type", value: "\(skill.type)")
                DatabaseRecordField(name: "Target Type", value: "\(skill.targetType)")
            }

            if let skillDescription {
                Section("Description") {
                    Text(skillDescription)
                }
            }
        }
        .listStyle(.plain)
        .navigationTitle(skill.skillDescription)
        .navigationBarTitleDisplayMode(.inline)
        .task {
            skillDescription = ClientDatabase.shared.skillDescription(skill.skillID)
        }
    }
}
