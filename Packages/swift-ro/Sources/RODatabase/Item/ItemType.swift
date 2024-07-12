//
//  ItemType.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/1/10.
//

import rAthenaCommon

public enum ItemType: Option {
    case healing
    case usable
    case etc
    case armor
    case weapon
    case card
    case petEgg
    case petArmor
    case ammo
    case delayConsume
    case shadowGear
    case cash

    public var intValue: Int {
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

    public var stringValue: String {
        switch self {
        case .healing: "Healing"
        case .usable: "Usable"
        case .etc: "Etc"
        case .armor: "Armor"
        case .weapon: "Weapon"
        case .card: "Card"
        case .petEgg: "PetEgg"
        case .petArmor: "PetArmor"
        case .ammo: "Ammo"
        case .delayConsume: "DelayConsume"
        case .shadowGear: "ShadowGear"
        case .cash: "Cash"
        }
    }
}

extension ItemType: CustomLocalizedStringResourceConvertible {
    public var localizedStringResource: LocalizedStringResource {
        switch self {
        case .healing: .init("Healing", bundle: .module)
        case .usable: .init("Usable", bundle: .module)
        case .etc: .init("Etc", bundle: .module)
        case .armor: .init("Armor", bundle: .module)
        case .weapon: .init("Weapon", bundle: .module)
        case .card: .init("Card", bundle: .module)
        case .petEgg: .init("Pet Egg", bundle: .module)
        case .petArmor: .init("Pet Armor", bundle: .module)
        case .ammo: .init("Ammo", bundle: .module)
        case .delayConsume: .init("Delay Consume", bundle: .module)
        case .shadowGear: .init("Shadow Gear", bundle: .module)
        case .cash: .init("Cash", bundle: .module)
        }
    }
}
