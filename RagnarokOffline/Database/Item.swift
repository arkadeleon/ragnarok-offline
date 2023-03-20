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
            ("Type", type.englishName),
            (type == .weapon ? ("Weapon Type", subType?.asWeaponType()?.englishName ?? "") : nil),
            (type == .ammo ? ("Ammo Type", subType?.asAmmoType()?.englishName ?? "") : nil),
            (type == .card ? ("Card Type", subType?.asCardType()?.englishName ?? "") : nil),
            ("Buy", String(buy > 0 ? buy : sell * 2)),
            ("Sell", String(sell > 0 ? sell : buy / 2)),
            ("Weight", String(weight / 10)),
            (type == .weapon ? ("Attack", String(attack)) : nil),
            (type == .weapon ? ("Magic Attack", String(magicAttack)) : nil),
            (type == .armor ? ("Defense", String(defense)) : nil),
            (type == .weapon ? ("Attack Range", String(range)) : nil),
            (type == .weapon || type == .armor ? ("Slots", String(slots)) : nil),
            ("Gender", gender.englishName),
            (type == .weapon || type == .armor ? ("Locations", locations.map({ $0.englishName }).joined(separator: " / ")) : nil),
            (type == .weapon ? ("Weapon Level", String(weaponLevel)) : nil),
            (type == .armor ? ("Armor Level", String(armorLevel)) : nil),
            (equipLevelMin > 0 ? ("Minimum Equipable Level", String(equipLevelMin)) : nil),
            (equipLevelMax > 0 ? ("Maximum Equipable Level", String(equipLevelMax)) : nil),
        ]
        return attributes.compactMap({ $0 })
    }
}
