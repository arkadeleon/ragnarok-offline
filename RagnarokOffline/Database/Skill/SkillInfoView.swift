//
//  SkillInfoView.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/1/3.
//

import SwiftUI

struct SkillInfoView: View {
    var skill: ObservableSkill

    var body: some View {
        ScrollView {
            LazyVStack(pinnedViews: .sectionHeaders) {
                DatabaseRecordAttributesSectionView("Info", attributes: skill.attributes)

                if let skillLocalizedDescription = skill.localizedDescription {
                    DatabaseRecordSectionView("Description") {
                        Text(skillLocalizedDescription)
                    }
                }
            }
        }
        .background(.background)
        .navigationTitle(skill.displayName)
        .task {
            await skill.fetchDetail()
        }
    }
}
