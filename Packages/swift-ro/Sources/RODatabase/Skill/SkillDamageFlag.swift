//
//  SkillDamageFlag.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/1/11.
//

import rAthenaCommon

public enum SkillDamageFlag: String, CaseIterable, CodingKey, Decodable {
    case noDamage = "NoDamage"
    case splash = "Splash"
    case splashSplit = "SplashSplit"
    case ignoreAtkCard = "IgnoreAtkCard"
    case ignoreElement = "IgnoreElement"
    case ignoreDefense = "IgnoreDefense"
    case ignoreFlee = "IgnoreFlee"
    case ignoreDefCard = "IgnoreDefCard"
    case ignoreLongCard = "IgnoreLongCard"
    case critical = "Critical"
}

extension SkillDamageFlag: Identifiable {
    public var id: Int {
        switch self {
        case .noDamage: RA_NK_NODAMAGE
        case .splash: RA_NK_SPLASH
        case .splashSplit: RA_NK_SPLASHSPLIT
        case .ignoreAtkCard: RA_NK_IGNOREATKCARD
        case .ignoreElement: RA_NK_IGNOREELEMENT
        case .ignoreDefense: RA_NK_IGNOREDEFENSE
        case .ignoreFlee: RA_NK_IGNOREFLEE
        case .ignoreDefCard: RA_NK_IGNOREDEFCARD
        case .ignoreLongCard: RA_NK_IGNORELONGCARD
        case .critical: RA_NK_CRITICAL
        }
    }
}

extension SkillDamageFlag: CustomStringConvertible {
    public var description: String {
        stringValue
    }
}
