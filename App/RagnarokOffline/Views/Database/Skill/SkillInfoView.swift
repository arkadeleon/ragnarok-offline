//
//  SkillInfoView.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/1/3.
//  Copyright © 2024 Leon & Vane. All rights reserved.
//

import SwiftUI

struct SkillInfoView: View {
    let database: Database
    let skill: Skill

    @State private var skillDescription: String?

    var body: some View {
        ScrollView {
            DatabaseRecordInfoSection("Info") {
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 280), spacing: 20)], spacing: 10) {
                    ForEach(fields, id: \.title) { field in
                        LabeledContent(field.title, value: field.value)
                    }
                }
            }

            if let skillDescription {
                DatabaseRecordInfoSection("Description") {
                    Text(skillDescription)
                }
            }
        }
        .navigationTitle(skill.name)
        .navigationBarTitleDisplayMode(.inline)
        .task {
            await loadSkillInfo()
        }
    }

    private var fields: [DatabaseRecordField] {
        var fields: [DatabaseRecordField] = []

        fields.append(("ID", "#\(skill.id)"))
        fields.append(("Aegis Name", skill.aegisName))
        fields.append(("Name", skill.name))
        fields.append(("Maximum Level", "\(skill.maxLevel)"))
        fields.append(("Type", skill.type.description))
        fields.append(("Target Type", skill.targetType.description))

        return fields
    }

    private func loadSkillInfo() async {
        skillDescription = ClientDatabase.shared.skillDescription(skill.id)
    }
}
