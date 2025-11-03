//
//  PACKET_CZ_USE_ITEM.swift
//  RagnarokPackets
//
//  Created by Leon Li on 2025/4/15.
//

import BinaryIO

let ENTRY_CZ_USE_ITEM = packetDatabase.entry(forFunctionName: "clif_parse_UseItem")!

public struct PACKET_CZ_USE_ITEM: BinaryEncodable, Sendable {
    public let packetType: Int16
    public var index: UInt16
    public var accountID: UInt32

    public init() {
        packetType = ENTRY_CZ_USE_ITEM.packetType
        index = 0
        accountID = 0
    }

    public func encode(to encoder: BinaryEncoder) throws {
        let packetLength = ENTRY_CZ_USE_ITEM.packetLength
        let offsets = ENTRY_CZ_USE_ITEM.offsets

        var data = [UInt8](repeating: 0, count: Int(packetLength))
        data.replaceSubrange(from: 0, with: packetType)
        data.replaceSubrange(from: offsets[0], with: index)
        data.replaceSubrange(from: offsets[1], with: accountID)

        try encoder.encode(data)
    }
}
