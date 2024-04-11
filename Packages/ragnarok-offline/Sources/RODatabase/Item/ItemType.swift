//
//  ItemType.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/1/10.
//

import rAthenaCommon

public enum ItemType: String, CaseIterable, CodingKey, Decodable {

    /// Healing item.
    case healing = "Healing"

    /// Usable item.
    case usable = "Usable"

    /// Etc item.
    case etc = "Etc"

    /// Armor/Garment/Boots/Headgear/Accessory item.
    case armor = "Armor"

    /// Weapon item.
    case weapon = "Weapon"

    /// Card item.
    case card = "Card"

    /// Pet egg item.
    case petEgg = "PetEgg"

    /// Pet equipment item.
    case petArmor = "PetArmor"

    /// Ammo (Arrows/Bullets/etc) item.
    case ammo = "Ammo"

    /// Usable with delayed consumption (intended for 'itemskill').
    /// Items using the 'itemskill' script command are consumed after selecting a target. Any other command will NOT consume the item.
    case delayConsume = "DelayConsume"

    /// Shadow Equipment item.
    case shadowGear = "ShadowGear"

    /// Another delayed consume that requires user confirmation before using the item.
    case cash = "Cash"

    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let rawValue = try container.decode(String.self)
        self = ItemType.allCases.first(where: { $0.rawValue.caseInsensitiveCompare(rawValue) == .orderedSame }) ?? .etc
    }
}

extension ItemType: Identifiable {
    public var id: Int {
        switch self {
        case .healing: RA_IT_HEALING
        case .usable: RA_IT_USABLE
        case .etc: RA_IT_ETC
        case .armor: RA_IT_ARMOR
        case .weapon: RA_IT_WEAPON
        case .card: RA_IT_CARD
        case .petEgg: RA_IT_PETEGG
        case .petArmor: RA_IT_PETARMOR
        case .ammo: RA_IT_AMMO
        case .delayConsume: RA_IT_DELAYCONSUME
        case .shadowGear: RA_IT_SHADOWGEAR
        case .cash: RA_IT_CASH
        }
    }
}

extension ItemType: CustomStringConvertible {
    public var description: String {
        switch self {
        case .healing: "Healing"
        case .usable: "Usable"
        case .etc: "Etc"
        case .armor: "Armor"
        case .weapon: "Weapon"
        case .card: "Card"
        case .petEgg: "Pet Egg"
        case .petArmor: "Pet Armor"
        case .ammo: "Ammo"
        case .delayConsume: "Delay Consume"
        case .shadowGear: "Shadow Gear"
        case .cash: "Cash"
        }
    }
}
