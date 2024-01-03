//
//  SkillListRow.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/1/3.
//  Copyright © 2024 Leon & Vane. All rights reserved.
//

import rAthenaMap
import SwiftUI

struct SkillListRow: View {
    let skill: RASkill

    @State private var localizedSkillName: String?

    var body: some View {
        HStack {
            DatabaseRecordIcon {
                await ClientResourceManager.shared.skillIconImage(skill.skillName)
            }

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
    SkillListRow(skill: RASkill())
}
