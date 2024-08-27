//
//  PACKET_CZ_PING.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/4/8.
//

/// See `chclif_parse_keepalive`
public struct PACKET_CZ_PING: EncodablePacket {
    public var packetType: Int16 {
        0x187
    }

    public var packetLength: Int16 {
        2 + 4
    }

    public var accountID: UInt32

    public init() {
        accountID = 0
    }

    public func encode(to encoder: BinaryEncoder) throws {
        try encoder.encode(packetType)
        try encoder.encode(accountID)
    }
}
