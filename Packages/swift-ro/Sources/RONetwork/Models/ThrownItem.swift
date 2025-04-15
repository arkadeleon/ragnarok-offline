//
//  ThrownItem.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2025/4/15.
//

import ROPackets

public struct ThrownItem: Sendable {
    public var index: Int
    public var count: Int

    init(packet: PACKET_ZC_ITEM_THROW_ACK) {
        index = Int(packet.index)
        count = Int(packet.count)
    }
}
