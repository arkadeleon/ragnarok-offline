//
//  PACKET_CZ_NOTIFY_ACTORINIT.swift
//  RagnarokPackets
//
//  Created by Leon Li on 2024/8/23.
//

import BinaryIO

public let HEADER_CZ_NOTIFY_ACTORINIT: Int16 = 0x7d

/// See `clif_parse_LoadEndAck`
public struct PACKET_CZ_NOTIFY_ACTORINIT: BinaryEncodable, Sendable {
    public var packetType: Int16 = 0

    public init() {
    }

    public func encode(to encoder: BinaryEncoder) throws {
        try encoder.encode(packetType)
    }
}
