//
//  MapItem.swift
//  RagnarokModels
//
//  Created by Leon Li on 2025/4/2.
//

import RagnarokPackets

/// Represents an item dropped on a map.
public struct MapItem: Sendable {
    public let objectID: UInt32
    public let itemID: UInt32

    public init(from packet: PACKET_ZC_ITEM_ENTRY) {
        self.objectID = packet.AID
        self.itemID = packet.itemId
    }

    public init(from packet: packet_dropflooritem) {
        self.objectID = packet.ITAID
        self.itemID = packet.ITID
    }
}
