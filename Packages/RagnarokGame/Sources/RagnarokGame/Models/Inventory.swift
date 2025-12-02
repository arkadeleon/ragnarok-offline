//
//  Inventory.swift
//  RagnarokGame
//
//  Created by Leon Li on 2025/4/10.
//

import Observation
import RagnarokNetwork

@Observable
final class Inventory {
    var items: [Int : InventoryItem] = [:]

    var usableItems: [InventoryItem] {
        let usableItems = items.values.filter { $0.isUsable }
        return usableItems.sorted()
    }

    var equippableItems: [InventoryItem] {
        let equippableItems = items.values.filter { $0.isEquippable }
        return equippableItems.sorted()
    }

    var etcItems: [InventoryItem] {
        let etcItems = items.values.filter { $0.isEtc }
        return etcItems.sorted()
    }

    func append(items: [InventoryItem]) {
        for item in items {
            self.items[item.index] = item
        }
    }

    func updateItem(at index: Int, amount: Int) {
        if var item = items[index] {
            item.amount = amount
            items[index] = item
        }
    }
}
