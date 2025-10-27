//
//  UnequippedItem.swift
//  NetworkClient
//
//  Created by Leon Li on 2025/6/30.
//

import RagnarokConstants
import NetworkPackets

public struct UnequippedItem: Sendable {
    public let index: Int
    public let location: EquipPositions

    init(packet: PACKET_ZC_REQ_TAKEOFF_EQUIP_ACK) {
        self.index = Int(packet.index)
        self.location = EquipPositions(rawValue: Int(packet.wearLocation))
    }
}
