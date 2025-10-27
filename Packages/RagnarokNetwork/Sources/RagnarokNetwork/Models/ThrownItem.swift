//
//  ThrownItem.swift
//  RagnarokNetwork
//
//  Created by Leon Li on 2025/6/30.
//

import RagnarokPackets

public struct ThrownItem: Sendable {
    public let index: Int
    public let amount: Int

    init(packet: PACKET_ZC_ITEM_THROW_ACK) {
        self.index = Int(packet.index)
        self.amount = Int(packet.count)
    }
}
