//
//  PACKET_CZ_PING.swift
//  RagnarokPackets
//
//  Created by Leon Li on 2024/4/8.
//

import BinaryIO

@available(*, deprecated, message: "Use HEADER_PING instead.")
public let _HEADER_CZ_PING: Int16 = 0x187

/// See `chclif_parse_keepalive`
@available(*, deprecated, message: "Use PACKET_PING instead.")
public struct _PACKET_CZ_PING: EncodablePacket {
    public var packetType: Int16 = 0
    public var accountID: UInt32 = 0

    public init() {
    }

    public func encode(to encoder: BinaryEncoder) throws {
        try encoder.encode(packetType)
        try encoder.encode(accountID)
    }
}
