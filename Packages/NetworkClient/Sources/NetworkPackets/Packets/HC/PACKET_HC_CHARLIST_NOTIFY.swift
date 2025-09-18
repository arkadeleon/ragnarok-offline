//
//  PACKET_HC_CHARLIST_NOTIFY.swift
//  NetworkPackets
//
//  Created by Leon Li on 2024/8/12.
//

import BinaryIO

/// See `chclif_charlist_notify`
public struct PACKET_HC_CHARLIST_NOTIFY: DecodablePacket, Sendable {
    public static var packetType: Int16 {
        0x9a0
    }

    public var packetLength: Int16 {
        if PACKET_VERSION_RE && PACKET_VERSION >= 20151001 && PACKET_VERSION < 20180103 {
            2 + 4 + 4
        } else {
            2 + 4
        }
    }

    public var totalCount: UInt32
    public var charSlots: UInt32

    public init(from decoder: BinaryDecoder) throws {
        try decoder.decodePacketType(Self.self)

        totalCount = try decoder.decode(UInt32.self)

        if PACKET_VERSION_RE && PACKET_VERSION >= 20151001 && PACKET_VERSION < 20180103 {
            charSlots = try decoder.decode(UInt32.self)
        } else {
            charSlots = 0
        }
    }
}
