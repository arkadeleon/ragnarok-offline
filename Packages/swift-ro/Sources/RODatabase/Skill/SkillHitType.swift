//
//  SkillHitType.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/1/11.
//

import rAthenaCommon

public enum SkillHitType: CaseIterable, CodingKey, Decodable {
    case normal
    case single
    case multiHit

    public var intValue: Int {
        switch self {
        case .normal: 0
        case .single: RA_DMG_SINGLE
        case .multiHit: RA_DMG_MULTI_HIT
        }
    }

    public var stringValue: String {
        switch self {
        case .normal: "Normal"
        case .single: "Single"
        case .multiHit: "Multi_Hit"
        }
    }

    public init?(stringValue: String) {
        if let skillHitType = SkillHitType.allCases.first(where: { $0.stringValue.caseInsensitiveCompare(stringValue) == .orderedSame }) {
            self = skillHitType
        } else {
            return nil
        }
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let stringValue = try container.decode(String.self)
        if let skillHitType = SkillHitType(stringValue: stringValue) {
            self = skillHitType
        } else {
            let context = DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Skill hit type does not exist.")
            throw DecodingError.valueNotFound(SkillHitType.self, context)
        }
    }
}

extension SkillHitType: CustomLocalizedStringResourceConvertible {
    public var localizedStringResource: LocalizedStringResource {
        switch self {
        case .normal: "Normal"
        case .single: "Single Hit"
        case .multiHit: "Multiple Hit"
        }
    }
}
