//
//  SkillCell.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/1/3.
//

import SwiftUI

struct SkillCell<SecondaryLabel>: View where SecondaryLabel: View {
    var skill: SkillModel
    var secondaryLabel: SecondaryLabel

    var body: some View {
        HStack {
            SkillIconImageView(skill: skill)

            VStack(alignment: .leading, spacing: 2) {
                Text(skill.displayName)
                    .foregroundStyle(Color.primary)
                    .lineLimit(1)

                secondaryLabel
                    .foregroundStyle(Color.secondary)
                    .lineLimit(1)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    init(skill: SkillModel, secondaryText: String? = nil) where SecondaryLabel == Text {
        self.skill = skill
        self.secondaryLabel = Text(secondaryText ?? skill.aegisName)
    }

    init(skill: SkillModel, badges: [DatabaseBadge]) where SecondaryLabel == DatabaseBadgeStackView {
        self.skill = skill
        self.secondaryLabel = DatabaseBadgeStackView(badges: badges)
    }
}
