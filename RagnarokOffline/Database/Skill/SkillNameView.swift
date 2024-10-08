//
//  SkillNameView.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/5/30.
//

import RODatabase
import ROLocalizations
import SwiftUI

struct SkillNameView: View {
    var skill: Skill

    @State private var localizedSkillName: String?

    var body: some View {
        Text(localizedSkillName ?? skill.name)
            .task {
                localizedSkillName = SkillInfoTable.shared.localizedSkillName(forSkillID: skill.id)
            }
    }
}

//#Preview {
//    SkillNameView()
//}
