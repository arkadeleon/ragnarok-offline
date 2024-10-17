//
//  SkillInfoView.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/1/3.
//

import SwiftUI
import rAthenaCommon
import RODatabase
import ROLocalizations

struct SkillInfoView: View {
    var mode: ServerMode
    var skill: Skill

    @State private var skillDescription: String?

    var body: some View {
        ScrollView {
            DatabaseRecordInfoSection("Info") {
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 280), spacing: 20)], spacing: 10) {
                    ForEach(attributes) { attribute in
                        LabeledContent {
                            Text(attribute.value)
                        } label: {
                            Text(attribute.name)
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
        .background(.background)
        .navigationTitle(skill.name)
        .task {
            loadSkillInfo()
        }
    }

    private var attributes: [DatabaseRecordAttribute] {
        var attributes: [DatabaseRecordAttribute] = []

        attributes.append(.init(name: "ID", value: "#\(skill.id)"))
        attributes.append(.init(name: "Aegis Name", value: skill.aegisName))
        attributes.append(.init(name: "Name", value: skill.name))
        attributes.append(.init(name: "Maximum Level", value: skill.maxLevel))
        attributes.append(.init(name: "Type", value: skill.type.stringValue))
        attributes.append(.init(name: "Target Type", value: skill.targetType.stringValue))

        return attributes
    }

    private func loadSkillInfo() {
        skillDescription = SkillInfoTable.shared.localizedSkillDescription(forSkillID: skill.id)
    }
}
