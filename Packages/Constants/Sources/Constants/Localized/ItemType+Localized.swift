//
//  ItemType+Localized.swift
//  Constants
//
//  Created by Leon Li on 2024/1/10.
//

import Foundation

extension ItemType {
    public var localizedName: LocalizedStringResource {
        switch self {
        case .healing:
            LocalizedStringResource("Healing", table: "ItemType", bundle: .module, comment: "The name of an item type.")
        case .usable:
            LocalizedStringResource("Usable", table: "ItemType", bundle: .module, comment: "The name of an item type.")
        case .etc:
            LocalizedStringResource("Etc", table: "ItemType", bundle: .module, comment: "The name of an item type.")
        case .armor:
            LocalizedStringResource("Armor", table: "ItemType", bundle: .module, comment: "The name of an item type.")
        case .weapon:
            LocalizedStringResource("Weapon", table: "ItemType", bundle: .module, comment: "The name of an item type.")
        case .card:
            LocalizedStringResource("Card", table: "ItemType", bundle: .module, comment: "The name of an item type.")
        case .petegg:
            LocalizedStringResource("Pet Egg", table: "ItemType", bundle: .module, comment: "The name of an item type.")
        case .petarmor:
            LocalizedStringResource("Pet Armor", table: "ItemType", bundle: .module, comment: "The name of an item type.")
        case .ammo:
            LocalizedStringResource("Ammo", table: "ItemType", bundle: .module, comment: "The name of an item type.")
        case .delayconsume:
            LocalizedStringResource("Delay Consume", table: "ItemType", bundle: .module, comment: "The name of an item type.")
        case .shadowgear:
            LocalizedStringResource("Shadow Gear", table: "ItemType", bundle: .module, comment: "The name of an item type.")
        case .cash:
            LocalizedStringResource("Cash", table: "ItemType", bundle: .module, comment: "The name of an item type.")
        }
    }
}
