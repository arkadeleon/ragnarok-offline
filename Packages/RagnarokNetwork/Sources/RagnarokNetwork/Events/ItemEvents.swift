//
//  ItemEvents.swift
//  RagnarokNetwork
//
//  Created by Leon Li on 2025/4/1.
//

public enum ItemEvents {
    public struct ListReceived: Event {
        public let inventory: Inventory
    }

    public struct ListUpdated: Event {
        public let inventory: Inventory
    }

    public struct Spawned: Event {
        public let item: MapItem
        public let position: SIMD2<Int>
    }

    public struct Vanished: Event {
        public let objectID: UInt32
    }

    public struct PickedUp: Event {
        public let item: PickedUpItem
    }

    public struct Thrown: Event {
        public let item: ThrownItem
    }

    public struct Used: Event {
        public let item: UsedItem
        public let accountID: UInt32
        public let success: Bool
    }

    public struct Equipped: Event {
        public let item: EquippedItem
        public let success: Bool
    }

    public struct Unequipped: Event {
        public let item: UnequippedItem
        public let success: Bool
    }
}
