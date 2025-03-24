//
//  PACKET_ZC_SPRITE_CHANGE.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/8/28.
//

import ROCore

/// See `clif_sprite_change`
@available(*, deprecated, message: "Use generated struct instead.")
public struct _PACKET_ZC_SPRITE_CHANGE: DecodablePacket {
    public static var packetType: Int16 {
        if PACKET_VERSION >= 4 {
            0x1d7
        } else {
            0xc3
        }
    }

    public var packetLength: Int16 {
        if PACKET_VERSION_MAIN_NUMBER >= 20181121 || PACKET_VERSION_RE_NUMBER >= 20180704 || PACKET_VERSION_ZERO_NUMBER >= 20181114 {
            2 + 4 + 1 + 4 + 4
        } else if PACKET_VERSION >= 4 {
            2 + 4 + 1 + 2 + 2
        } else {
            2 + 4 + 1 + 1
        }
    }

    public var accountID: UInt32
    public var type: UInt8
    public var value: UInt32
    public var value2: UInt32

    public init(from decoder: BinaryDecoder) throws {
        try decoder.decodePacketType(Self.self)

        accountID = try decoder.decode(UInt32.self)
        type = try decoder.decode(UInt8.self)

        if PACKET_VERSION_MAIN_NUMBER >= 20181121 || PACKET_VERSION_RE_NUMBER >= 20180704 || PACKET_VERSION_ZERO_NUMBER >= 20181114 {
            value = try decoder.decode(UInt32.self)
            value2 = try decoder.decode(UInt32.self)
        } else if PACKET_VERSION >= 4 {
            value = UInt32(try decoder.decode(UInt16.self))
            value2 = UInt32(try decoder.decode(UInt16.self))
        } else {
            value = UInt32(try decoder.decode(UInt8.self))
            value2 = 0
        }
    }
}
