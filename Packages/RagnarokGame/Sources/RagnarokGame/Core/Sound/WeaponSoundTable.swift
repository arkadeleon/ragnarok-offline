//
//  WeaponSoundTable.swift
//  RagnarokGame
//
//  Created by Leon Li on 2026/4/15.
//

import RagnarokConstants

// Ported from roBrowserLegacy:
// https://github.com/MrAntares/roBrowserLegacy/blob/master/src/DB/Items/WeaponSoundTable.js
enum WeaponSoundTable {
    static func attackSoundFilenames(for weaponType: WeaponType) -> [String] {
        switch weaponType {
        case .w_fist, .w_knuckle, .w_shield:
            ["attack_fist.wav"]
        case .w_dagger:
            ["attack_short_sword.wav", "attack_short_sword_.wav"]
        case .w_1hsword:
            ["attack_sword.wav"]
        case .w_2hsword:
            ["attack_twohand_sword.wav"]
        case .w_1hspear, .w_2hspear:
            ["attack_spear.wav"]
        case .w_1haxe, .w_2haxe:
            ["attack_axe.wav"]
        case .w_mace, .w_2hmace, .w_musical:
            ["attack_mace.wav"]
        case .w_staff, .w_2hstaff:
            ["attack_rod.wav"]
        case .w_bow:
            ["attack_bow1.wav", "attack_bow2.wav"]
        case .w_whip:
            ["attack_whip.wav"]
        case .w_book:
            ["attack_book.wav"]
        case .w_katar:
            ["attack_katar.wav"]
        case .w_revolver, .w_rifle, .w_gatling, .w_shotgun, .w_grenade:
            []
        case .w_huuma:
            ["attack_sword.wav"]
        }
    }
}
