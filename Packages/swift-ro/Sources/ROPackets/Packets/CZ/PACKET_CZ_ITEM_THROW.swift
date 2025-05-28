//
//  PACKET_CZ_ITEM_THROW.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2025/4/15.
//

import BinaryIO

let ENTRY_CZ_ITEM_THROW = packetDatabase.entry(forFunctionName: "clif_parse_DropItem")!

public struct PACKET_CZ_ITEM_THROW: BinaryEncodable {
    public let packetType: Int16
    public var index: UInt16
    public var amount: Int16

    public init() {
        packetType = ENTRY_CZ_ITEM_THROW.packetType
        index = 0
        amount = 0
    }

    public func encode(to encoder: BinaryEncoder) throws {
        let packetLength = ENTRY_CZ_ITEM_THROW.packetLength
        let offsets = ENTRY_CZ_ITEM_THROW.offsets

        var data = [UInt8](repeating: 0, count: Int(packetLength))
        data.replaceSubrange(from: 0, with: packetType)
        data.replaceSubrange(from: offsets[0], with: index)
        data.replaceSubrange(from: offsets[1], with: amount)

        try encoder.encode(data)
    }
}
