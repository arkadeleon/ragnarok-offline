//
//  PACKET_ZC_MAIL_RECEIVE.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/8/28.
//

import ROCore

/// See `clif_Mail_new`
public struct PACKET_ZC_MAIL_RECEIVE: DecodablePacket {
    public static var packetType: Int16 {
        0x24a
    }

    public var packetLength: Int16 {
        2 + 4 + 40 + 24
    }

    public var mailID: UInt32
    public var title: String
    public var sender: String

    public init(from decoder: BinaryDecoder) throws {
        try decoder.decodePacketType(Self.self)

        mailID = try decoder.decode(UInt32.self)
        title = try decoder.decode(String.self, length: 40)
        sender = try decoder.decode(String.self, length: 24)
    }
}
