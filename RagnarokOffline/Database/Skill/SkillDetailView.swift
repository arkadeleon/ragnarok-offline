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
            DatabaseRecordSectionView("Info", attributes: skill.attributes)

            if let localizedDescription = skill.localizedDescription {
                DatabaseRecordSectionView("Description", text: localizedDescription)
            }
        }
        .navigationTitle(skill.displayName)
        .task {
            await skill.fetchDetail()
        }
    }
}
