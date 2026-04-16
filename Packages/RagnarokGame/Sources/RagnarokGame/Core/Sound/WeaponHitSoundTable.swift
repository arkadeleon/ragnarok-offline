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
    static func hitSoundFilenames(for weaponType: WeaponType) -> [String] {
        switch weaponType {
        case .w_fist:
            ["_hit_fist1.wav", "_hit_fist2.wav", "_hit_fist3.wav", "_hit_fist4.wav"]
        case .w_dagger, .w_1hsword, .w_2hsword:
            ["_hit_sword.wav"]
        case .w_1hspear, .w_2hspear:
            ["_hit_spear.wav"]
        case .w_1haxe, .w_2haxe:
            ["_hit_axe.wav"]
        case .w_mace, .w_2hmace, .w_musical, .w_whip, .w_book, .w_katar:
            ["_hit_mace.wav"]
        case .w_staff, .w_2hstaff:
            ["_hit_rod.wav"]
        case .w_bow:
            ["_hit_arrow.wav"]
        case .w_knuckle:
            ["_HIT_FIST2.wav"]
        case .w_revolver:
            [K2L("_hit_권총.wav")]
        case .w_rifle:
            [K2L("_hit_라이플.wav")]
        case .w_gatling:
            [K2L("_hit_개틀링한발.wav")]
        case .w_shotgun:
            [K2L("_hit_샷건.wav")]
        case .w_grenade:
            [K2L("_hit_그레네이드런쳐.wav")]
        case .w_huuma, .w_shield:
            ["_hit_mace.wav"]
        }
    }
}
