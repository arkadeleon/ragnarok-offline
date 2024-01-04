//
//  SkillListCell.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/1/3.
//  Copyright © 2024 Leon & Vane. All rights reserved.
//

import rAthenaMap
import SwiftUI

struct SkillListCell: View {
    let skill: RASkill

    @State private var localizedSkillName: String?

    var body: some View {
        HStack {
            DatabaseRecordImage {
                await ClientResourceManager.shared.skillIconImage(skill.skillName)
            }
            .frame(width: 24, height: 24)

            Text(skill.skillDescription)

            if let localizedSkillName {
                Text(localizedSkillName)
                    .foregroundColor(.secondary)
            }
        }
        .task {
            localizedSkillName = ClientScriptManager.shared.skillName(skill.skillID)
        }
    }
}

#Preview {
    SkillListCell(skill: RASkill())
}
