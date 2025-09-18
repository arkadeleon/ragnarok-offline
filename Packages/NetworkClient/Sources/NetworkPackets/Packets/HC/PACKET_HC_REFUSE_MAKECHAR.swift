//
//  PACKET_HC_REFUSE_MAKECHAR.swift
//  NetworkPackets
//
//  Created by Leon Li on 2024/4/8.
//

import BinaryIO

/// See `chclif_parse_createnewchar`
public struct PACKET_HC_REFUSE_MAKECHAR: DecodablePacket, Sendable {
    public static var packetType: Int16 {
        0x6e
    }

    public var packetLength: Int16 {
        2 + 1
    }

    public var errorCode: UInt8

    public init(from decoder: BinaryDecoder) throws {
        try decoder.decodePacketType(Self.self)

        errorCode = try decoder.decode(UInt8.self)
    }
}
