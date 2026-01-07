//
//  PACKET_CZ_REQUEST_MOVE.swift
//  RagnarokPackets
//
//  Created by Leon Li on 2024/8/23.
//

import BinaryIO

let ENTRY_CZ_REQUEST_MOVE = packetDatabase.entry(forFunctionName: "clif_parse_WalkToXY")!

public struct PACKET_CZ_REQUEST_MOVE: EncodablePacket {
    public let packetType: Int16
    public var x: Int16
    public var y: Int16

    public init() {
        packetType = ENTRY_CZ_REQUEST_MOVE.packetType
        x = 0
        y = 0
    }

    public func encode(to encoder: BinaryEncoder) throws {
        let packetLength = ENTRY_CZ_REQUEST_MOVE.packetLength
        let offsets = ENTRY_CZ_REQUEST_MOVE.offsets

        var data = [UInt8](repeating: 0, count: Int(packetLength))
        data.replaceSubrange(from: 0, with: packetType)
        data.replaceSubrange(from: offsets[0], with: [
            UInt8(x >> 2),
            UInt8((x % 4) << 6) | UInt8(y >> 4),
            UInt8((y % 16) << 4),
        ])

        try encoder.encode(data)
    }
}
