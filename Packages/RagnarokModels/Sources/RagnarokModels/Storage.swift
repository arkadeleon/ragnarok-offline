//
//  Storage.swift
//  RagnarokModels
//
//  Created by Leon Li on 2026/9/26.
//

import RagnarokConstants
import RagnarokPackets

public struct Storage: Sendable {
    public var name: String
    public var items: [Int : InventoryItem] = [:]
    public var amount = 0
    public var maxAmount = 0

    public init(name: String) {
        self.name = name
    }

    public mutating func update(from packet: packet_itemlist_normal) {
        let items = packet.list.map(InventoryItem.init(from:))
        for item in items {
            self.items[item.index] = item
        }
    }

    public mutating func update(from packet: packet_itemlist_equip) {
        let items = packet.list.map(InventoryItem.init(from:))
        for item in items {
            self.items[item.index] = item
        }
    }

    public mutating func update(from packet: PACKET_ZC_NOTIFY_STOREITEM_COUNTINFO) {
        amount = Int(packet.amount)
        maxAmount = Int(packet.max_amount)
    }

    public mutating func update(from packet: PACKET_ZC_ADD_ITEM_TO_STORE) {
        let index = Int(packet.index)
        let amount = Int(packet.amount)

        if var item = items[index] {
            item.amount += amount
            items[index] = item
        } else {
            var item = InventoryItem()
            item.index = index
            item.itemID = Int(packet.itemId)
            item.type = ItemType(rawValue: Int(packet.itemType)) ?? .etc
            item.amount = amount
            item.slots = packet.slot.card.map(Int.init)
            items[index] = item
        }
    }

    public mutating func update(from packet: PACKET_ZC_DELETE_ITEM_FROM_STORE) {
        let index = Int(packet.index)
        let amount = Int(packet.amount)
        guard amount > 0, var item = items[index] else {
            return
        }

        item.amount -= amount
        if item.amount > 0 {
            items[index] = item
        } else {
            items.removeValue(forKey: index)
        }
    }
}
