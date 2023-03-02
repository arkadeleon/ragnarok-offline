//
//  Item.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2023/3/2.
//  Copyright © 2023 Leon & Vane. All rights reserved.
//

import rAthenaCommon

extension RAItem {
    typealias Attribute = (name: String, value: String)

    var attributes: [Attribute] {
        let attributes: [Attribute?] = [
            ("Type", type.name),
            (type == .weapon ? ("Weapon Type", String(subType.rawValue)) : nil),
            (type == .ammo ? ("Ammo Type", String(subType.rawValue)) : nil),
            (type == .card ? ("Card Type", String(subType.rawValue)) : nil),
            ("Buy", String(buy)),
            ("Sell", String(sell)),
            ("Weight", String(weight)),
            (type == .weapon ? ("Attack", String(attack)) : nil),
            (type == .weapon ? ("Magic Attack", String(magicAttack)) : nil),
            (type == .armor ? ("Defense", String(defense)) : nil),
            (type == .weapon ? ("Attack Range", String(range)) : nil),
            (type == .weapon || type == .armor ? ("Slots", String(slots)) : nil),
            (type == .weapon ? ("Weapon Level", String(weaponLevel)) : nil),
            (type == .armor ? ("Armor Level", String(armorLevel)) : nil),
        ]
        return attributes.compactMap({ $0 })
    }
}

extension RAItemType {
    var name: String {
        switch self {
        case .healing:
            return "Healing"
        case .usable:
            return "Usable"
        case .etc:
            return "Etc"
        case .armor:
            return "Armor"
        case .weapon:
            return "Weapon"
        case .card:
            return "Card"
        case .petEgg:
            return "Pet Egg"
        case .petArmor:
            return "Pet Armor"
        case .ammo:
            return "Ammo"
        case .delayConsume:
            return "Delay Consume"
        case .shadowGear:
            return "Shadow Gear"
        case .cash:
            return "Cash"
        @unknown default:
            fatalError()
        }
    }
}
