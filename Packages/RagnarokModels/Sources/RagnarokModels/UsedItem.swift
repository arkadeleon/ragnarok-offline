//
//  UsedItem.swift
//  RagnarokModels
//
//  Created by Leon Li on 2025/6/30.
//

import RagnarokPackets

public struct UsedItem: Sendable {
    public let index: Int
    public let itemID: Int
    public let amount: Int

    public init(from packet: PACKET_ZC_USE_ITEM_ACK) {
        self.index = Int(packet.index)
        self.itemID = Int(packet.itemId)
        self.amount = Int(packet.amount)
    }
}
