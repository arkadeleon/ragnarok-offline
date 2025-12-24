//
//  ItemDatabaseFilter.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2025/12/18.
//

import Observation
import RagnarokConstants
import RagnarokDatabase

@Observable
class ItemDatabaseFilter {
    var searchText = ""

    var itemType: ItemType? {
        didSet {
            weaponType = nil
            ammoType = nil
            cardType = nil
            locations = EquipPositions(rawValue: 0)
        }
    }

    var availableItemTypes: [ItemType] {
        [.weapon, .armor, .card, .ammo, .shadowgear, .healing, .usable, .petegg, .petarmor, .delayconsume, .cash, .etc]
    }

    var weaponType: WeaponType?

    var availableWeaponTypes: [WeaponType] {
        [
            .w_dagger, .w_1hsword, .w_2hsword, .w_1hspear, .w_2hspear, .w_1haxe, .w_2haxe, .w_mace, .w_staff, .w_2hstaff,
            .w_bow, .w_knuckle, .w_musical, .w_whip, .w_book, .w_katar, .w_huuma,
            .w_revolver, .w_rifle, .w_gatling, .w_shotgun, .w_grenade,
        ]
    }

    var ammoType: AmmoType?

    var availableAmmoTypes: [AmmoType] {
         [.arrow, .bullet, .grenade, .shuriken, .kunai, .cannonball, .throwweapon, .dagger]
    }

    var cardType: CardType?

    var availableCardTypes: [CardType] {
        [.normal, .enchant]
    }

    var locations = EquipPositions(rawValue: 0)

    var availableLocations: [EquipPositions] {
        switch itemType {
        case .armor:
            [
                .head_low, .head_mid, .head_top,
                .left_hand, .armor, .shoes, .garment,
                .right_accessory, .left_accessory,
                .costume_head_top, .costume_head_mid, .costume_head_low, .costume_garment,
            ]
        case .card:
            [
                .head_low, .head_mid, .head_top,
                .right_hand, .left_hand, .armor, .shoes, .garment,
                .right_accessory, .left_accessory,
            ]
        case .shadowgear:
            [
                .shadow_armor, .shadow_weapon, .shadow_shield, .shadow_shoes,
                .shadow_right_accessory, .shadow_left_accessory,
            ]
        default:
            []
        }
    }

    var identifier: String {
        let itemType = itemType?.stringValue ?? "all"
        let weaponType = weaponType?.stringValue ?? "all"
        let ammoType = ammoType?.stringValue ?? "all"
        let cardType = cardType?.stringValue ?? "all"
        let locations = locations.rawValue

        return "\(searchText)+\(itemType)+\(weaponType)+\(ammoType)+\(cardType)+\(locations)"
    }

    var isEmpty: Bool {
        searchText.isEmpty &&
        itemType == nil &&
        weaponType == nil &&
        ammoType == nil &&
        cardType == nil &&
        locations.rawValue == 0
    }

    func isIncluded(_ item: ItemModel) -> Bool {
        if let itemType, item.type != itemType {
            return false
        }

        if let weaponType, item.type == .weapon, item.weaponType != weaponType {
            return false
        }

        if let ammoType, item.type == .ammo, item.ammoType != ammoType {
            return false
        }

        if let cardType, item.type == .card, item.cardType != cardType {
            return false
        }

        if item.type == .armor || item.type == .card || item.type == .shadowgear, !item.locations.contains(locations) {
            return false
        }

        if searchText.isEmpty {
            return true
        } else {
            return item.displayName.localizedStandardContains(searchText)
        }
    }
}
