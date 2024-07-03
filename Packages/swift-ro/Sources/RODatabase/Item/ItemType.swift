//
//  ItemType.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/1/10.
//

import rAthenaCommon

public enum ItemType: CaseIterable, CodingKey, Decodable {
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

//    public init?(stringValue: String) {
//        if let itemType = ItemType.allCases.first(where: { $0.stringValue.caseInsensitiveCompare(stringValue) == .orderedSame }) {
//            self = itemType
//        } else {
//            return nil
//        }
//    }
//
//    public init(from decoder: Decoder) throws {
//        let container = try decoder.singleValueContainer()
//        let stringValue = try container.decode(String.self)
//        if let itemType = ItemType(stringValue: stringValue) {
//            self = itemType
//        } else {
//            let context = DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Item type does not exist.")
//            throw DecodingError.valueNotFound(ItemType.self, context)
//        }
//    }
}

extension ItemType: CustomLocalizedStringResourceConvertible {
    public var localizedStringResource: LocalizedStringResource {
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
