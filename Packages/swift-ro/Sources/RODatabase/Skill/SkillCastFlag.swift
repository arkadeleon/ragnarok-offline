//
//  SkillCastFlag.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/2/4.
//

import rAthenaCommon

public enum SkillCastFlag: CaseIterable, CodingKey, Decodable {
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

    public init?(stringValue: String) {
        if let skillCastFlag = SkillCastFlag.allCases.first(where: { $0.stringValue.caseInsensitiveCompare(stringValue) == .orderedSame }) {
            self = skillCastFlag
        } else {
            return nil
        }
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let stringValue = try container.decode(String.self)
        if let skillCastFlag = SkillCastFlag(stringValue: stringValue) {
            self = skillCastFlag
        } else {
            let context = DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Skill cast flag does not exist.")
            throw DecodingError.valueNotFound(SkillCastFlag.self, context)
        }
    }
}
