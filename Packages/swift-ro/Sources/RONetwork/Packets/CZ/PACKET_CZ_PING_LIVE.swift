//
//  PACKET_CZ_PING_LIVE.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/8/23.
//

/// See `clif_ping`
public struct PACKET_CZ_PING_LIVE: EncodablePacket {
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
