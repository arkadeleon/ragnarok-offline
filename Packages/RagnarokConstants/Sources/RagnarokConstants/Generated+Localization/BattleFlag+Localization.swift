//
//  BattleFlag+Localization.swift
//  RagnarokConstants
//
//  Created by Leon Li on 2026/10/19.
//

import Foundation

extension BattleFlag {
    public var localizedName: LocalizedStringResource {
        switch self {
        case .none:
            LocalizedStringResource("None", table: "BattleFlag", bundle: .module)
        case .weapon:
            LocalizedStringResource("Weapon", table: "BattleFlag", bundle: .module)
        case .magic:
            LocalizedStringResource("Magic", table: "BattleFlag", bundle: .module)
        case .misc:
            LocalizedStringResource("Misc", table: "BattleFlag", bundle: .module)
        case .short:
            LocalizedStringResource("Short Range", table: "BattleFlag", bundle: .module)
        case .long:
            LocalizedStringResource("Long Range", table: "BattleFlag", bundle: .module)
        case .skill:
            LocalizedStringResource("Skill", table: "BattleFlag", bundle: .module)
        case .normal:
            LocalizedStringResource("Normal Attack", table: "BattleFlag", bundle: .module)
        }
    }
}
