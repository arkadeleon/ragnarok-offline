//
//  SkillDetailView.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/1/3.
//

import SwiftUI

struct SkillDetailView: View {
    var skill: SkillModel

    var body: some View {
        DatabaseRecordDetailView {
            DatabaseRecordSectionView(attributes: skill.attributes) {
                Text("Info", tableName: "Database")
            }

            if let localizedDescription = skill.localizedDescription {
                DatabaseRecordSectionView(text: AttributedString(description: localizedDescription)) {
                    Text("Description", tableName: "Database")
                }
            }
        }
        .navigationTitle(skill.displayName)
    }
}
