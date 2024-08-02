//
//  SkillIconView.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/5/30.
//

import ROClient
import RODatabase
import SwiftUI

struct SkillIconView: View {
    var skill: Skill

    @State private var skillIcon: CGImage?

    var body: some View {
        ZStack {
            if let skillIcon {
                Image(skillIcon, scale: 1, label: Text(skill.name))
                    .resizable()
                    .aspectRatio(contentMode: .fit)
            } else {
                Image(systemName: "arrow.up.heart")
                    .font(.system(size: 25, weight: .thin))
                    .foregroundStyle(Color.secondary)
            }
        }
        .frame(width: 40, height: 40)
        .task {
            skillIcon = await ClientResourceBundle.shared.skillIconImage(forSkill: skill)
        }
    }
}

//#Preview {
//    SkillIconView()
//}
