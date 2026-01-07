//
//  InventoryItem.swift
//  RagnarokModels
//
//  Created by Leon Li on 2025/4/15.
//

import RagnarokConstants
import RagnarokPackets

public struct InventoryItem: Sendable {
    public var index: Int
    public var itemID: Int
    public var type: ItemType
    public var amount: Int
    public var location: EquipPositions
    public var equippedLocation: EquipPositions
    public var slots: [Int]

    public var isUsable: Bool {
        switch type {
        case .healing, .usable, .delayconsume, .cash: true
        default: false
        }
    }

    public var isEquippable: Bool {
        switch type {
        case .weapon, .armor, .shadowgear, .petegg, .petarmor: true
        default: false
        }
    }

    public var isEquipped: Bool {
        !equippedLocation.isEmpty && type != .card && type != .ammo
    }

    public var isEtc: Bool {
        switch type {
        case .etc, .card, .ammo: true
        default: false
        }
    }

    public init() {
        index = 0
        itemID = 0
        type = .etc
        amount = 0
        location = EquipPositions(rawValue: 0)
        equippedLocation = EquipPositions(rawValue: 0)
        slots = [0, 0, 0, 0]
    }

    public init(from item: NORMALITEM_INFO) {
        index = Int(item.index)
        itemID = Int(item.ITID)
        type = ItemType(rawValue: Int(item.type)) ?? .etc
        amount = Int(item.count)
        location = EquipPositions(rawValue: 0)
        equippedLocation = EquipPositions(rawValue: Int(item.WearState))
        slots = item.slot.card.map(Int.init)
    }

    public init(from item: EQUIPITEM_INFO) {
        index = Int(item.index)
        itemID = Int(item.ITID)
        type = ItemType(rawValue: Int(item.type)) ?? .etc
        amount = 1
        location = EquipPositions(rawValue: Int(item.location))
        equippedLocation = EquipPositions(rawValue: Int(item.WearState))
        slots = item.slot.card.map(Int.init)
    }
}

extension InventoryItem: Comparable {
    public static func < (lhs: InventoryItem, rhs: InventoryItem) -> Bool {
        lhs.index < rhs.index
    }
}
