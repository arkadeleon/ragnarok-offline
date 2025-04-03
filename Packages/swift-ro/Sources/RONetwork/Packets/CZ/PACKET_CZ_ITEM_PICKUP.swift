//
//  PACKET_CZ_ITEM_PICKUP.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2025/4/2.
//

import ROCore

public struct PACKET_CZ_ITEM_PICKUP: BinaryEncodable {
    public var packetType: Int16
    public var itemAID: UInt32

    public init() {
        packetType = PacketDatabase.Entry.CZ_ITEM_PICKUP.packetType
        itemAID = 0
    }

    public func encode(to encoder: BinaryEncoder) throws {
        let packetLength = PacketDatabase.Entry.CZ_ITEM_PICKUP.packetLength
        let offsets = PacketDatabase.Entry.CZ_ITEM_PICKUP.offsets

        var data = [UInt8](repeating: 0, count: Int(packetLength))
        data.replaceSubrange(from: 0, with: packetType)
        data.replaceSubrange(from: offsets[0], with: itemAID)

        try encoder.encode(data)
    }
}

extension PacketDatabase.Entry {
    public static let CZ_ITEM_PICKUP = packetDatabase.entry(forFunctionName: "clif_parse_TakeItem")!
}
