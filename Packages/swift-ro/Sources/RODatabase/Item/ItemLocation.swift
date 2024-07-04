//
//  ItemLocation.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/1/10.
//

import rAthenaCommon

public enum ItemLocation: Option {
    case headTop
    case headMid
    case headLow
    case armor
    case rightHand
    case leftHand
    case garment
    case shoes
    case rightAccessory
    case leftAccessory
    case costumeHeadTop
    case costumeHeadMid
    case costumeHeadLow
    case costumeGarment
    case ammo
    case shadowArmor
    case shadowWeapon
    case shadowShield
    case shadowShoes
    case shadowRightAccessory
    case shadowLeftAccessory

    public var intValue: Int {
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
        }
    }

    public var stringValue: String {
        switch self {
        case .headTop: "Head_Top"
        case .headMid: "Head_Mid"
        case .headLow: "Head_Low"
        case .armor: "Armor"
        case .rightHand: "Right_Hand"
        case .leftHand: "Left_Hand"
        case .garment: "Garment"
        case .shoes: "Shoes"
        case .rightAccessory: "Right_Accessory"
        case .leftAccessory: "Left_Accessory"
        case .costumeHeadTop: "Costume_Head_Top"
        case .costumeHeadMid: "Costume_Head_Mid"
        case .costumeHeadLow: "Costume_Head_Low"
        case .costumeGarment: "Costume_Garment"
        case .ammo: "Ammo"
        case .shadowArmor: "Shadow_Armor"
        case .shadowWeapon: "Shadow_Weapon"
        case .shadowShield: "Shadow_Shield"
        case .shadowShoes: "Shadow_Shoes"
        case .shadowRightAccessory: "Shadow_Right_Accessory"
        case .shadowLeftAccessory: "Shadow_Left_Accessory"
        }
    }
}

extension Set where Element == ItemLocation {
    public static let bothHand: Set<ItemLocation> = [.rightHand, .leftHand]
    public static let bothAccessory: Set<ItemLocation> = [.rightAccessory, .leftAccessory]

    public init(from dictionary: [String : Bool]) {
        self = []

        if dictionary.keys.contains("All") {
            formUnion(ItemLocation.allCases)
        }
        if dictionary.keys.contains("Both_Hand") {
            formUnion(Set<ItemLocation>.bothHand)
        }
        if dictionary.keys.contains("Both_Accessory") {
            formUnion(Set<ItemLocation>.bothAccessory)
        }

        for (key, value) in dictionary {
            if let itemLocation = ItemLocation(stringValue: key) {
                if value {
                    insert(itemLocation)
                } else {
                    remove(itemLocation)
                }
            }
        }
    }
}
