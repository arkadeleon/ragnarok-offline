//
//  PickedUpItem.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2025/4/15.
//

import ROConstants
import ROPackets

public struct PickedUpItem: Sendable {
    public var index: Int
    public var count: Int
    public var itemID: Int
    public var isIdentified: Bool
    public var isDamaged: Bool
    public var slots: [Int]
    public var location: EquipPositions
    public var itemType: ItemType

    init(packet: PACKET_ZC_ITEM_PICKUP_ACK) {
        index = Int(packet.Index)
        count = Int(packet.count)
        itemID = Int(packet.nameid)
        isIdentified = (packet.IsIdentified != 0)
        isDamaged = (packet.IsDamaged != 0)
        slots = packet.slot.card.map(Int.init)
        location = EquipPositions(rawValue: Int(packet.location))
        itemType = ItemType(rawValue: Int(packet.type)) ?? .etc
    }
}
