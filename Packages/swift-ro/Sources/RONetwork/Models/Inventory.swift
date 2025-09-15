//
//  Inventory.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2025/4/10.
//

import Constants
import ROPackets

public struct Inventory: Sendable {
    public internal(set) var items: [Int : InventoryItem]

    public var usableItems: [InventoryItem] {
        let usableItems = items.values.filter { $0.isUsable }
        return usableItems.sorted()
    }

    public var equippableItems: [InventoryItem] {
        let equippableItems = items.values.filter { $0.isEquippable }
        return equippableItems.sorted()
    }

    public var etcItems: [InventoryItem] {
        let etcItems = items.values.filter { $0.isEtc }
        return etcItems.sorted()
    }

    public init() {
        items = [:]
    }

    public mutating func append(items: [InventoryItem]) {
        for item in items {
            self.items[item.index] = item
        }
    }

    mutating func append(items: [NORMALITEM_INFO]) {
        let items = items.map(InventoryItem.init)
        append(items: items)
    }

    mutating func append(items: [EQUIPITEM_INFO]) {
        let items = items.map(InventoryItem.init)
        append(items: items)
    }

    mutating func updateItem(at index: Int, amount: Int) {
        if var item = items[index] {
            item.amount = amount
            items[index] = item
        }
    }
}
