//
//  SkillCastFlag.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/2/4.
//

import rAthenaCommon

public enum SkillCastFlag: Option {
    case ignoreDex
    case ignoreStatus
    case ignoreItemBonus

    public var intValue: Int {
        switch self {
        case .ignoreDex: RA_SKILL_CAST_IGNOREDEX
        case .ignoreStatus: RA_SKILL_CAST_IGNORESTATUS
        case .ignoreItemBonus: RA_SKILL_CAST_IGNOREITEMBONUS
        }
    }

    public var stringValue: String {
        switch self {
        case .ignoreDex: "IgnoreDex"
        case .ignoreStatus: "IgnoreStatus"
        case .ignoreItemBonus: "IgnoreItemBonus"
        }
    }
}
