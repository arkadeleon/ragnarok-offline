//
//  MapSession+Item.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2025/4/2.
//

import ROConstants
import ROPackets

extension MapSession {
    func subscribeToItemPackets(with subscription: inout ClientSubscription) {
        // See `clif_inventoryStart`
        subscription.subscribe(to: PACKET_ZC_INVENTORY_START.self) { [unowned self] packet in
            self.inventory = Inventory()
        }

        // See `clif_inventorylist`
        subscription.subscribe(to: packet_itemlist_normal.self) { [unowned self] packet in
            self.inventory.stackableItems = packet.list.map(Inventory.StackableItem.init)
        }

        // See `clif_inventorylist`
        subscription.subscribe(to: packet_itemlist_equip.self) { [unowned self] packet in
            self.inventory.equippableItems = packet.list.map(Inventory.EquippableItem.init)
        }

        // See `clif_inventoryEnd`
        subscription.subscribe(to: PACKET_ZC_INVENTORY_END.self) { [unowned self] packet in
            let event = ItemEvents.Listed(inventory: self.inventory)
            self.postEvent(event)
        }

        // See `clif_getareachar_item`
        subscription.subscribe(to: PACKET_ZC_ITEM_ENTRY.self) { [unowned self] packet in
            let event = ItemEvents.Spawned(packet: packet)
            self.postEvent(event)
        }

        // See `clif_dropflooritem`
        subscription.subscribe(to: packet_dropflooritem.self) { [unowned self] packet in
            let event = ItemEvents.Spawned(packet: packet)
            self.postEvent(event)
        }

        // See `clif_clearflooritem`
        subscription.subscribe(to: PACKET_ZC_ITEM_DISAPPEAR.self) { [unowned self] packet in
            let event = ItemEvents.Vanished(packet: packet)
            self.postEvent(event)
        }

        // See `clif_additem`
        subscription.subscribe(to: PACKET_ZC_ITEM_PICKUP_ACK.self) { [unowned self] packet in
            let event = ItemEvents.PickedUp(packet: packet)
            self.postEvent(event)
        }

        // See `clif_dropitem`
        subscription.subscribe(to: PACKET_ZC_ITEM_THROW_ACK.self) { [unowned self] packet in
            let event = ItemEvents.Thrown(packet: packet)
            self.postEvent(event)
        }

        // See `clif_useitemack`
        subscription.subscribe(to: PACKET_ZC_USE_ITEM_ACK.self) { [unowned self] packet in
            let event = ItemEvents.Used(packet: packet)
            self.postEvent(event)
        }

        // See `clif_equipitemack`
        subscription.subscribe(to: PACKET_ZC_REQ_WEAR_EQUIP_ACK.self) { [unowned self] packet in
            let event = ItemEvents.Equipped(packet: packet)
            self.postEvent(event)
        }

        // See `clif_unequipitemack`
        subscription.subscribe(to: PACKET_ZC_REQ_TAKEOFF_EQUIP_ACK.self) { [unowned self] packet in
            let event = ItemEvents.Unequipped(packet: packet)
            self.postEvent(event)
        }
    }

    // See `clif_parse_TakeItem`
    public func pickUpItem(objectID: UInt32) {
        var packet = PACKET_CZ_ITEM_PICKUP()
        packet.objectID = objectID

        client.sendPacket(packet)
    }

    // See `clif_parse_DropItem`
    public func throwItem(at index: Int, amount: Int) {
        var packet = PACKET_CZ_ITEM_THROW()
        packet.index = UInt16(index)
        packet.amount = Int16(amount)

        client.sendPacket(packet)
    }

    // See `clif_parse_UseItem`
    public func useItem(at index: Int, by accountID: UInt32) {
        var packet = PACKET_CZ_USE_ITEM()
        packet.index = UInt16(index)
        packet.accountID = accountID

        client.sendPacket(packet)
    }

    // See `clif_parse_EquipItem`
    public func equipItem(at index: Int, location: EquipPositions) {
        var packet = PACKET_CZ_REQ_WEAR_EQUIP()
        packet.packetType = HEADER_CZ_REQ_WEAR_EQUIP
        packet.index = UInt16(index)
        packet.position = UInt32(location.rawValue)

        client.sendPacket(packet)
    }

    // See `clif_parse_UnequipItem`
    public func unequipItem(at index: Int) {
        var packet = PACKET_CZ_REQ_TAKEOFF_EQUIP()
        packet.index = UInt16(index)

        client.sendPacket(packet)
    }
}
