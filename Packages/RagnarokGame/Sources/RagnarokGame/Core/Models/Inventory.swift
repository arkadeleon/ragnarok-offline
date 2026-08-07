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

    var equipItems: [InventoryItem] {
        let equipItems = items.values.filter({ $0.isEquippable && !$0.isEquipped })
        return equipItems.sorted()
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

    func append(item: InventoryItem) {
        items[item.index] = item
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

    func update(from packet: PACKET_ZC_ITEM_PICKUP_ACK) {
        guard packet.result == 0 else {
            return
        }

        let index = Int(packet.Index)
        let amount = Int(packet.count)

        if var item = items[index] {
            item.amount += amount
            items[index] = item
        } else {
            var item = InventoryItem()
            item.index = index
            item.itemID = Int(packet.nameid)
            item.type = ItemType(rawValue: Int(packet.type)) ?? .etc
            item.amount = amount
            item.location = EquipPositions(rawValue: Int(packet.location))
            item.slots = packet.slot.card.map(Int.init)
            items[index] = item
        }
    }

    func update(from packet: PACKET_ZC_USE_ITEM_ACK) {
        let usedItem = UsedItem(from: packet)
        if var item = items[usedItem.index] {
            item.amount = usedItem.amount
            items[usedItem.index] = item
        }
    }

    func update(from packet: PACKET_ZC_REQ_WEAR_EQUIP_ACK) {
        guard let flag = ItemEquipAcknowledgeFlag(rawValue: Int(packet.result)), flag == .ok else {
            return
        }

        let index = Int(packet.index)
        let location = EquipPositions(rawValue: Int(packet.wearLocation))
        items[index]?.equippedLocation = location
    }

    func update(from packet: PACKET_ZC_REQ_TAKEOFF_EQUIP_ACK) {
        guard let flag = ItemEquipAcknowledgeFlag(rawValue: Int(packet.flag)), flag == .ok else {
            return
        }

        let index = Int(packet.index)
        items[index]?.equippedLocation = EquipPositions(rawValue: 0)
    }

    func update(from packet: PACKET_ZC_ITEM_THROW_ACK) {
        let index = Int(packet.index)
        let amount = Int(packet.count)
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

    func update(from packet: PACKET_ZC_EQUIP_ARROW) {
        for key in items.keys where items[key]?.equippedLocation == .ammo {
            items[key]?.equippedLocation = EquipPositions(rawValue: 0)
        }

        let index = Int(packet.index)
        items[index]?.equippedLocation = .ammo
    }
}
