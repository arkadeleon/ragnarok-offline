//
//  SkillGridCell.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/1/3.
//  Copyright © 2024 Leon & Vane. All rights reserved.
//

import SwiftUI
import rAthenaDatabase

struct SkillGridCell: View {
    let database: Database
    let skill: Skill

    @State private var skillIconImage: UIImage?
    @State private var localizedSkillName: String?

    var body: some View {
        HStack {
            Image(uiImage: skillIconImage ?? UIImage())
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: 40, height: 40)
                .clipped()

            VStack(alignment: .leading, spacing: 2) {
                Text(skill.name)
                    .foregroundColor(.primary)
                    .lineLimit(1)

                Text(localizedSkillName ?? skill.name)
                    .foregroundColor(.secondary)
                    .lineLimit(1)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .task {
            skillIconImage = await ClientResourceBundle.shared.skillIconImage(forSkill: skill)
            localizedSkillName = ClientDatabase.shared.skillName(skill.id)
        }
    }
}
