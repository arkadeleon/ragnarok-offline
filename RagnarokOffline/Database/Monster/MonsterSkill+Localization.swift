//
//  MonsterSkill+Localization.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2026/10/19.
//

import Foundation
import RagnarokDatabase

extension MonsterSkill.State {
    var localizedName: LocalizedStringResource {
        switch self {
        case .any:
            LocalizedStringResource("Any State", table: "Database")
        case .idle:
            LocalizedStringResource("Idle", table: "Database")
        case .walk:
            LocalizedStringResource("Walking", table: "Database")
        case .dead:
            LocalizedStringResource("On Death", table: "Database")
        case .loot:
            LocalizedStringResource("Looting", table: "Database")
        case .attack:
            LocalizedStringResource("Attacking", table: "Database")
        case .angry:
            LocalizedStringResource("Angry", table: "Database")
        case .chase:
            LocalizedStringResource("Chasing", table: "Database")
        case .follow:
            LocalizedStringResource("Following", table: "Database")
        case .anyTarget:
            LocalizedStringResource("Any Target", table: "Database")
        }
    }
}
