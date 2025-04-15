//
//  MapSession+Item.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2025/4/2.
//

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
    }

    public func pickUpItem(objectID: UInt32) {
        var packet = PACKET_CZ_ITEM_PICKUP()
        packet.itemAID = objectID

        client.sendPacket(packet)
    }
}
