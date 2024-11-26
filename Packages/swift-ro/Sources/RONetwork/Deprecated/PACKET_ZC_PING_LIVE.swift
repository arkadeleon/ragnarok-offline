//
//  PACKET_ZC_PING_LIVE.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/8/23.
//

import ROCore

/// See `clif_ping`
public struct _PACKET_ZC_PING_LIVE: DecodablePacket {
    public static var packetType: Int16 {
        0xb1d
    }

    public var packetLength: Int16 {
        2
    }

    public init(from decoder: BinaryDecoder) throws {
        try decoder.decodePacketType(Self.self)
    }
}
