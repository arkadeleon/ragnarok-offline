//
//  SkillListCell.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/1/3.
//  Copyright © 2024 Leon & Vane. All rights reserved.
//

import SwiftUI
import rAthenaDatabase

struct SkillListCell: View {
    let database: Database
    let skill: Skill

    @State private var localizedSkillName: String?

    var body: some View {
        HStack {
            DatabaseRecordImage {
                await ClientResourceManager.shared.skillIconImage(skill.aegisName)
            }
            .frame(width: 24, height: 24)

            Text(skill.name)

            if let localizedSkillName {
                Text(localizedSkillName)
                    .foregroundColor(.secondary)
            }
        }
        .task {
            localizedSkillName = ClientDatabase.shared.skillName(skill.id)
        }
    }
}
