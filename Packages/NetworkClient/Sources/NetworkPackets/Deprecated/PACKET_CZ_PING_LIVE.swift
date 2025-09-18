//
//  PACKET_CZ_PING_LIVE.swift
//  NetworkPackets
//
//  Created by Leon Li on 2024/8/23.
//

import BinaryIO

/// See `clif_ping`
@available(*, deprecated, message: "Use generated struct instead.")
public struct _PACKET_CZ_PING_LIVE: EncodablePacket {
    public var packetType: Int16 {
        0xb1c
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
