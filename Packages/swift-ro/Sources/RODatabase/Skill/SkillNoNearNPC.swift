//
//  SkillNoNearNPC.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/2/4.
//

import rAthenaCommon

public enum SkillNoNearNPC: CaseIterable, CodingKey, Decodable {
    case warpPortal
    case shop
    case npc
    case tomb

    public var intValue: Int {
        switch self {
        case .warpPortal: RA_SKILL_NONEAR_WARPPORTAL
        case .shop: RA_SKILL_NONEAR_SHOP
        case .npc: RA_SKILL_NONEAR_NPC
        case .tomb: RA_SKILL_NONEAR_TOMB
        }
    }

    public var stringValue: String {
        switch self {
        case .warpPortal: "WarpPortal"
        case .shop: "Shop"
        case .npc: "Npc"
        case .tomb: "Tomb"
        }
    }

    public init?(stringValue: String) {
        if let skillNoNearNPC = SkillNoNearNPC.allCases.first(where: { $0.stringValue.caseInsensitiveCompare(stringValue) == .orderedSame }) {
            self = skillNoNearNPC
        } else {
            return nil
        }
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let stringValue = try container.decode(String.self)
        if let skillNoNearNPC = SkillNoNearNPC(stringValue: stringValue) {
            self = skillNoNearNPC
        } else {
            let context = DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Skill no near NPC does not exist.")
            throw DecodingError.valueNotFound(SkillNoNearNPC.self, context)
        }
    }
}
