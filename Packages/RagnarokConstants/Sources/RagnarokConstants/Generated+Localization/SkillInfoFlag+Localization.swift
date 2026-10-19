//
//  SkillInfoFlag+Localization.swift
//  RagnarokConstants
//
//  Created by Leon Li on 2026/10/19.
//

import Foundation

extension SkillInfoFlag {
    public var localizedName: LocalizedStringResource {
        switch self {
        case .passive:
            LocalizedStringResource("Passive", table: "SkillInfoFlag", bundle: .module)
        case .attack:
            LocalizedStringResource("Attack", table: "SkillInfoFlag", bundle: .module)
        case .ground:
            LocalizedStringResource("Ground", table: "SkillInfoFlag", bundle: .module)
        case ._self:
            LocalizedStringResource("Self", table: "SkillInfoFlag", bundle: .module)
        case .support:
            LocalizedStringResource("Support", table: "SkillInfoFlag", bundle: .module)
        case .trap:
            LocalizedStringResource("Trap", table: "SkillInfoFlag", bundle: .module)
        }
    }
}
