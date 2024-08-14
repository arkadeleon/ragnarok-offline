//
//  PACKET_SC_NOTIFY_BAN.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/3/27.
//

public struct PACKET_SC_NOTIFY_BAN: DecodablePacket {
    public static var packetType: UInt16 {
        0x81
    }

    public var packetLength: UInt16 {
        2 + 1
    }

    public var errorCode: UInt8

    public init(from decoder: BinaryDecoder) throws {
        try decoder.decodePacketType(Self.self)

        errorCode = try decoder.decode(UInt8.self)
    }
}
