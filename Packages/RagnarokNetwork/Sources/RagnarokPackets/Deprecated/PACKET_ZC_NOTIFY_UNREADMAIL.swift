//
//  PACKET_ZC_NOTIFY_UNREADMAIL.swift
//  RagnarokPackets
//
//  Created by Leon Li on 2024/8/28.
//

import BinaryIO

/// See `clif_Mail_new`
@available(*, deprecated, message: "Use generated struct instead.")
public struct _PACKET_ZC_NOTIFY_UNREADMAIL: _DecodablePacket {
    public static var packetType: Int16 {
        0x9e7
    }

    public var packetLength: Int16 {
        2 + 1
    }

    public var unread: Int8

    public init(from decoder: BinaryDecoder) throws {
        try decoder.decodePacketType(Self.self)

        unread = try decoder.decode(Int8.self)
    }
}
