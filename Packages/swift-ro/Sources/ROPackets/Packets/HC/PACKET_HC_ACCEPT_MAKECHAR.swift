//
//  PACKET_HC_ACCEPT_MAKECHAR.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/4/8.
//

import ROCore

/// See `chclif_parse_createnewchar`
public struct PACKET_HC_ACCEPT_MAKECHAR: DecodablePacket, Sendable {
    public static var packetType: Int16 {
        if PACKET_VERSION_MAIN_NUMBER >= 20201007 || PACKET_VERSION_RE_NUMBER >= 20211103 {
            0xb6f
        } else {
            0x6d
        }
    }

    public var packetLength: Int16 {
        2 + CharInfo.decodedLength
    }

    public var char: CharInfo

    public init(from decoder: BinaryDecoder) throws {
        try decoder.decodePacketType(Self.self)

        char = try decoder.decode(CharInfo.self)
    }
}
