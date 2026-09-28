//
//  PACKET_CZ_MOVE_ITEM_FROM_STORE_TO_BODY.swift
//  RagnarokPackets
//
//  Created by Leon Li on 2026/9/26.
//

import BinaryIO

let ENTRY_CZ_MOVE_ITEM_FROM_STORE_TO_BODY = packetDatabase.entry(forFunctionName: "clif_parse_MoveFromKafra")!

public struct PACKET_CZ_MOVE_ITEM_FROM_STORE_TO_BODY: EncodablePacket {
    public let packetType: Int16
    public var index: UInt16
    public var amount: Int32

    public init() {
        packetType = ENTRY_CZ_MOVE_ITEM_FROM_STORE_TO_BODY.packetType
        index = 0
        amount = 0
    }

    public func encode(to encoder: BinaryEncoder) throws {
        let packetLength = ENTRY_CZ_MOVE_ITEM_FROM_STORE_TO_BODY.packetLength
        let offsets = ENTRY_CZ_MOVE_ITEM_FROM_STORE_TO_BODY.offsets

        var data = [UInt8](repeating: 0, count: Int(packetLength))
        data.replaceSubrange(from: 0, with: packetType)
        data.replaceSubrange(from: offsets[0], with: index)
        data.replaceSubrange(from: offsets[1], with: amount)

        try encoder.encode(data)
    }
}
