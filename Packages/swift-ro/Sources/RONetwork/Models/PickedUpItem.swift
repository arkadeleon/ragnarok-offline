//
//  PickedUpItem.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2025/4/15.
//

import Constants
import ROPackets

public struct PickedUpItem: Sendable {
    public let index: Int
    public let count: Int
    public let itemID: Int
    public let isIdentified: Bool
    public let isDamaged: Bool
    public let slots: [Int]
    public let location: EquipPositions
    public let itemType: ItemType

    init(packet: PACKET_ZC_ITEM_PICKUP_ACK) {
        self.index = Int(packet.Index)
        self.count = Int(packet.count)
        self.itemID = Int(packet.nameid)
        self.isIdentified = (packet.IsIdentified != 0)
        self.isDamaged = (packet.IsDamaged != 0)
        self.slots = packet.slot.card.map(Int.init)
        self.location = EquipPositions(rawValue: Int(packet.location))
        self.itemType = ItemType(rawValue: Int(packet.type)) ?? .etc
    }
}
