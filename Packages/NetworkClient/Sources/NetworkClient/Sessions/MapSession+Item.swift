//
//  MapSession+Item.swift
//  NetworkClient
//
//  Created by Leon Li on 2025/4/2.
//

import Constants
import NetworkPackets

extension MapSession {
    func subscribeToItemPackets(with subscription: inout ClientSubscription) {
        // See `clif_inventoryStart`
        subscription.subscribe(to: PACKET_ZC_INVENTORY_START.self) { [unowned self] packet in
            self.inventory = Inventory()
        }

        // See `clif_inventorylist`
        subscription.subscribe(to: packet_itemlist_normal.self) { [unowned self] packet in
            self.inventory.append(items: packet.list)
        }

        // See `clif_inventorylist`
        subscription.subscribe(to: packet_itemlist_equip.self) { [unowned self] packet in
            self.inventory.append(items: packet.list)
        }

        // See `clif_inventoryEnd`
        subscription.subscribe(to: PACKET_ZC_INVENTORY_END.self) { [unowned self] packet in
            let event = MapSession.Event.itemListReceived(inventory: self.inventory)
            self.postEvent(event)
        }

        // See `clif_getareachar_item`
        subscription.subscribe(to: PACKET_ZC_ITEM_ENTRY.self) { [unowned self] packet in
            let item = MapItem(packet: packet)
            let position = SIMD2(x: Int(packet.x), y: Int(packet.y))

            let event = MapSession.Event.itemSpawned(item: item, position: position)
            self.postEvent(event)
        }

        // See `clif_dropflooritem`
        subscription.subscribe(to: packet_dropflooritem.self) { [unowned self] packet in
            let item = MapItem(packet: packet)
            let position = SIMD2(x: Int(packet.xPos), y: Int(packet.yPos))

            let event = MapSession.Event.itemSpawned(item: item, position: position)
            self.postEvent(event)
        }

        // See `clif_clearflooritem`
        subscription.subscribe(to: PACKET_ZC_ITEM_DISAPPEAR.self) { [unowned self] packet in
            let event = MapSession.Event.itemVanished(objectID: packet.itemAid)
            self.postEvent(event)
        }

        // See `clif_additem`
        subscription.subscribe(to: PACKET_ZC_ITEM_PICKUP_ACK.self) { [unowned self] packet in
            let item = PickedUpItem(packet: packet)
            let event = MapSession.Event.itemPickedUp(item: item)
            self.postEvent(event)
        }

        // See `clif_dropitem`
        subscription.subscribe(to: PACKET_ZC_ITEM_THROW_ACK.self) { [unowned self] packet in
            let item = ThrownItem(packet: packet)
            let event = MapSession.Event.itemThrown(item: item)
            self.postEvent(event)
        }

        // See `clif_useitemack`
        subscription.subscribe(to: PACKET_ZC_USE_ITEM_ACK.self) { [unowned self] packet in
            let item = UsedItem(packet: packet)
            let event = MapSession.Event.itemUsed(
                item: item,
                accountID: packet.AID,
                success: (packet.result != 0)
            )
            self.postEvent(event)

            self.inventory.updateItem(at: Int(packet.index), amount: Int(packet.amount))

            let listUpdatedEvent = MapSession.Event.itemListUpdated(inventory: self.inventory)
            self.postEvent(listUpdatedEvent)
        }

        // See `clif_equipitemack`
        subscription.subscribe(to: PACKET_ZC_REQ_WEAR_EQUIP_ACK.self) { [unowned self] packet in
            let item = EquippedItem(packet: packet)
            let event = MapSession.Event.itemEquipped(
                item: item,
                success: (packet.result != 0)
            )
            self.postEvent(event)
        }

        // See `clif_unequipitemack`
        subscription.subscribe(to: PACKET_ZC_REQ_TAKEOFF_EQUIP_ACK.self) { [unowned self] packet in
            let item = UnequippedItem(packet: packet)
            let event = MapSession.Event.itemUnequipped(
                item: item,
                success: (packet.flag != 0)
            )
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
