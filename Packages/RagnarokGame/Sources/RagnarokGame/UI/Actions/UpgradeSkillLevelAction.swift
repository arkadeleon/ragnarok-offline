//
//  UpgradeSkillLevelAction.swift
//  RagnarokGame
//
//  Created by Leon Li on 2026/8/7.
//

import SwiftUI

struct UpgradeSkillLevelAction {
    var action: (Int) -> Void

    func callAsFunction(skillID: Int) {
        action(skillID)
    }
}

extension EnvironmentValues {
    @Entry var upgradeSkillLevel: UpgradeSkillLevelAction?
}

extension View {
    nonisolated func onUpgradeSkillLevel(
        perform action: @escaping (Int) -> Void
    ) -> some View {
        environment(\.upgradeSkillLevel, UpgradeSkillLevelAction(action: action))
    }
}
