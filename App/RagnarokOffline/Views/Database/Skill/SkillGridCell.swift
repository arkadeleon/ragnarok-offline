//
//  SkillGridCell.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/1/3.
//  Copyright © 2024 Leon & Vane. All rights reserved.
//

import SwiftUI

struct SkillGridCell: View {
    let database: Database
    let skill: Skill

    @State private var skillIconImage: CGImage?
    @State private var skillDisplayName: String?

    var body: some View {
        NavigationLink {
            SkillInfoView(database: database, skill: skill)
        } label: {
            HStack {
                ZStack {
                    if let skillIconImage {
                        Image(skillIconImage, scale: 1, label: Text(skill.name))
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                    } else {
                        Image(systemName: "arrow.up.heart")
                            .foregroundStyle(.tertiary)
                            .font(.system(size: 25))
                    }
                }
                .frame(width: 40, height: 40)

                VStack(alignment: .leading, spacing: 2) {
                    Text(skillDisplayName ?? skill.name)
                        .foregroundColor(.primary)
                        .lineLimit(1)

                    Text(skill.aegisName)
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .task {
            skillIconImage = await ClientResourceBundle.shared.skillIconImage(forSkill: skill)
            skillDisplayName = ClientDatabase.shared.skillDisplayName(skill.id)
        }
    }
}
