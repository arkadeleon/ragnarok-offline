//
//  PACKET_CZ_PING.swift
//  RagnarokPackets
//
//  Created by Leon Li on 2024/4/8.
//

import BinaryIO

public let HEADER_CZ_PING: Int16 = 0x187

/// See `chclif_parse_keepalive`
public struct PACKET_CZ_PING: BinaryEncodable, Sendable {
    public var packetType: Int16 = 0
    public var accountID: UInt32 = 0

    public init() {
    }

    public func encode(to encoder: BinaryEncoder) throws {
        try encoder.encode(packetType)
        try encoder.encode(accountID)
    }
}
