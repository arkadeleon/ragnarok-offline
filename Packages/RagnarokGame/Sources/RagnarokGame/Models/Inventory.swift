//
//  Inventory.swift
//  RagnarokGame
//
//  Created by Leon Li on 2025/4/10.
//

import Observation
import RagnarokConstants
import RagnarokModels
import RagnarokPackets

@Observable
final class Inventory {
    var items: [Int : InventoryItem] = [:]

    var usableItems: [InventoryItem] {
        let usableItems = items.values.filter(\.isUsable)
        return usableItems.sorted()
    }

    var equippableItems: [InventoryItem] {
        let equippableItems = items.values.filter(\.isEquippable)
        return equippableItems.sorted()
    }

    var etcItems: [InventoryItem] {
        let etcItems = items.values.filter(\.isEtc)
        return etcItems.sorted()
    }

    func item(equippedAt location: EquipPositions) -> InventoryItem? {
        items.values.first {
            $0.equippedLocation.contains(location)
        }
    }

    func update(from packet: packet_itemlist_normal) {
        let items = packet.list.map { InventoryItem(from: $0) }
        for item in items {
            self.items[item.index] = item
        }
    }

    func update(from packet: packet_itemlist_equip) {
        let items = packet.list.map { InventoryItem(from: $0) }
        for item in items {
            self.items[item.index] = item
        }
    }

    func update(from packet: PACKET_ZC_USE_ITEM_ACK) {
        let usedItem = UsedItem(from: packet)
        if var item = items[usedItem.index] {
            item.amount = usedItem.amount
            items[usedItem.index] = item
        }
    }
}
