//
//  SkillLevelBadge.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2026/10/20.
//

import SwiftUI

struct SkillLevelBadge: View {
    var level: Int

    var body: some View {
        Badge(text: "Lv. \(level)", color: .indigo)
    }
}
