//
//  SkillType.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/1/11.
//

import rAthenaCommon

public enum SkillType: CaseIterable, CodingKey, Decodable {
    case none
    case weapon
    case magic
    case misc

    public var intValue: Int {
        switch self {
        case .none: RA_BF_NONE
        case .weapon: RA_BF_WEAPON
        case .magic: RA_BF_MAGIC
        case .misc: RA_BF_MISC
        }
    }

    public var stringValue: String {
        switch self {
        case .none: "None"
        case .weapon: "Weapon"
        case .magic: "Magic"
        case .misc: "Misc"
        }
    }
}
