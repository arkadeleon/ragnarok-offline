//
//  EquippedItem.swift
//  RagnarokModels
//
//  Created by Leon Li on 2025/6/30.
//

import RagnarokConstants
import RagnarokPackets

public struct EquippedItem: Sendable {
    public let index: Int
    public let location: EquipPositions
    public let view: Int

    public init(from packet: PACKET_ZC_REQ_WEAR_EQUIP_ACK) {
        self.index = Int(packet.index)
        self.location = EquipPositions(rawValue: Int(packet.wearLocation))
        self.view = Int(packet.wItemSpriteNumber)
    }
}
