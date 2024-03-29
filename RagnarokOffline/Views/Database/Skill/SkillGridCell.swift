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

    @State private var skillIconImage: CGImage?
    @State private var localizedSkillName: String?

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
                    }
                }
                .frame(width: 40, height: 40)

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
        }
        .task {
            skillIconImage = await ClientResourceBundle.shared.skillIconImage(forSkill: skill)
            localizedSkillName = ClientDatabase.shared.skillName(skill.id)
        }
    }
}
