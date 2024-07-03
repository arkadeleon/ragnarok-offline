//
//  SkillRequirement.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/2/4.
//

import rAthenaCommon

public enum SkillRequirement: CaseIterable, RawRepresentable, CodingKey, Decodable {
    case hpCost
    case spCost
    case hpRateCost
    case spRateCost
    case maxHpTrigger
    case zenyCost
    case weapon
    case ammo
    case state
    case status
    case spiritSphereCost
    case itemCost
    case equipment
    case apCost
    case apRateCost

    public var rawValue: Int {
        switch self {
        case .hpCost: RA_SKILL_REQ_HPCOST
        case .spCost: RA_SKILL_REQ_SPCOST
        case .hpRateCost: RA_SKILL_REQ_HPRATECOST
        case .spRateCost: RA_SKILL_REQ_SPRATECOST
        case .maxHpTrigger: RA_SKILL_REQ_MAXHPTRIGGER
        case .zenyCost: RA_SKILL_REQ_ZENYCOST
        case .weapon: RA_SKILL_REQ_WEAPON
        case .ammo: RA_SKILL_REQ_AMMO
        case .state: RA_SKILL_REQ_STATE
        case .status: RA_SKILL_REQ_STATUS
        case .spiritSphereCost: RA_SKILL_REQ_SPIRITSPHERECOST
        case .itemCost: RA_SKILL_REQ_ITEMCOST
        case .equipment: RA_SKILL_REQ_EQUIPMENT
        case .apCost: RA_SKILL_REQ_APCOST
        case .apRateCost: RA_SKILL_REQ_APRATECOST
        }
    }

    public var stringValue: String {
        switch self {
        case .hpCost: "HpCost"
        case .spCost: "SpCost"
        case .hpRateCost: "HpRateCost"
        case .spRateCost: "SpRateCost"
        case .maxHpTrigger: "MaxHpTrigger"
        case .zenyCost: "ZenyCost"
        case .weapon: "Weapon"
        case .ammo: "Ammo"
        case .state: "State"
        case .status: "Status"
        case .spiritSphereCost: "SpiritSphereCost"
        case .itemCost: "ItemCost"
        case .equipment: "Equipment"
        case .apCost: "ApCost"
        case .apRateCost: "ApRateCost"
        }
    }
}
