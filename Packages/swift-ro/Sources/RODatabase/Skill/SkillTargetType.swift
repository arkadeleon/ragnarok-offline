//
//  SkillTargetType.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/1/11.
//

import rAthenaCommon

public enum SkillTargetType: Option {
    case passive
    case attack
    case ground
    case `self`
    case support
    case trap

    public var intValue: Int {
        switch self {
        case .passive: RA_INF_PASSIVE_SKILL
        case .attack: RA_INF_ATTACK_SKILL
        case .ground: RA_INF_GROUND_SKILL
        case .self: RA_INF_SELF_SKILL
        case .support: RA_INF_SUPPORT_SKILL
        case .trap: RA_INF_TRAP_SKILL
        }
    }

    public var stringValue: String {
        switch self {
        case .passive: "Passive"
        case .attack: "Attack"
        case .ground: "Ground"
        case .self: "Self"
        case .support: "Support"
        case .trap: "Trap"
        }
    }
}
