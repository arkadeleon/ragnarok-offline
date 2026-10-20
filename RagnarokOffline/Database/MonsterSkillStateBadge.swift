//
//  MonsterSkillStateBadge.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2026/10/20.
//

import RagnarokDatabase
import SwiftUI

struct MonsterSkillStateBadge: View {
    var state: MonsterSkill.State

    var body: some View {
        Badge(text: String(localized: state.localizedName), color: .gray)
    }
}
