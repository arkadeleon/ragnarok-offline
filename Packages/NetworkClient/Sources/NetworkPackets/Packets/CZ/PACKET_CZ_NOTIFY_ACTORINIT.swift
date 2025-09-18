//
//  PACKET_CZ_NOTIFY_ACTORINIT.swift
//  NetworkPackets
//
//  Created by Leon Li on 2024/8/23.
//

import BinaryIO

/// See `clif_parse_LoadEndAck`
public struct PACKET_CZ_NOTIFY_ACTORINIT: EncodablePacket {
    public var packetType: Int16 {
        0x7d
    }

    public var packetLength: Int16 {
        2
    }

    public init() {
    }

    public func encode(to encoder: BinaryEncoder) throws {
        try encoder.encode(packetType)
    }
}
