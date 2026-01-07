//
//  PACKET_CA_CONNECT_INFO_CHANGED.swift
//  RagnarokPackets
//
//  Created by Leon Li on 2024/4/8.
//

import BinaryIO

/// See `logclif_parse_keepalive`
@available(*, deprecated, message: "Use generated struct instead.")
public struct _PACKET_CA_CONNECT_INFO_CHANGED: _EncodablePacket {
    public var packetType: Int16 {
        0x200
    }

    public var packetLength: Int16 {
        2 + 24
    }

    public var name: String

    public init() {
        name = ""
    }

    public func encode(to encoder: BinaryEncoder) throws {
        try encoder.encode(packetType)
        try encoder.encode(name, lengthOfBytes: 24)
    }
}
