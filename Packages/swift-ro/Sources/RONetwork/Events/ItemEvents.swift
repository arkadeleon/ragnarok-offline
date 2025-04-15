//
//  ItemEvents.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2025/4/1.
//

import ROConstants
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
}

extension ItemEvents {
    public struct Thrown: Event {
        public struct Item: Sendable {
            public let index: Int
            public let amount: Int

            public init(index: Int, amount: Int) {
                self.index = index
                self.amount = amount
            }
        }

        public let item: ItemEvents.Thrown.Item

        init(packet: PACKET_ZC_ITEM_THROW_ACK) {
            self.item = ItemEvents.Thrown.Item(
                index: Int(packet.index),
                amount: Int(packet.count)
            )
        }
    }
}

extension ItemEvents {
    public struct Used: Event {
        public struct Item: Sendable {
            public let index: Int
            public let itemID: Int
            public let amount: Int

            public init(index: Int, itemID: Int, amount: Int) {
                self.index = index
                self.itemID = itemID
                self.amount = amount
            }
        }

        public let item: ItemEvents.Used.Item
        public let accountID: UInt32
        public let success: Bool

        init(packet: PACKET_ZC_USE_ITEM_ACK) {
            self.item = ItemEvents.Used.Item(
                index: Int(packet.index),
                itemID: Int(packet.itemId),
                amount: Int(packet.amount)
            )
            self.accountID = packet.AID
            self.success = (packet.result != 0)
        }
    }
}

extension ItemEvents {
    public struct Equipped: Event {
        public struct Item: Sendable {
            public let index: Int
            public let location: EquipPositions
            public let view: Int

            init(index: Int, location: Int, view: Int) {
                self.index = index
                self.location = EquipPositions(rawValue: location)
                self.view = view
            }
        }

        public let item: ItemEvents.Equipped.Item
        public let success: Bool

        init(packet: PACKET_ZC_REQ_WEAR_EQUIP_ACK) {
            self.item = ItemEvents.Equipped.Item(
                index: Int(packet.index),
                location: Int(packet.wearLocation),
                view: Int(packet.wItemSpriteNumber)
            )
            self.success = (packet.result != 0)
        }
    }
}

extension ItemEvents {
    public struct Unequipped: Event {
        public struct Item: Sendable {
            public let index: Int
            public let location: EquipPositions

            init(index: Int, location: Int) {
                self.index = index
                self.location = EquipPositions(rawValue: location)
            }
        }

        public let item: ItemEvents.Unequipped.Item
        public let success: Bool

        init(packet: PACKET_ZC_REQ_TAKEOFF_EQUIP_ACK) {
            self.item = ItemEvents.Unequipped.Item(
                index: Int(packet.index),
                location: Int(packet.wearLocation)
            )
            self.success = (packet.flag != 0)
        }
    }
}
