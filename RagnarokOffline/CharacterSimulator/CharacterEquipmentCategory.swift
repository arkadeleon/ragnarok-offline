//
//  CharacterEquipmentCategory.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2026/5/21.
//

import Foundation

enum CharacterEquipmentCategory: CaseIterable {
    case headTop
    case headMid
    case headBottom
    case garment

    var nameResource: LocalizedStringResource {
        switch self {
        case .headTop:
            LocalizedStringResource("Head Top", table: "CharacterSimulator")
        case .headMid:
            LocalizedStringResource("Head Mid", table: "CharacterSimulator")
        case .headBottom:
            LocalizedStringResource("Head Bottom", table: "CharacterSimulator")
        case .garment:
            LocalizedStringResource("Garment", table: "CharacterSimulator")
        }
    }

    func includes(_ item: ItemModel) -> Bool {
        switch self {
        case .headTop:
            item.type == .armor && item.locations.contains(.head_top)
        case .headMid:
            item.type == .armor && item.locations.contains(.head_mid)
        case .headBottom:
            item.type == .armor && item.locations.contains(.head_low)
        case .garment:
            item.type == .armor && item.locations.contains(.garment) && item.view > 0
        }
    }
}
