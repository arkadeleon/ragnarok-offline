//
//  ItemType.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/1/10.
//

import Foundation
import ROGenerated

extension ItemType: CustomLocalizedStringResourceConvertible {
    public var localizedStringResource: LocalizedStringResource {
        switch self {
        case .healing: .init("Healing", bundle: .module)
        case .usable: .init("Usable", bundle: .module)
        case .etc: .init("Etc", bundle: .module)
        case .armor: .init("Armor", bundle: .module)
        case .weapon: .init("Weapon", bundle: .module)
        case .card: .init("Card", bundle: .module)
        case .petegg: .init("Pet Egg", bundle: .module)
        case .petarmor: .init("Pet Armor", bundle: .module)
        case .ammo: .init("Ammo", bundle: .module)
        case .delayconsume: .init("Delay Consume", bundle: .module)
        case .shadowgear: .init("Shadow Gear", bundle: .module)
        case .cash: .init("Cash", bundle: .module)
        }
    }
}
