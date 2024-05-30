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
            SkillNameView(skill: skill)
        }
    }
}
