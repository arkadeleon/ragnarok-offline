//
//  PACKET_HC_ACCEPT_DELETECHAR.swift
//  NetworkPackets
//
//  Created by Leon Li on 2024/4/8.
//

import BinaryIO

/// See `chclif_parse_delchar`
public struct PACKET_HC_ACCEPT_DELETECHAR: DecodablePacket, Sendable {
    public static var packetType: Int16 {
        0x6f
    }

    public var packetLength: Int16 {
        2
    }

    public init(from decoder: BinaryDecoder) throws {
        try decoder.decodePacketType(Self.self)
    }
}
