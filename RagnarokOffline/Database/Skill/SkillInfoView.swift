//
//  SkillInfoView.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/1/3.
//

import SwiftUI
import rAthenaCommon
import RODatabase
import ROResources

struct SkillInfoView: View {
    var mode: ServerMode
    var skill: Skill

    @State private var skillDescription: String?

    var body: some View {
        ScrollView {
            DatabaseRecordInfoSection("Info") {
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 280), spacing: 20)], spacing: 10) {
                    ForEach(fields, id: \.title.key) { field in
                        LabeledContent {
                            Text(field.value)
                        } label: {
                            Text(field.title)
                        }
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
        .task {
            await loadSkillInfo()
        }
    }

    private var fields: [DatabaseRecordField] {
        var fields: [DatabaseRecordField] = []

        fields.append(("ID", "#\(skill.id)"))
        fields.append(("Aegis Name", skill.aegisName))
        fields.append(("Name", skill.name))
        fields.append(("Maximum Level", skill.maxLevel.formatted()))
        fields.append(("Type", skill.type.description))
        fields.append(("Target Type", skill.targetType.description))

        return fields
    }

    private func loadSkillInfo() async {
        skillDescription = await SkillLocalization.shared.localizedDescription(for: skill.id)
    }
}
