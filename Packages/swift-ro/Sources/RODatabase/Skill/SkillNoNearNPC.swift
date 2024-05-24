//
//  SkillNoNearNPC.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/2/4.
//

import rAthenaCommon

public enum SkillNoNearNPC: String, CaseIterable, CodingKey, Decodable {
    case warpPortal = "WarpPortal"
    case shop = "Shop"
    case npc = "Npc"
    case tomb = "Tomb"
}

extension SkillNoNearNPC: Identifiable {
    public var id: Int {
        switch self {
        case .warpPortal: RA_SKILL_NONEAR_WARPPORTAL
        case .shop: RA_SKILL_NONEAR_SHOP
        case .npc: RA_SKILL_NONEAR_NPC
        case .tomb: RA_SKILL_NONEAR_TOMB
        }
    }
}

extension SkillNoNearNPC: CustomStringConvertible {
    public var description: String {
        stringValue
    }
}
