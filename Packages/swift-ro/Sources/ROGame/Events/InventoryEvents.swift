//
//  InventoryEvents.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2025/4/10.
//

public enum InventoryEvents {
    public struct Listed: Event {
        public let inventory: Inventory

        init(inventory: Inventory) {
            self.inventory = inventory
        }
    }
}
