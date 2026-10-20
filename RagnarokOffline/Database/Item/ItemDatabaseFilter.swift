//
//  ItemDatabaseFilter.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2025/12/18.
//

import RagnarokConstants

struct ItemDatabaseFilter: Equatable {
    var itemType: ItemType? {
        didSet {
            weaponType = nil
            ammoType = nil
            cardType = nil
            locations = EquipPositions(rawValue: 0)
            slots = nil
            job = nil
            baseLevel = nil
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

    var slots: Int?

    var availableSlots: [Int] {
        [0, 1, 2, 3, 4]
    }

    var job: EAJobID?

    var availableJobs: [EAJobID] {
        [
            .novice, .swordman, .mage, .archer, .acolyte, .merchant, .thief,
            .taekwon, .gunslinger, .ninja, .summoner,
            .super_novice, .knight, .wizard, .hunter, .priest, .blacksmith, .assassin,
            .star_gladiator, .rebellion, .kagerouoboro, .spirit_handler,
            .crusader, .sage, .barddancer, .monk, .alchemist, .rogue, .soul_linker,
        ]
    }

    /// Includes only the items that a character at this base level can equip.
    var baseLevel: Int?

    var isEmpty: Bool {
        itemType == nil &&
        weaponType == nil &&
        ammoType == nil &&
        cardType == nil &&
        locations.rawValue == 0 &&
        slots == nil &&
        job == nil &&
        baseLevel == nil
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

        if let slots, item.slots != slots {
            return false
        }

        if let job, !item.jobs.contains(job) {
            return false
        }

        // An equipLevelMax of 0 means no maximum level.
        if let baseLevel, baseLevel < item.equipLevelMin || (item.equipLevelMax > 0 && baseLevel > item.equipLevelMax) {
            return false
        }

        return true
    }

    mutating func toggleItemType(_ itemType: ItemType) {
        self.itemType = self.itemType == itemType ? nil : itemType
    }

    mutating func toggleWeaponType(_ weaponType: WeaponType) {
        self.weaponType = self.weaponType == weaponType ? nil : weaponType
    }

    mutating func toggleAmmoType(_ ammoType: AmmoType) {
        self.ammoType = self.ammoType == ammoType ? nil : ammoType
    }

    mutating func toggleCardType(_ cardType: CardType) {
        self.cardType = self.cardType == cardType ? nil : cardType
    }

    mutating func toggleLocation(_ location: EquipPositions) {
        if locations.contains(location) {
            locations.remove(location)
        } else {
            locations.insert(location)
        }
    }

    mutating func toggleSlots(_ slots: Int) {
        self.slots = self.slots == slots ? nil : slots
    }

    mutating func toggleJob(_ job: EAJobID) {
        self.job = self.job == job ? nil : job
    }

    mutating func reset() {
        itemType = nil
        weaponType = nil
        ammoType = nil
        cardType = nil
        locations = EquipPositions(rawValue: 0)
        slots = nil
        job = nil
        baseLevel = nil
    }
}
