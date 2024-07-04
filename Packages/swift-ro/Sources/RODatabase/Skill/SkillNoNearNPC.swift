//
//  SkillNoNearNPC.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/2/4.
//

import rAthenaCommon

public enum SkillNoNearNPC: Option {
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
}
