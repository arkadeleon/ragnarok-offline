//
//  ItemType+Localization.swift
//  RagnarokLocalization
//
//  Created by Leon Li on 2024/1/10.
//

import Foundation
import RagnarokConstants

extension ItemType {
    public var localizedName: LocalizedStringResource {
        switch self {
        case .healing:
            LocalizedStringResource("Healing", table: "ItemType", bundle: .module)
        case .usable:
            LocalizedStringResource("Usable", table: "ItemType", bundle: .module)
        case .etc:
            LocalizedStringResource("Etc", table: "ItemType", bundle: .module)
        case .armor:
            LocalizedStringResource("Armor", table: "ItemType", bundle: .module)
        case .weapon:
            LocalizedStringResource("Weapon", table: "ItemType", bundle: .module)
        case .card:
            LocalizedStringResource("Card", table: "ItemType", bundle: .module)
        case .petegg:
            LocalizedStringResource("Pet Egg", table: "ItemType", bundle: .module)
        case .petarmor:
            LocalizedStringResource("Pet Armor", table: "ItemType", bundle: .module)
        case .ammo:
            LocalizedStringResource("Ammo", table: "ItemType", bundle: .module)
        case .delayconsume:
            LocalizedStringResource("Delay Consume", table: "ItemType", bundle: .module)
        case .shadowgear:
            LocalizedStringResource("Shadow Gear", table: "ItemType", bundle: .module)
        case .cash:
            LocalizedStringResource("Cash", table: "ItemType", bundle: .module)
        }
    }
}
