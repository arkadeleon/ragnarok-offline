//
//  Inventory.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2025/4/10.
//

import ROConstants
import ROPackets

public struct Inventory: Sendable {
    public var stackableItems: [StackableItem]
    public var equippableItems: [EquippableItem]

    public init() {
        stackableItems = []
        equippableItems = []
    }
}

extension Inventory {
    public struct StackableItem: Sendable {
        public var index: Int
        public var itemID: Int
        public var itemType: ItemType
        public var count: Int
        public var equipState: EquipPositions
        public var cards: [Int]

        public init() {
            index = 0
            itemID = 0
            itemType = .etc
            count = 0
            equipState = EquipPositions(rawValue: 0)
            cards = [0, 0, 0, 0]
        }

        public init(item: NORMALITEM_INFO) {
            index = Int(item.index)
            itemID = Int(item.ITID)
            itemType = ItemType(rawValue: Int(item.type)) ?? .etc
            count = Int(item.count)
            equipState = EquipPositions(rawValue: Int(item.WearState))
            cards = item.slot.card.map(Int.init)
        }
    }
}

extension Inventory {
    public struct EquippableItem: Sendable {
        public var index: Int
        public var itemID: Int
        public var itemType: ItemType
        public var location: EquipPositions
        public var equipState: EquipPositions
        public var refiningLevel: Int
        public var cards: [Int]

        public init() {
            index = 0
            itemID = 0
            itemType = .etc
            location = EquipPositions(rawValue: 0)
            equipState = EquipPositions(rawValue: 0)
            refiningLevel = 0
            cards = [0, 0, 0, 0]
        }

        public init(item: EQUIPITEM_INFO) {
            index = Int(item.index)
            itemID = Int(item.ITID)
            itemType = ItemType(rawValue: Int(item.type)) ?? .etc
            location = EquipPositions(rawValue: Int(item.location))
            equipState = EquipPositions(rawValue: Int(item.WearState))
            refiningLevel = Int(item.RefiningLevel)
            cards = item.slot.card.map(Int.init)
        }
    }
}
