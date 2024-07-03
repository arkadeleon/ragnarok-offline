//
//  SkillHitType.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/1/11.
//

import rAthenaCommon

public enum SkillHitType: CaseIterable, RawRepresentable, CodingKey, Decodable {
    case normal
    case single
    case multiHit

    public var rawValue: Int {
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
