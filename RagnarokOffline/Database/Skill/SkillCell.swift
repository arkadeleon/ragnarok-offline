//
//  SkillCell.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/1/3.
//

import RODatabase
import SwiftUI

struct SkillCell: View {
    var skill: Skill

    var body: some View {
        HStack {
            SkillIconView(skill: skill)

            VStack(alignment: .leading, spacing: 2) {
                SkillNameView(skill: skill)
                    .foregroundStyle(Color.primary)
                    .lineLimit(1)

                Text(skill.aegisName)
                    .foregroundStyle(Color.secondary)
                    .lineLimit(1)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}
