//
//  PACKET_SC_NOTIFY_BAN.swift
//  RagnarokPackets
//
//  Created by Leon Li on 2024/3/27.
//

import BinaryIO

/// See `logclif_sent_auth_result` or `chclif_send_auth_result` or `clif_authfail_fd`
@available(*, deprecated, message: "Use generated struct instead.")
public struct _PACKET_SC_NOTIFY_BAN: _DecodablePacket {
    public static var packetType: Int16 {
        0x81
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
