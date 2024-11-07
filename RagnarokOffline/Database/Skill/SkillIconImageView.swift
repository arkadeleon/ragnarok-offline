//
//  SkillIconImageView.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/5/30.
//

import SwiftUI

struct SkillIconImageView: View {
    var skill: ObservableSkill

    var body: some View {
        ZStack {
            if let skillIconImage = skill.iconImage {
                Image(skillIconImage, scale: 1, label: Text(skill.displayName))
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
            await skill.fetchIconImage()
        }
    }
}
