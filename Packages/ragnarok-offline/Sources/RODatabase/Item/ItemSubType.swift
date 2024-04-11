//
//  ItemSubType.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/1/10.
//

public enum ItemSubType: Equatable {
    case none
    case weapon(WeaponType)
    case ammo(AmmoType)
    case card(CardType)
}
