//
//  ItemSubType.swift
//  DatabaseCore
//
//  Created by Leon Li on 2024/1/10.
//

import Constants

public enum ItemSubType: Equatable, Hashable, Sendable {
    case none
    case weapon(WeaponType)
    case ammo(AmmoType)
    case card(CardType)
}
