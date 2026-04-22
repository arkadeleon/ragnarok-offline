//
//  WeaponHitSoundTable.swift
//  RagnarokGame
//
//  Created by Leon Li on 2026/4/15.
//

import RagnarokConstants
import RagnarokCore

// Ported from roBrowserLegacy:
// https://github.com/MrAntares/roBrowserLegacy/blob/master/src/DB/Items/WeaponHitSoundTable.js
enum WeaponHitSoundTable {
    private static let table: [WeaponType: [String]] = [
        .w_fist: ["_hit_fist1.wav", "_hit_fist2.wav", "_hit_fist3.wav", "_hit_fist4.wav"],
        .w_dagger: ["_hit_sword.wav"],
        .w_1hsword: ["_hit_sword.wav"],
        .w_2hsword: ["_hit_sword.wav"],
        .w_1hspear: ["_hit_spear.wav"],
        .w_2hspear: ["_hit_spear.wav"],
        .w_1haxe: ["_hit_axe.wav"],
        .w_2haxe: ["_hit_axe.wav"],
        .w_mace: ["_hit_mace.wav"],
        .w_2hmace: ["_hit_mace.wav"],
        .w_musical: ["_hit_mace.wav"],
        .w_whip: ["_hit_mace.wav"],
        .w_book: ["_hit_mace.wav"],
        .w_katar: ["_hit_mace.wav"],
        .w_staff: ["_hit_rod.wav"],
        .w_2hstaff: ["_hit_rod.wav"],
        .w_bow: ["_hit_arrow.wav"],
        .w_knuckle: ["_HIT_FIST2.wav"],
        .w_revolver: ["_hit_권총.wav"],
        .w_rifle: ["_hit_라이플.wav"],
        .w_gatling: ["_hit_개틀링한발.wav"],
        .w_shotgun: ["_hit_샷건.wav"],
        .w_grenade: ["_hit_그레네이드런쳐.wav"],
        .w_huuma: ["_hit_mace.wav"],
        .w_shield: ["_hit_mace.wav"],
    ]

    static func hitSoundNames(for weaponType: WeaponType) -> [String] {
        (table[weaponType] ?? []).map(K2L)
    }
}
