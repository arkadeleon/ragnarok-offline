//
//  PACKET_HC_CHARLIST_NOTIFY.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/8/12.
//

/// See `chclif_charlist_notify`
public struct PACKET_HC_CHARLIST_NOTIFY: DecodablePacket {
    public static var packetType: UInt16 {
        0x9a0
    }

    public var packetLength: UInt16 {
        if PACKET_VERSION_RE && PACKET_VERSION >= 20151001 && PACKET_VERSION < 20180103 {
            10
        } else {
            6
        }
    }

    public var totalCnt: UInt32
    public var charSlots: UInt32

    public init(from decoder: BinaryDecoder) throws {
        try decoder.decodePacketType(Self.self)

        totalCnt = try decoder.decode(UInt32.self)

        if PACKET_VERSION_RE && PACKET_VERSION >= 20151001 && PACKET_VERSION < 20180103 {
            charSlots = try decoder.decode(UInt32.self)
        } else {
            charSlots = 0
        }
    }
}
