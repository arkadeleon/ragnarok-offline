//
//  SkillCell.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/1/3.
//

import SwiftUI

struct SkillCell: View {
    var skill: SkillModel
    var secondaryText: String?

    var body: some View {
        HStack {
            SkillIconImageView(skill: skill)

            VStack(alignment: .leading, spacing: 2) {
                Text(skill.displayName)
                    .foregroundStyle(Color.primary)
                    .lineLimit(1)

                Text(secondaryText ?? skill.aegisName)
                    .foregroundStyle(Color.secondary)
                    .lineLimit(1)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}
