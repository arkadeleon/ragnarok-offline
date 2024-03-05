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

    @State private var localizedSkillName: String?

    var body: some View {
        HStack {
            DatabaseRecordImage {
                await ClientResourceManager.shared.skillIconImage(skill.aegisName, size: CGSize(width: 40, height: 40))
            }
            .frame(width: 40, height: 40)

            VStack(alignment: .leading, spacing: 2) {
                Text(skill.name)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .foregroundColor(.primary)
                    .lineLimit(1)

                Text(localizedSkillName ?? skill.name)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .foregroundColor(.secondary)
                    .lineLimit(1)
            }
        }
        .task {
            localizedSkillName = ClientDatabase.shared.skillName(skill.id)
        }
    }
}
