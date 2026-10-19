//
//  EquipPositions+Localization.swift
//  RagnarokConstants
//
//  Created by Leon Li on 2026/10/20.
//

import Foundation

extension EquipPositions {
    public var localizedName: LocalizedStringResource {
        switch self {
        case .head_low:
            LocalizedStringResource("Lower Headgear", table: "EquipPositions", bundle: .module)
        case .head_mid:
            LocalizedStringResource("Middle Headgear", table: "EquipPositions", bundle: .module)
        case .head_top:
            LocalizedStringResource("Upper Headgear", table: "EquipPositions", bundle: .module)
        case .right_hand:
            LocalizedStringResource("Right Hand", table: "EquipPositions", bundle: .module)
        case .left_hand:
            LocalizedStringResource("Left Hand", table: "EquipPositions", bundle: .module)
        case .armor:
            LocalizedStringResource("Armor", table: "EquipPositions", bundle: .module)
        case .shoes:
            LocalizedStringResource("Shoes", table: "EquipPositions", bundle: .module)
        case .garment:
            LocalizedStringResource("Garment", table: "EquipPositions", bundle: .module)
        case .right_accessory:
            LocalizedStringResource("Right Accessory", table: "EquipPositions", bundle: .module)
        case .left_accessory:
            LocalizedStringResource("Left Accessory", table: "EquipPositions", bundle: .module)
        case .costume_head_top:
            LocalizedStringResource("Costume Upper Headgear", table: "EquipPositions", bundle: .module)
        case .costume_head_mid:
            LocalizedStringResource("Costume Middle Headgear", table: "EquipPositions", bundle: .module)
        case .costume_head_low:
            LocalizedStringResource("Costume Lower Headgear", table: "EquipPositions", bundle: .module)
        case .costume_garment:
            LocalizedStringResource("Costume Garment", table: "EquipPositions", bundle: .module)
        case .ammo:
            LocalizedStringResource("Ammunition", table: "EquipPositions", bundle: .module)
        case .shadow_armor:
            LocalizedStringResource("Shadow Armor", table: "EquipPositions", bundle: .module)
        case .shadow_weapon:
            LocalizedStringResource("Shadow Weapon", table: "EquipPositions", bundle: .module)
        case .shadow_shield:
            LocalizedStringResource("Shadow Shield", table: "EquipPositions", bundle: .module)
        case .shadow_shoes:
            LocalizedStringResource("Shadow Shoes", table: "EquipPositions", bundle: .module)
        case .shadow_right_accessory:
            LocalizedStringResource("Shadow Right Accessory", table: "EquipPositions", bundle: .module)
        case .shadow_left_accessory:
            LocalizedStringResource("Shadow Left Accessory", table: "EquipPositions", bundle: .module)
        case .both_accessory:
            LocalizedStringResource("Both Accessories", table: "EquipPositions", bundle: .module)
        case .both_hand:
            LocalizedStringResource("Two-Handed", table: "EquipPositions", bundle: .module)
        default:
            LocalizedStringResource(stringLiteral: stringValue)
        }
    }
}
