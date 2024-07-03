//
//  SkillDamageFlag.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/1/11.
//

import rAthenaCommon

public enum SkillDamageFlag: CaseIterable, CodingKey, Decodable {
    case noDamage
    case splash
    case splashSplit
    case ignoreAtkCard
    case ignoreElement
    case ignoreDefense
    case ignoreFlee
    case ignoreDefCard
    case ignoreLongCard
    case critical

    public var intValue: Int {
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

    public var stringValue: String {
        switch self {
        case .noDamage: "NoDamage"
        case .splash: "Splash"
        case .splashSplit: "SplashSplit"
        case .ignoreAtkCard: "IgnoreAtkCard"
        case .ignoreElement: "IgnoreElement"
        case .ignoreDefense: "IgnoreDefense"
        case .ignoreFlee: "IgnoreFlee"
        case .ignoreDefCard: "IgnoreDefCard"
        case .ignoreLongCard: "IgnoreLongCard"
        case .critical: "Critical"
        }
    }

    public init?(stringValue: String) {
        if let skillDamageFlag = SkillDamageFlag.allCases.first(where: { $0.stringValue.caseInsensitiveCompare(stringValue) == .orderedSame }) {
            self = skillDamageFlag
        } else {
            return nil
        }
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let stringValue = try container.decode(String.self)
        if let skillDamageFlag = SkillDamageFlag(stringValue: stringValue) {
            self = skillDamageFlag
        } else {
            let context = DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Skill damage flag does not exist.")
            throw DecodingError.valueNotFound(SkillDamageFlag.self, context)
        }
    }
}
