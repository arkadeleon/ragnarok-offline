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
    private static let table: [WeaponType: [String]] = [
        .w_fist: ["attack_fist.wav"],
        .w_knuckle: ["attack_fist.wav"],
        .w_shield: ["attack_fist.wav"],
        .w_dagger: ["attack_short_sword.wav", "attack_short_sword_.wav"],
        .w_1hsword: ["attack_sword.wav"],
        .w_2hsword: ["attack_twohand_sword.wav"],
        .w_1hspear: ["attack_spear.wav"],
        .w_2hspear: ["attack_spear.wav"],
        .w_1haxe: ["attack_axe.wav"],
        .w_2haxe: ["attack_axe.wav"],
        .w_mace: ["attack_mace.wav"],
        .w_2hmace: ["attack_mace.wav"],
        .w_musical: ["attack_mace.wav"],
        .w_staff: ["attack_rod.wav"],
        .w_2hstaff: ["attack_rod.wav"],
        .w_bow: ["attack_bow1.wav", "attack_bow2.wav"],
        .w_whip: ["attack_whip.wav"],
        .w_book: ["attack_book.wav"],
        .w_katar: ["attack_katar.wav"],
        .w_revolver: [],
        .w_rifle: [],
        .w_gatling: [],
        .w_shotgun: [],
        .w_grenade: [],
        .w_huuma: ["attack_sword.wav"],
    ]

    static func attackSoundFilenames(for weaponType: WeaponType) -> [String] {
        table[weaponType] ?? []
    }
}
