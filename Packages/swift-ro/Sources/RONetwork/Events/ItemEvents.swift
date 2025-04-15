//
//  ItemEvents.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2025/4/1.
//

import ROPackets

public enum ItemEvents {
    public struct Listed: Event {
        public let inventory: Inventory

        init(inventory: Inventory) {
            self.inventory = inventory
        }
    }

    public struct Spawned: Event {
        public let item: MapItem

        init(packet: PACKET_ZC_ITEM_ENTRY) {
            self.item = MapItem(packet: packet)
        }

        init(packet: packet_dropflooritem) {
            self.item = MapItem(packet: packet)
        }
    }

    public struct Vanished: Event {
        public let objectID: UInt32

        init(packet: PACKET_ZC_ITEM_DISAPPEAR) {
            self.objectID = packet.itemAid
        }
    }

    public struct PickedUp: Event {
        public let item: PickedUpItem

        init(packet: PACKET_ZC_ITEM_PICKUP_ACK) {
            self.item = PickedUpItem(packet: packet)
        }
    }

    public struct Thrown: Event {
        public let item: ThrownItem

        init(packet: PACKET_ZC_ITEM_THROW_ACK) {
            self.item = ThrownItem(packet: packet)
        }
    }
}
