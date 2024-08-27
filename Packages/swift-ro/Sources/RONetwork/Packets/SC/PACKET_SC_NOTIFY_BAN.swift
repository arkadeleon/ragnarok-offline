//
//  PACKET_SC_NOTIFY_BAN.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/3/27.
//

/// See `logclif_sent_auth_result` or `clif_authfail_fd`
public struct PACKET_SC_NOTIFY_BAN: DecodablePacket {
    public static var packetType: Int16 {
        0x81
    }

    public var packetLength: Int16 {
        2 + 1
    }

    public var result: UInt8

    public init(from decoder: BinaryDecoder) throws {
        try decoder.decodePacketType(Self.self)

        result = try decoder.decode(UInt8.self)
    }
}
