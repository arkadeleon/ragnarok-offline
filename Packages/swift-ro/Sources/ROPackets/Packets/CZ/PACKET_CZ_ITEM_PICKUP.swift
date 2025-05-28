//
//  PACKET_CZ_ITEM_PICKUP.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2025/4/2.
//

import BinaryIO

let ENTRY_CZ_ITEM_PICKUP = packetDatabase.entry(forFunctionName: "clif_parse_TakeItem")!

public struct PACKET_CZ_ITEM_PICKUP: BinaryEncodable {
    public let packetType: Int16
    public var objectID: UInt32

    public init() {
        packetType = ENTRY_CZ_ITEM_PICKUP.packetType
        objectID = 0
    }

    public func encode(to encoder: BinaryEncoder) throws {
        let packetLength = ENTRY_CZ_ITEM_PICKUP.packetLength
        let offsets = ENTRY_CZ_ITEM_PICKUP.offsets

        var data = [UInt8](repeating: 0, count: Int(packetLength))
        data.replaceSubrange(from: 0, with: packetType)
        data.replaceSubrange(from: offsets[0], with: objectID)

        try encoder.encode(data)
    }
}
