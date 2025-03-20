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
                DatabaseRecordSectionView("Info", attributes: skill.attributes)

                if let localizedDescription = skill.localizedDescription {
                    DatabaseRecordSectionView("Description", text: localizedDescription)
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
