//
//  ItemEvents.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2025/4/1.
//

import ROConstants
import ROPackets

public enum ItemEvents {
    public struct ListReceived: Event {
        public let inventory: Inventory

        init(inventory: Inventory) {
            self.inventory = inventory
        }
    }

    public struct ListUpdated: Event {
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
}

extension ItemEvents {
    public struct Thrown: Event {
        public let index: Int
        public let amount: Int

        init(packet: PACKET_ZC_ITEM_THROW_ACK) {
            self.index = Int(packet.index)
            self.amount = Int(packet.count)
        }
    }
}

extension ItemEvents {
    public struct Used: Event {
        public let index: Int
        public let itemID: Int
        public let amount: Int
        public let accountID: UInt32
        public let success: Bool

        init(packet: PACKET_ZC_USE_ITEM_ACK) {
            self.index = Int(packet.index)
            self.itemID = Int(packet.itemId)
            self.amount = Int(packet.amount)
            self.accountID = packet.AID
            self.success = (packet.result != 0)
        }
    }
}

extension ItemEvents {
    public struct Equipped: Event {
        public let index: Int
        public let location: EquipPositions
        public let view: Int
        public let success: Bool

        init(packet: PACKET_ZC_REQ_WEAR_EQUIP_ACK) {
            self.index = Int(packet.index)
            self.location = EquipPositions(rawValue: Int(packet.wearLocation))
            self.view = Int(packet.wItemSpriteNumber)
            self.success = (packet.result != 0)
        }
    }
}

extension ItemEvents {
    public struct Unequipped: Event {
        public let index: Int
        public let location: EquipPositions
        public let success: Bool

        init(packet: PACKET_ZC_REQ_TAKEOFF_EQUIP_ACK) {
            self.index = Int(packet.index)
            self.location = EquipPositions(rawValue: Int(packet.wearLocation))
            self.success = (packet.flag != 0)
        }
    }
}
