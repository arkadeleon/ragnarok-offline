//
//  WeaponType+Localization.swift
//  RagnarokLocalization
//
//  Created by Leon Li on 2024/1/10.
//

import Foundation
import RagnarokConstants

extension WeaponType {
    public var localizedName: LocalizedStringResource {
        switch self {
        case .w_fist:
            LocalizedStringResource("Fist", table: "WeaponType", bundle: .module)
        case .w_dagger:
            LocalizedStringResource("Dagger", table: "WeaponType", bundle: .module)
        case .w_1hsword:
            LocalizedStringResource("One-Handed Sword", table: "WeaponType", bundle: .module)
        case .w_2hsword:
            LocalizedStringResource("Two-Handed Sword", table: "WeaponType", bundle: .module)
        case .w_1hspear:
            LocalizedStringResource("One-Handed Spear", table: "WeaponType", bundle: .module)
        case .w_2hspear:
            LocalizedStringResource("Two-Handed Spear", table: "WeaponType", bundle: .module)
        case .w_1haxe:
            LocalizedStringResource("One-Handed Axe", table: "WeaponType", bundle: .module)
        case .w_2haxe:
            LocalizedStringResource("Two-Handed Axe", table: "WeaponType", bundle: .module)
        case .w_mace:
            LocalizedStringResource("Mace", table: "WeaponType", bundle: .module)
        case .w_2hmace:
            LocalizedStringResource("Two-Handed Mace", table: "WeaponType", bundle: .module)
        case .w_staff:
            LocalizedStringResource("Staff", table: "WeaponType", bundle: .module)
        case .w_bow:
            LocalizedStringResource("Bow", table: "WeaponType", bundle: .module)
        case .w_knuckle:
            LocalizedStringResource("Knuckle", table: "WeaponType", bundle: .module)
        case .w_musical:
            LocalizedStringResource("Musical", table: "WeaponType", bundle: .module)
        case .w_whip:
            LocalizedStringResource("Whip", table: "WeaponType", bundle: .module)
        case .w_book:
            LocalizedStringResource("Book", table: "WeaponType", bundle: .module)
        case .w_katar:
            LocalizedStringResource("Katar", table: "WeaponType", bundle: .module)
        case .w_revolver:
            LocalizedStringResource("Revolver", table: "WeaponType", bundle: .module)
        case .w_rifle:
            LocalizedStringResource("Rifle", table: "WeaponType", bundle: .module)
        case .w_gatling:
            LocalizedStringResource("Gatling", table: "WeaponType", bundle: .module)
        case .w_shotgun:
            LocalizedStringResource("Shotgun", table: "WeaponType", bundle: .module)
        case .w_grenade:
            LocalizedStringResource("Grenade", table: "WeaponType", bundle: .module)
        case .w_huuma:
            LocalizedStringResource("Huuma", table: "WeaponType", bundle: .module)
        case .w_2hstaff:
            LocalizedStringResource("Two-Handed Staff", table: "WeaponType", bundle: .module)
        case .w_shield:
            LocalizedStringResource("Shield", table: "WeaponType", bundle: .module)
        }
    }
}
