//
//  ItemLocation.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/1/10.
//

import rAthenaCommon

public enum ItemLocation: String, CaseIterable, CodingKey, Decodable {

    /// Upper Headgear
    case headTop = "Head_Top"

    /// Middle Headgear
    case headMid = "Head_Mid"

    /// Lower Headgear
    case headLow = "Head_Low"

    /// Armor
    case armor = "Armor"

    /// Weapon
    case rightHand = "Right_Hand"

    /// Shield
    case leftHand = "Left_Hand"

    /// Garment/Robe
    case garment = "Garment"

    /// Shoes
    case shoes = "Shoes"

    /// Accessory Right
    case rightAccessory = "Right_Accessory"

    /// Accessory Left
    case leftAccessory = "Left_Accessory"

    /// Costume Top Headgear
    case costumeHeadTop = "Costume_Head_Top"

    /// Costume Mid Headgear
    case costumeHeadMid = "Costume_Head_Mid"

    /// Costume Low Headgear
    case costumeHeadLow = "Costume_Head_Low"

    /// Costume Garment/Robe
    case costumeGarment = "Costume_Garment"

    /// Ammo
    case ammo = "Ammo"

    /// Shadow Armor
    case shadowArmor = "Shadow_Armor"

    /// Shadow Weapon
    case shadowWeapon = "Shadow_Weapon"

    /// Shadow Shield
    case shadowShield = "Shadow_Shield"

    /// Shadow Shoes
    case shadowShoes = "Shadow_Shoes"

    /// Shadow Accessory Right (Earring)
    case shadowRightAccessory = "Shadow_Right_Accessory"

    /// Shadow Accessory Left (Pendant)
    case shadowLeftAccessory = "Shadow_Left_Accessory"

    /// Right_Hand + Left_Hand
    case bothHand = "Both_Hand"

    /// Right_Accessory + Left_Accessory
    case bothAccessory = "Both_Accessory"
}

extension ItemLocation: Identifiable {
    public var id: Int {
        switch self {
        case .headTop: RA_EQP_HEAD_TOP
        case .headMid: RA_EQP_HEAD_MID
        case .headLow: RA_EQP_HEAD_LOW
        case .armor: RA_EQP_ARMOR
        case .rightHand: RA_EQP_HAND_R
        case .leftHand: RA_EQP_HAND_L
        case .garment: RA_EQP_GARMENT
        case .shoes: RA_EQP_SHOES
        case .rightAccessory: RA_EQP_ACC_R
        case .leftAccessory: RA_EQP_ACC_L
        case .costumeHeadTop: RA_EQP_COSTUME_HEAD_TOP
        case .costumeHeadMid: RA_EQP_COSTUME_HEAD_MID
        case .costumeHeadLow: RA_EQP_COSTUME_HEAD_LOW
        case .costumeGarment: RA_EQP_COSTUME_GARMENT
        case .ammo: RA_EQP_AMMO
        case .shadowArmor: RA_EQP_SHADOW_ARMOR
        case .shadowWeapon: RA_EQP_SHADOW_WEAPON
        case .shadowShield: RA_EQP_SHADOW_SHIELD
        case .shadowShoes: RA_EQP_SHADOW_SHOES
        case .shadowRightAccessory: RA_EQP_ACC_R
        case .shadowLeftAccessory: RA_EQP_ACC_L
        case .bothHand: RA_EQP_HAND_R | RA_EQP_HAND_L
        case .bothAccessory: RA_EQP_ACC_RL
        }
    }
}

extension ItemLocation: CustomStringConvertible {
    public var description: String {
        stringValue
    }
}
