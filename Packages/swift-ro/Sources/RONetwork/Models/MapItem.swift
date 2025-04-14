//
//  MapItem.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2025/4/2.
//

import ROPackets

/// Represents an item dropped on a map.
public struct MapItem: Sendable {
    public let objectID: UInt32
    public let itemID: UInt32
    public let position: SIMD2<Int16>

    init(packet: PACKET_ZC_ITEM_ENTRY) {
        self.objectID = packet.AID
        self.itemID = packet.itemId
        self.position = [Int16(packet.x), Int16(packet.y)]
    }

    init(packet: packet_dropflooritem) {
        self.objectID = packet.ITAID
        self.itemID = packet.ITID
        self.position = [packet.xPos, packet.yPos]
    }
}
